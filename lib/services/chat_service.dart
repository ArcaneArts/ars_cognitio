import 'dart:convert';

import 'package:ars_cognitio/main.dart';
import 'package:ars_cognitio/model/chat/chat.dart';
import 'package:ars_cognitio/model/chat/chat_message.dart';
import 'package:ars_cognitio/model/settings.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:dart_openai/openai.dart';
import 'package:fast_log/fast_log.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:tiktoken/tiktoken.dart';

Map<String, double> completionCost = {
  "gpt-3.5-turbo": 0.002,
  "gpt-4": 0.06,
  "gpt-4-32k": 0.12
};
Map<String, double> promptCost = {
  "gpt-3.5-turbo": 0.002,
  "gpt-4": 0.03,
  "gpt-4-32k": 0.06
};

class ChatService extends ArsCognitioStatelessService {
  List<Chat> getChats() => data().getChats();

  Future<String> summarizeChat(Chat chat) =>
      openaiService().client().chat.create(model: "gpt-3.5-turbo", messages: [
        ...chat.messages!
            .map((e) => OpenAIChatCompletionChoiceMessageModel(
                role: e.role!, content: e.message!))
            .toList(),
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: "Summarize this chat into a title. Up to 5 words.")
      ]).then((value) {
        saveData((d) => d.track("gpt-3.5-turbo", value.usage));

        return value.choices.first.message.content
            .replaceAll("\"", "")
            .replaceAll("Title: ", "")
            .replaceAll(".", "");
      });

  Future<int> count(String model, String text) async {
    return encodingForModel(model).encode(text).length;
  }

  Stream<String?>? addMessage(Chat chat, ChatMessage message) {
    chat.messages ??= [];
    saveData((_) => chat.messages!.add(message));

    if (message.role == OpenAIChatMessageRole.user) {
      String buffer = "";
      count(data().getSettings().chatModel ?? availableChatModels.first,
              (chat.messages ?? []).map((e) => e.message ?? "").join(""))
          .then((value) => saveData((d) => d.addTokens(
              data().getSettings().chatModel ?? availableChatModels.first,
              value,
              0)));
      Stream<String?> s = openaiService().client().chat.createStream(
          model: data().getSettings().chatModel ?? availableChatModels.first,
          frequencyPenalty: data().getSettings().frequencyPenalty ?? 0,
          presencePenalty: data().getSettings().presencePenalty ?? 0,
          temperature: data().getSettings().chatTemperature ?? 1,
          messages: [
            ...chat.messages!
                .map((e) => OpenAIChatCompletionChoiceMessageModel(
                    role: e.role!, content: e.message!))
                .toList(),
          ]).handleError((e, es) {
        error(e);
        error(es);
      }).map((event) {
        if (event.choices.first.finishReason != null) {
          saveData((d) {
            chat.messages!.add(ChatMessage.create(
                role: OpenAIChatMessageRole.assistant,
                streaming: false,
                message: buffer + (event.choices.first.delta.content ?? "")));
            count(data().getSettings().chatModel ?? availableChatModels.first,
                    buffer + (event.choices.first.delta.content ?? ""))
                .then((value) => saveData((d) => d.addTokens(
                    data().getSettings().chatModel ?? availableChatModels.first,
                    0,
                    value)));
          });
          info(
              "Adding message: ${buffer + (event.choices.first.delta.content ?? "")}");
          summarizeChat(chat).then((value) {
            saveData((_) => chat.title = value);
            info("Setting title: $value");
          });
          return null;
        }
        buffer += (event.choices.first.delta.content ?? "");
        return buffer;
      });

      return s;
    }

    return null;
  }

  void deleteChat(String uuid) => saveData(
      (_) => getChats().removeWhere((element) => element.uuid == uuid));

  Chat newChat() {
    Chat c = Chat.create(title: "New Chat", uuid: const Uuid().v4());
    saveData((_) => getChats().add(c));
    return c;
  }

  String tkSummary() =>
      "${NumberFormat("###,###", "en_US").format(data().getTotalTokens())} Tokens, \$${NumberFormat("###,###.##", "en_US").format(data().getTotalCost())}";
}
