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
  List<Measurement> _measurements = [];
  StreamSubscription<QuerySnapshot> _measurementsSubscription;

  @override
  void initState() {
    super.initState();

    _measurementsSubscription = _getMeasurementsCollection().orderBy('date', descending: true).snapshots().listen((data) {
      setState(() {
        _measurements = data.docs.map((doc) => Measurement.fromJson(doc.id, doc.data())).toList();
      });
    });
  }

  @override
  void dispose() {
    if (_measurementsSubscription != null) {
      _measurementsSubscription.cancel();
    }
    super.dispose();
  }

  CollectionReference _getMeasurementsCollection() =>
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('measurements');

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
            startActionPane: ActionPane(
              motion: DrawerMotion(),
              extentRatio: 0.25,
              children: [],
            ),
            endActionPane: ActionPane(
              motion: DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  label: '削除',
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  onPressed: (context) {
                    final String id = _measurements[i].id;
                    final String dateStr = DateFormat('y/M/d').format(_measurements[i].date);
                    return _getMeasurementsCollection().doc(id).delete()
                      .then((_) => FirebaseStorage.instance.ref().child('users/${FirebaseAuth.instance.currentUser.uid}/measurements/$id').delete())
                      .then((_) => _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('$dateStr の測定結果を削除しました。'),
                      )));
                  },
                ),
              ]
            ),
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
              onTap: () => FirebaseStorage.instance.ref().child('users/${FirebaseAuth.instance.currentUser.uid}/measurements/${_measurements[i].id}').getDownloadURL()
                .then((url) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                      FormWidget(_measurements[i], Image.network(url), (measurement) => _getMeasurementsCollection().doc(measurement.id).update(measurement.toJson())),
                    fullscreenDialog: true,
                  )
                )),
            ),
          ),
        separatorBuilder: (context, i) => Divider(height: 1),
      ),
    );
  }
}
