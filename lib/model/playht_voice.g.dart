// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playht_voice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayhtVoice _$PlayhtVoiceFromJson(Map<String, dynamic> json) => PlayhtVoice()
  ..name = json['name'] as String?
  ..gender = json['gender'] as String?
  ..id = json['id'] as String?
  ..accent = json['accent'] as String?
  ..age = json['age'] as String?
  ..tempo = json['tempo'] as String?
  ..loudness = json['loudness'] as String?
  ..language = json['language'] as String?
  ..languageCode = json['languageCode'] as String?
  ..sample = json['sample'] as String?
  ..texture = json['texture'] as String?
  ..style = json['style'] as String?;

Map<String, dynamic> _$PlayhtVoiceToJson(PlayhtVoice instance) =>
    <String, dynamic>{
      'name': instance.name,
      'gender': instance.gender,
      'id': instance.id,
      'accent': instance.accent,
      'age': instance.age,
      'tempo': instance.tempo,
      'loudness': instance.loudness,
      'language': instance.language,
      'languageCode': instance.languageCode,
      'sample': instance.sample,
      'texture': instance.texture,
      'style': instance.style,
    };
