// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat()
  ..title = json['title'] as String?
  ..uuid = json['uuid'] as String?
  ..messages = (json['messages'] as List<dynamic>?)
      ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'title': instance.title,
      'uuid': instance.uuid,
      'messages': instance.messages,
    };
