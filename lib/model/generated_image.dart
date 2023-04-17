/*
 * Copyright (c) 2022-2023.. MyGuide
 *
 * MyGuide is a closed source project developed by Arcane Arts.
 * Do not copy, share, distribute or otherwise allow this source file
 * to leave hardware approved by Arcane Arts unless otherwise
 * approved by Arcane Arts.
 */

import 'package:json_annotation/json_annotation.dart';

part 'generated_image.g.dart';

@JsonSerializable()
class GeneratedImage {
  String? image;
  String? promptImage;
  String? superImage;
  String? model;
  String? prompt;
  int? seed;
  String? negativePrompt;
  bool? enhancePrompt = true;
  bool? safetyChecker = true;
  double? promptStrength = 0.85;
  double? guidanceScale = 7.5;
  int? inferenceSteps = 50;
  int? width = 512;
  int? height = 512;

  String bestImage() => superImage ?? image ?? promptImage ?? "error";

  GeneratedImage();

  factory GeneratedImage.fromJson(Map<String, dynamic> json) =>
      _$GeneratedImageFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedImageToJson(this);
}
