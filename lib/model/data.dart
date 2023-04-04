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
import 'package:json_annotation/json_annotation.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  List<Chat>? chats;
  Settings? settings;

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
