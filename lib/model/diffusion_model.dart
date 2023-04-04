import 'package:json_annotation/json_annotation.dart';

part 'diffusion_model.g.dart';

@JsonSerializable()
class DiffusionModel {
  @JsonKey(name: "model_id")
  String? id;
  String? status;
  @JsonKey(name: "model_name")
  String? name;
  String? description;
  String? screenshots;

  DiffusionModel();

  factory DiffusionModel.fromJson(Map<String, dynamic> json) =>
      _$DiffusionModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiffusionModelToJson(this);
}
