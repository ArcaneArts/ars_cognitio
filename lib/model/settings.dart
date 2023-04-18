/*
 * Copyright (c) 2022-2023.. MyGuide
 *
 * MyGuide is a closed source project developed by Arcane Arts.
 * Do not copy, share, distribute or otherwise allow this source file
 * to leave hardware approved by Arcane Arts unless otherwise
 * approved by Arcane Arts.
 */

import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings {
  String? openAiKey;
  String? openAiOrganization;
  String? googleServiceAccountJson;
  String? playhtUser;
  String? playhtSecret;
  String? playhtVoice = "Lottie";
  String? stableDiffusionApiKey;
  String? chatModel = availableChatModels.first;
  double? chatTemperature = 1.0;
  double? presencePenalty = 0.0; // -2 to 2
  double? frequencyPenalty = 0.0; // -2 to 2
  bool? enhancePrompt = true;
  bool? safetyChecker = true;
  double? promptStrength = 0.85;
  double? guidanceScale = 7.5;
  int? inferenceSteps = 50;
  int? width = 512;
  int? height = 512;

  Settings();

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}

List<String> availableChatModels = ["gpt-3.5-turbo", "gpt-4", "gpt-4-32k"];
