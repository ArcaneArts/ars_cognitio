import 'package:json_annotation/json_annotation.dart';

part 'playht_voice.g.dart';

@JsonSerializable()
class PlayhtVoice {
  String? name;
  String? gender;
  String? value;
  String? accent;
  String? age;
  String? tempo;
  String? loudness;
  String? language;
  String? languageCode;
  String? sample;
  String? texture;
  String? style;
  bool? hq;
  bool? isPopular;
  bool? isNew;
  bool? isExperimental;

  PlayhtVoice();

  factory PlayhtVoice.fromJson(Map<String, dynamic> json) =>
      _$PlayhtVoiceFromJson(json);

  Map<String, dynamic> toJson() => _$PlayhtVoiceToJson(this);
}
