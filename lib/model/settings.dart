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
  String? stableDiffusionApiKey;

  Settings();

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
