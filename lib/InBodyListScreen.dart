
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'InBodyData.dart';

class InBodyListScreen extends StatefulWidget {
  InBodyListScreen({Key key, this.history}) : super(key: key);

  final Map<DateTime, InBodyData> history;

  @override
  _InBodyListScreenState createState() => _InBodyListScreenState();
}

class _InBodyListScreenState extends State<InBodyListScreen> {
  @override
  Widget build(BuildContext context) {
    List<MapEntry<DateTime, InBodyData>> items = widget.history.entries.toList();
    items.sort((a, b) => b.key.compareTo(a.key));
    return Scaffold(
      appBar: AppBar(
        title: Text('履歴'),
      ),
      body: ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, i) =>
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: ListTile(
              title: Text(DateFormat('yyyy-MM-dd').format(items[i].key)),
              subtitle: Text('体重 ${items[i].value.bodyWeight} kg, 筋肉 ${items[i].value.muscleWeight} kg, 体脂肪 ${items[i].value.bodyFatWeight} kg, BMI ${items[i].value.bmi} kg/㎡, 体脂肪率 ${items[i].value.bodyFatPercentage} %'),
              contentPadding: EdgeInsets.all(12.0),
            ),
            actions: [],
            secondaryActions: [
              IconSlideAction(
                caption: '削除',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () =>
                  FirebaseAuth.instance.currentUser()
                    .then((user) => Firestore.instance.collection('users').document(user.uid).collection('measurements').document(items[i].value.id).delete()),
              ),
            ],
          ),
        separatorBuilder: (context, i) => Divider(height: 1),
      ),
    );
  }
}
