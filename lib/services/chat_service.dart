import 'dart:convert';

import 'package:ars_cognitio/main.dart';
import 'package:ars_cognitio/model/chat/chat.dart';
import 'package:ars_cognitio/model/chat/chat_message.dart';
import 'package:ars_cognitio/model/settings.dart';
import 'package:ars_cognitio/sugar.dart';
import 'package:dart_openai/openai.dart';
import 'package:fast_log/fast_log.dart';
import 'package:uuid/uuid.dart';

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
      ]).then((value) => value.choices.first.message.content
          .replaceAll("\"", "")
          .replaceAll("Title: ", "")
          .replaceAll(".", ""));

  Stream<String?>? addMessage(Chat chat, ChatMessage message) {
    chat.messages ??= [];
    saveData((_) => chat.messages!.add(message));

    if (message.role == OpenAIChatMessageRole.user) {
      String buffer = "";
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
          saveData((_) => chat.messages!.add(ChatMessage.create(
              role: OpenAIChatMessageRole.assistant,
              streaming: false,
              message: buffer + (event.choices.first.delta.content ?? ""))));
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
}
