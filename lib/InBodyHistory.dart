import 'package:flutter/material.dart';
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
    return widget.history != null ? Container(
      child: Column(
        children: widget.history.values.map((InBodyData data) => Text(data.toJson().toString())).toList(),
      ),
    ) : Container();
  }
}
