class InBodyData {
  String id;
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
    this.leftLegPercentage,
    {this.id});

  factory InBodyData.fromJson(String id, Map<String, dynamic> json) => 
    InBodyData(
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
      id: id,
    );

  Map<String, dynamic> toJson() =>
    {
      'date': this.date?.toIso8601String(),
      'bodyWeight': this.bodyWeight,
      'muscleWeight': this.muscleWeight,
      'bodyFatWeight': this.bodyFatWeight,
      'rightArmWeight': this.rightArmWeight,
      'leftArmWeight': this.leftArmWeight,
      'trunkWeight': this.trunkWeight,
      'rightLegWeight': this.rightLegWeight,
      'leftLegWeight': this.leftLegWeight,
      'bmi': this.bmi,
      'bodyFatPercentage': this.bodyFatPercentage,
      'trunkPercentage': this.trunkPercentage,
      'rightLegPercentage': this.rightLegPercentage,
      'leftLegPercentage': this.leftLegPercentage,
    };
}