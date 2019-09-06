import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'InBodyData.dart';

class InBodyHistory extends StatefulWidget {
  InBodyHistory({Key key, this.history}) : super(key: key);

  final Map<DateTime, InBodyData> history;

  @override
  _InBodyHistoryState createState() => _InBodyHistoryState();
}

class _InBodyHistoryState extends State<InBodyHistory> {
  @override
  Widget build(BuildContext context) {
    if (widget.history == null) {
      return Container();
    }
    List<DateTime> dates = widget.history.keys.toList();
    dates.sort();
    return Container(
      padding: EdgeInsets.only(top: 10, right: 10, bottom: 80, left: 10),
      child: charts.TimeSeriesChart(
        [
          charts.Series<LinearBodyWeight, DateTime> (
            id: 'BodyWeight',
            domainFn: (LinearBodyWeight bodyWeight, _) => bodyWeight.date,
            measureFn: (LinearBodyWeight bodyWeight, _) => bodyWeight.value,
            data: dates.map((DateTime date) => LinearBodyWeight(date, widget.history[date].bodyWeight)).toList(),
          ),
        ],
        domainAxis: charts.EndPointsTimeAxisSpec(),
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
        ),
      ),
    );
  }
}

class LinearBodyWeight {
  final DateTime date;
  final double value;

  LinearBodyWeight(this.date, this.value);
}