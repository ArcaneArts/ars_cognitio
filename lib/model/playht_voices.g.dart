// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playht_voices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayhtVoices _$PlayhtVoicesFromJson(Map<String, dynamic> json) => PlayhtVoices()
  ..voices = (json['voices'] as List<dynamic>?)
      ?.map((e) => PlayhtVoice.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$PlayhtVoicesToJson(PlayhtVoices instance) =>
    <String, dynamic>{
      'voices': instance.voices,
    };
