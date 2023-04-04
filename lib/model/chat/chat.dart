import 'dart:convert';

import 'package:ars_cognitio/model/chat/chat_message.dart';

import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  String? title;
  String? uuid;
  List<ChatMessage>? messages;

  Chat();

  Chat.create({this.title, this.uuid}) : messages = [];

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);
}
