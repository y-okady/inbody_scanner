// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'InBodyData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InBodyData _$InBodyDataFromJson(Map<String, dynamic> json) {
  return InBodyData(
    json['date'] == null ? null : DateTime.parse(json['date'] as String),
    (json['bodyWeight'] as num)?.toDouble(),
    (json['muscleWeight'] as num)?.toDouble(),
    (json['bodyFatWeight'] as num)?.toDouble(),
    (json['rightArmWeight'] as num)?.toDouble(),
    (json['leftArmWeight'] as num)?.toDouble(),
    (json['trunkWeight'] as num)?.toDouble(),
    (json['rightLegWeight'] as num)?.toDouble(),
    (json['leftLegWeight'] as num)?.toDouble(),
    (json['bmi'] as num)?.toDouble(),
    (json['bodyFatPercentage'] as num)?.toDouble(),
    (json['trunkPercentage'] as num)?.toDouble(),
    (json['rightLegPercentage'] as num)?.toDouble(),
    (json['leftLegPercentage'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$InBodyDataToJson(InBodyData instance) =>
    <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'bodyWeight': instance.bodyWeight,
      'muscleWeight': instance.muscleWeight,
      'bodyFatWeight': instance.bodyFatWeight,
      'rightArmWeight': instance.rightArmWeight,
      'leftArmWeight': instance.leftArmWeight,
      'trunkWeight': instance.trunkWeight,
      'rightLegWeight': instance.rightLegWeight,
      'leftLegWeight': instance.leftLegWeight,
      'bmi': instance.bmi,
      'bodyFatPercentage': instance.bodyFatPercentage,
      'trunkPercentage': instance.trunkPercentage,
      'rightLegPercentage': instance.rightLegPercentage,
      'leftLegPercentage': instance.leftLegPercentage,
    };
