/*
 * Copyright (c) 2022-2023.. MyGuide
 *
 * MyGuide is a closed source project developed by Arcane Arts.
 * Do not copy, share, distribute or otherwise allow this source file
 * to leave hardware approved by Arcane Arts unless otherwise
 * approved by Arcane Arts.
 */

import 'package:ars_cognitio/model/chat/chat.dart';
import 'package:ars_cognitio/model/settings.dart';
import 'package:ars_cognitio/services/chat_service.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  List<Chat>? chats;
  Settings? settings;
  Map<String, int>? promptTokens;
  Map<String, int>? completionTokens;
  List<String>? systemTemplates;

  List<String> getSystemTemplates() {
    systemTemplates ??= [];
    return systemTemplates!;
  }

  Map<String, int> getPromptTokens() {
    promptTokens ??= {};
    return promptTokens!;
  }

  Map<String, int> getCompletionTokens() {
    completionTokens ??= {};
    return completionTokens!;
  }

  void track(String model, OpenAIChatCompletionUsageModel usage) {
    addTokens(model, usage.promptTokens, usage.completionTokens);
  }

  int getTotalPromptTokens() {
    List<int> c = [...getPromptTokens().values];
    if (c.length < 2) {
      c.add(0);
      c.add(0);
    }

    return c.reduce((a, b) => a + b);
  }

  int getTotalCompletionTokens() {
    List<int> c = [...getCompletionTokens().values];
    if (c.length < 2) {
      c.add(0);
      c.add(0);
    }

    return c.reduce((a, b) => a + b);
  }

  int getTotalTokens() => getTotalPromptTokens() + getTotalCompletionTokens();

  double getTotalCost() {
    double total = 0;
    for (var model in getPromptTokens().keys) {
      total += (getPromptTokensFor(model) / 1000.0) * (promptCost[model] ?? 0);
    }
    for (var model in getCompletionTokens().keys) {
      total += (getCompletionTokensFor(model) / 1000.0) *
          (completionCost[model] ?? 0);
    }

    return total;
  }

  int getPromptTokensFor(String model) => getPromptTokens()[model] ?? 0;

  int getCompletionTokensFor(String model) => getCompletionTokens()[model] ?? 0;

  List<String> getTrackedChatModels() =>
      {...getPromptTokens().keys, ...getCompletionTokens().keys}.toList();

  void addTokens(String model, int promptTokens, int completionTokens) {
    getPromptTokens()[model] = (getPromptTokens()[model] ?? 0) + promptTokens;
    getCompletionTokens()[model] =
        (getCompletionTokens()[model] ?? 0) + completionTokens;
  }

  List<Chat> getChats() {
    chats ??= [];
    return chats!;
  }

  Settings getSettings() {
    settings ??= Settings();
    return settings!;
  }

  Data();

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
