// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings()
  ..openAiKey = json['openAiKey'] as String?
  ..openAiOrganization = json['openAiOrganization'] as String?
  ..googleServiceAccountJson = json['googleServiceAccountJson'] as String?
  ..stableDiffusionApiKey = json['stableDiffusionApiKey'] as String?;

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'openAiKey': instance.openAiKey,
      'openAiOrganization': instance.openAiOrganization,
      'googleServiceAccountJson': instance.googleServiceAccountJson,
      'stableDiffusionApiKey': instance.stableDiffusionApiKey,
    };
