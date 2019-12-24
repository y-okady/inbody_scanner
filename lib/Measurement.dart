class Measurement {
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

  Measurement({
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
    this.id
  });

  factory Measurement.fromJson(String id, Map<String, dynamic> json) => 
    Measurement(
      date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
      bodyWeight: (json['bodyWeight'] as num)?.toDouble(),
      muscleWeight: (json['muscleWeight'] as num)?.toDouble(),
      bodyFatWeight: (json['bodyFatWeight'] as num)?.toDouble(),
      rightArmWeight: (json['rightArmWeight'] as num)?.toDouble(),
      leftArmWeight: (json['leftArmWeight'] as num)?.toDouble(),
      trunkWeight: (json['trunkWeight'] as num)?.toDouble(),
      rightLegWeight: (json['rightLegWeight'] as num)?.toDouble(),
      leftLegWeight: (json['leftLegWeight'] as num)?.toDouble(),
      bmi: (json['bmi'] as num)?.toDouble(),
      bodyFatPercentage: (json['bodyFatPercentage'] as num)?.toDouble(),
      trunkPercentage: (json['trunkPercentage'] as num)?.toDouble(),
      rightLegPercentage: (json['rightLegPercentage'] as num)?.toDouble(),
      leftLegPercentage: (json['leftLegPercentage'] as num)?.toDouble(),
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