// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage()
  ..role = $enumDecodeNullable(_$OpenAIChatMessageRoleEnumMap, json['role'])
  ..message = json['message'] as String?
  ..streaming = json['streaming'] as bool?;

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'role': _$OpenAIChatMessageRoleEnumMap[instance.role],
      'message': instance.message,
      'streaming': instance.streaming,
    };

const _$OpenAIChatMessageRoleEnumMap = {
  OpenAIChatMessageRole.system: 'system',
  OpenAIChatMessageRole.user: 'user',
  OpenAIChatMessageRole.assistant: 'assistant',
};
