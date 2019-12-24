import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  Future<void> _deleteMeasurement(String id) =>
    _getMeasurementsCollection()
      .then((collection) => collection.document(id).delete());

  Future<void> _deleteImage(String id) =>
    FirebaseAuth.instance.currentUser()
      .then((user) => FirebaseStorage.instance.ref().child('users/${user.uid}/measurements/$id').delete());

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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('データの編集'),
      ),
      body: _measurements.isEmpty ? Container(
        padding: EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text('測定結果はありません。',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ) : ListView.separated(
        itemCount: _measurements.length,
        itemBuilder: (context, i) =>
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: ListTile(
              title: Container(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text(DateFormat('y/M/d').format(_measurements[i].date)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('体重 ${_measurements[i].bodyWeight} kg, 筋肉 ${_measurements[i].muscleWeight} kg, 体脂肪 ${_measurements[i].bodyFatWeight} kg'),
                  Text('BMI ${_measurements[i].bmi} kg/m², 体脂肪率 ${_measurements[i].bodyFatPercentage} %'),
                ]
              ),
              contentPadding: EdgeInsets.all(12.0),
              onTap: () => FirebaseAuth.instance.currentUser()
                .then((user) => FirebaseStorage.instance.ref().child('users/${user.uid}/measurements/${_measurements[i].id}').getDownloadURL())
                .then((url) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                      FormWidget(_measurements[i], Image.network(url), _updateMeasurement),
                    fullscreenDialog: true,
                  )
                )),
            ),
            actions: [],
            secondaryActions: [
              IconSlideAction(
                caption: '削除',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  final String id = _measurements[i].id;
                  final String dateStr = DateFormat('y/M/d').format(_measurements[i].date);
                  return _deleteMeasurement(id)
                    .then((_) => _deleteImage(id))
                    .then((_) => _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text('$dateStr の測定結果を削除しました。'),
                    )));
                }
              ),
            ],
          ),
        separatorBuilder: (context, i) => Divider(height: 1),
      ),
    );
  }
}
