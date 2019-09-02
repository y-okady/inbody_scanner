import 'package:json_annotation/json_annotation.dart';

// flutter pub run build_runner build
part 'InBodyData.g.dart';

@JsonSerializable()
class InBodyData {
  DateTime date;
  double bodyWeight;
  double muscleWeight;
  double bodyFatWeight;
  double rightArmWeight;
  double leftArmWeight;
  double trunkWeight;
  double rightLegWeight;
  double leftLegWeight;
  double bmi;
  double bodyFatPercentage;
  double trunkPercentage;
  double rightLegPercentage;
  double leftLegPercentage;

  InBodyData(
    this.date,
    this.bodyWeight,
    this.muscleWeight,
    this.bodyFatWeight,
    this.rightArmWeight,
    this.leftArmWeight,
    this.trunkWeight,
    this.rightLegWeight,
    this.leftLegWeight,
    this.bmi,
    this.bodyFatPercentage,
    this.trunkPercentage,
    this.rightLegPercentage,
    this.leftLegPercentage);

  factory InBodyData.fromJson(Map<String, dynamic> json) => _$InBodyDataFromJson(json);

  Map<String, dynamic> toJson() => _$InBodyDataToJson(this);
}