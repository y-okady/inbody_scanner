import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'InBodyData.dart';

class InBodyCharts extends StatefulWidget {
  InBodyCharts(this.measurements, {Key key}) : super(key: key);

  final List<InBodyData> measurements;

  @override
  _InBodyChartsState createState() => _InBodyChartsState();
}

class _InBodyChartsState extends State<InBodyCharts> {
  Widget _buildChart(String caption, List<LinearData> values, List<ChartSeries> serieses, {bool legend = true}) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(caption,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          height: 200,
          child: charts.TimeSeriesChart(
            serieses.map((series) =>
              charts.Series<LinearData, DateTime> (
                id: series.legend,
                domainFn: (LinearData data, _) => data.date,
                measureFn: series.measureFn,
                colorFn: series.colorFn,
                data: values,
              )
            ).toList(),
            domainAxis: charts.EndPointsTimeAxisSpec(),
            primaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
            ),
            behaviors: legend ? [charts.SeriesLegend()] : [],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LinearData> values = widget.measurements.map((InBodyData measurement) => LinearData(measurement.date, measurement)).toList();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 10),),
          _buildChart('体重 (kg)', values, [
            ChartSeries.blue('体重', (LinearData data, _) => data.value.bodyWeight),
          ], legend: false),
          _buildChart('BMI (kg/㎡)', values, [
            ChartSeries.blue('BMI', (LinearData data, _) => data.value.bmi),
          ], legend: false),
          _buildChart('体脂肪率 (%)', values, [
            ChartSeries.blue('体脂肪率', (LinearData data, _) => data.value.bodyFatPercentage),
          ], legend: false),
          _buildChart('体脂肪 (kg)', values, [
            ChartSeries.blue('体脂肪', (LinearData data, _) => data.value.bodyFatWeight),
          ], legend: false),
          _buildChart('筋肉 (kg)', values, [
            ChartSeries.green('筋肉', (LinearData data, _) => data.value.muscleWeight),
          ], legend: false),
          _buildChart('腕の筋肉 (kg)', values, [
            ChartSeries.cyan('右腕', (LinearData data, _) => data.value.rightArmWeight),
            ChartSeries.teal('左腕', (LinearData data, _) => data.value.leftArmWeight),
          ],),
          _buildChart('胴体の筋肉 (kg)', values, [
            ChartSeries.green('胴体', (LinearData data, _) => data.value.trunkWeight),
          ],),
          _buildChart('脚の筋肉 (kg)', values, [
            ChartSeries.cyan('右脚', (LinearData data, _) => data.value.rightLegWeight),
            ChartSeries.teal('左脚', (LinearData data, _) => data.value.leftLegWeight),
          ],),
          _buildChart('発達程度 (%)', values, [
            ChartSeries.green('胴体', (LinearData data, _) => data.value.trunkPercentage),
            ChartSeries.cyan('右脚', (LinearData data, _) => data.value.rightLegPercentage),
            ChartSeries.teal('左脚', (LinearData data, _) => data.value.leftLegPercentage),
          ],),
          Padding(padding: EdgeInsets.only(bottom: 80),)
        ],
      ),
    );
  }
}

class LinearData {
  final DateTime date;
  final InBodyData value;

  LinearData(this.date, this.value);
}

class ChartSeries {
  final String legend;
  final num Function(LinearData, int) measureFn;
  charts.Color Function(LinearData, int) colorFn;

  ChartSeries.blue(this.legend, this.measureFn) {
    this.colorFn = (_, __) => charts.MaterialPalette.blue.shadeDefault;
  }

  ChartSeries.green(this.legend, this.measureFn) {
    this.colorFn = (_, __) => charts.MaterialPalette.green.shadeDefault;
  }

  ChartSeries.cyan(this.legend, this.measureFn) {
    this.colorFn = (_, __) => charts.MaterialPalette.cyan.shadeDefault;
  }

  ChartSeries.teal(this.legend, this.measureFn) {
    this.colorFn = (_, __) => charts.MaterialPalette.teal.shadeDefault;
  }
}