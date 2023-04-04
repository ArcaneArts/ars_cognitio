// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diffusion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiffusionModel _$DiffusionModelFromJson(Map<String, dynamic> json) =>
    DiffusionModel()
      ..id = json['model_id'] as String?
      ..status = json['status'] as String?
      ..name = json['model_name'] as String?
      ..description = json['description'] as String?
      ..screenshots = json['screenshots'] as String?;

Map<String, dynamic> _$DiffusionModelToJson(DiffusionModel instance) =>
    <String, dynamic>{
      'model_id': instance.id,
      'status': instance.status,
      'model_name': instance.name,
      'description': instance.description,
      'screenshots': instance.screenshots,
    };
