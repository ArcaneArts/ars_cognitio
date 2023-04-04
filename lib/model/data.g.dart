// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) => Data()
  ..chats = (json['chats'] as List<dynamic>?)
      ?.map((e) => Chat.fromJson(e as Map<String, dynamic>))
      .toList()
  ..settings = json['settings'] == null
      ? null
      : Settings.fromJson(json['settings'] as Map<String, dynamic>);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'chats': instance.chats,
      'settings': instance.settings,
    };
