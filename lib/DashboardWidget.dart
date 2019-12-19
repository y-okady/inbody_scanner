import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'Measurement.dart';

class DashboardWidget extends StatelessWidget {
  DashboardWidget(this.measurements, {Key key}) : super(key: key);

  final List<Measurement> measurements;

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text('測定結果はありません。'),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _ItemWidget('体重', 'kg', false, measurements, (measurement) => measurement.bodyWeight),
          _ItemWidget('BMI', 'kg/m2', false, measurements, (measurement) => measurement.bmi),
          _ItemWidget('体脂肪率', '%', false, measurements, (measurement) => measurement.bodyFatPercentage),
          _ItemWidget('体脂肪', 'kg', false, measurements, (measurement) => measurement.bodyFatWeight),
          _ItemWidget('筋肉', 'kg', true, measurements, (measurement) => measurement.muscleWeight),
          _ItemWidget('右腕の筋肉', 'kg', true, measurements, (measurement) => measurement.rightArmWeight),
          _ItemWidget('左腕の筋肉', 'kg', true, measurements, (measurement) => measurement.leftArmWeight),
          _ItemWidget('胴体の筋肉', 'kg', true, measurements, (measurement) => measurement.trunkWeight),
          _ItemWidget('右脚の筋肉', 'kg', true, measurements, (measurement) => measurement.rightLegWeight),
          _ItemWidget('左脚の筋肉', 'kg', true, measurements, (measurement) => measurement.leftLegWeight),
          _ItemWidget('胴体の筋肉発達程度', '%', true, measurements, (measurement) => measurement.trunkPercentage),
          _ItemWidget('右脚の筋肉発達程度', '%', true, measurements, (measurement) => measurement.rightLegPercentage),
          _ItemWidget('左脚の筋肉発達程度', '%', true, measurements, (measurement) => measurement.leftLegPercentage),
          Padding(
            padding: EdgeInsets.only(bottom: 80),
          ),
        ],
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  _ItemWidget(this.label, this.unit, this.positive, this.measurements, this.valueFn);

  final String label;
  final String unit;
  final bool positive;
  final List<Measurement> measurements;
  final double Function(Measurement) valueFn; 

  @override
  Widget build(BuildContext context) {
    double latestValue = valueFn(measurements[0]);
    double prevValue = measurements.length > 1 ? valueFn(measurements[1]) : null;
    double diff = prevValue != null ? ((latestValue - prevValue) * 10).round() / 10 : 0;
    return Container(
      padding: EdgeInsets.all(8),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 12),
                child: Text(label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(latestValue.toString(),
                        style: TextStyle(
                          fontSize: 32,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 4, bottom: 4),
                      child: Text('$unit',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              prevValue != null ? Container(
                margin: EdgeInsets.only(right: 4, bottom: 4),
                child: Text('${diff == 0 ? '±' : diff > 0 ? '+' : ''}$diff $unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: diff == 0 ? Colors.grey : (diff > 0) && positive || (diff < 0) && ! positive ? Colors.green : Colors.red,
                  ),
                ),
              ) : Container(),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    height: 100,
                    child: charts.TimeSeriesChart(
                      [
                        charts.Series<_LinearData, DateTime> (
                          id: label,
                          domainFn: (_LinearData data, _) => data.date,
                          measureFn: (_LinearData data, _) => valueFn(data.value),
                          data: measurements.map((measurement) => _LinearData(measurement.date, measurement)).toList(),
                        )
                      ],
                      domainAxis: charts.EndPointsTimeAxisSpec(),
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _LinearData {
  final DateTime date;
  final Measurement value;

  _LinearData(this.date, this.value);
}
