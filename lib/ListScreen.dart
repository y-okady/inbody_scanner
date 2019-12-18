
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'Measurement.dart';
import 'FormWidget.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Measurement> _measurements = List();
  StreamSubscription<QuerySnapshot> _measurementsSubscription;

  @override
  void initState() {
    super.initState();

    _subscribeMeasurements()
      .then((subscription) => _measurementsSubscription = subscription);
  }

  @override
  void dispose() {
    if (_measurementsSubscription != null) {
      _measurementsSubscription.cancel();
    }
    super.dispose();
  }

  Future<CollectionReference> _getMeasurementsCollection() =>
    FirebaseAuth.instance.currentUser()
      .then((user) => Firestore.instance.collection('users').document(user.uid).collection('measurements'));

  Future<void> _updateMeasurement(Measurement measurement) =>
    _getMeasurementsCollection()
      .then((collection) => collection.document(measurement.id).setData(measurement.toJson()));

  Future<void> _deleteMeasurement(Measurement measurement) =>
    _getMeasurementsCollection()
      .then((collection) => collection.document(measurement.id).delete());

  Future<StreamSubscription<QuerySnapshot>> _subscribeMeasurements() =>
    _getMeasurementsCollection()
      .then((collection) => collection.orderBy('date', descending: true).snapshots().listen((data) {
        setState(() {
          _measurements = data.documents.map((doc) => Measurement.fromJson(doc.documentID, doc.data)).toList();
        });
      }));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('履歴'),
      ),
      body: ListView.separated(
        itemCount: _measurements.length,
        itemBuilder: (context, i) =>
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: ListTile(
              title: Container(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text(DateFormat('yyyy-MM-dd').format(_measurements[i].date)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('体重 ${_measurements[i].bodyWeight} kg, 筋肉 ${_measurements[i].muscleWeight} kg, 体脂肪 ${_measurements[i].bodyFatWeight} kg'),
                  Text('BMI ${_measurements[i].bmi} kg/㎡, 体脂肪率 ${_measurements[i].bodyFatPercentage} %'),
                ]
              ),
              contentPadding: EdgeInsets.all(12.0),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                      FormWidget(_measurements[i], _updateMeasurement),
                    fullscreenDialog: true,
                  )
                );
              },
            ),
            actions: [],
            secondaryActions: [
              IconSlideAction(
                caption: '削除',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => _deleteMeasurement(_measurements[i]),
              ),
            ],
          ),
        separatorBuilder: (context, i) => Divider(height: 1),
      ),
    );
  }
}
