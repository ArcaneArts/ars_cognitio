import 'package:ars_cognitio/model/playht_voice.dart';
import 'package:json_annotation/json_annotation.dart';

part 'playht_voices.g.dart';

@JsonSerializable()
class PlayhtVoices {
  List<PlayhtVoice>? voices;

  PlayhtVoices();

  factory PlayhtVoices.fromJson(Map<String, dynamic> json) =>
      _$PlayhtVoicesFromJson(json);

  Map<String, dynamic> toJson() => _$PlayhtVoicesToJson(this);
}
