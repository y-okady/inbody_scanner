import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// flutter pub run build_runner build
part 'InBodyData.g.dart';

@JsonSerializable()
class InBodyData {
  static const String KEY = 'inBodyData';

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

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<DateTime, InBodyData> map = await load();
    map[date] = this;
    return prefs.setString(KEY, jsonEncode(map.map((DateTime date, InBodyData data) =>
      MapEntry(date.toIso8601String(), data.toJson())
    )));
  }

  static Future<Map<DateTime, InBodyData>> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(KEY)) {
      return Map();
    }
    Map<String, dynamic> json = jsonDecode(prefs.get(KEY));
    return json.map((String key, dynamic value) =>
      MapEntry(DateTime.parse(key), InBodyData.fromJson(value))
    );
  }
}