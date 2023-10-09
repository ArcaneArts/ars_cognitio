import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage {
  OpenAIChatMessageRole? role;
  String? message;
  bool? streaming;

  ChatMessage();

  ChatMessage.create({this.role, this.message, this.streaming = false});

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}
