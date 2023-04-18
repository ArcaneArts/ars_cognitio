// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings()
  ..openAiKey = json['openAiKey'] as String?
  ..openAiOrganization = json['openAiOrganization'] as String?
  ..googleServiceAccountJson = json['googleServiceAccountJson'] as String?
  ..playhtUser = json['playhtUser'] as String?
  ..playhtSecret = json['playhtSecret'] as String?
  ..playhtVoice = json['playhtVoice'] as String?
  ..stableDiffusionApiKey = json['stableDiffusionApiKey'] as String?
  ..chatModel = json['chatModel'] as String?
  ..chatTemperature = (json['chatTemperature'] as num?)?.toDouble()
  ..presencePenalty = (json['presencePenalty'] as num?)?.toDouble()
  ..frequencyPenalty = (json['frequencyPenalty'] as num?)?.toDouble()
  ..enhancePrompt = json['enhancePrompt'] as bool?
  ..safetyChecker = json['safetyChecker'] as bool?
  ..promptStrength = (json['promptStrength'] as num?)?.toDouble()
  ..guidanceScale = (json['guidanceScale'] as num?)?.toDouble()
  ..inferenceSteps = json['inferenceSteps'] as int?
  ..width = json['width'] as int?
  ..height = json['height'] as int?;

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'openAiKey': instance.openAiKey,
      'openAiOrganization': instance.openAiOrganization,
      'googleServiceAccountJson': instance.googleServiceAccountJson,
      'playhtUser': instance.playhtUser,
      'playhtSecret': instance.playhtSecret,
      'playhtVoice': instance.playhtVoice,
      'stableDiffusionApiKey': instance.stableDiffusionApiKey,
      'chatModel': instance.chatModel,
      'chatTemperature': instance.chatTemperature,
      'presencePenalty': instance.presencePenalty,
      'frequencyPenalty': instance.frequencyPenalty,
      'enhancePrompt': instance.enhancePrompt,
      'safetyChecker': instance.safetyChecker,
      'promptStrength': instance.promptStrength,
      'guidanceScale': instance.guidanceScale,
      'inferenceSteps': instance.inferenceSteps,
      'width': instance.width,
      'height': instance.height,
    };
