// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratedImage _$GeneratedImageFromJson(Map<String, dynamic> json) =>
    GeneratedImage()
      ..image = json['image'] as String?
      ..promptImage = json['promptImage'] as String?
      ..superImage = json['superImage'] as String?
      ..model = json['model'] as String?
      ..prompt = json['prompt'] as String?
      ..seed = json['seed'] as int?
      ..negativePrompt = json['negativePrompt'] as String?
      ..enhancePrompt = json['enhancePrompt'] as bool?
      ..safetyChecker = json['safetyChecker'] as bool?
      ..promptStrength = (json['promptStrength'] as num?)?.toDouble()
      ..guidanceScale = (json['guidanceScale'] as num?)?.toDouble()
      ..inferenceSteps = json['inferenceSteps'] as int?
      ..width = json['width'] as int?
      ..height = json['height'] as int?;

Map<String, dynamic> _$GeneratedImageToJson(GeneratedImage instance) =>
    <String, dynamic>{
      'image': instance.image,
      'promptImage': instance.promptImage,
      'superImage': instance.superImage,
      'model': instance.model,
      'prompt': instance.prompt,
      'seed': instance.seed,
      'negativePrompt': instance.negativePrompt,
      'enhancePrompt': instance.enhancePrompt,
      'safetyChecker': instance.safetyChecker,
      'promptStrength': instance.promptStrength,
      'guidanceScale': instance.guidanceScale,
      'inferenceSteps': instance.inferenceSteps,
      'width': instance.width,
      'height': instance.height,
    };
