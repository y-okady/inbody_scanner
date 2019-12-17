import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'InBodyData.dart';
import 'InBodyForm.dart';
import 'InBodyHistory.dart';
import 'InBodyScanner.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum AppBarMenuItem {
  LoadImage,
  SignOut,
}

class _HomeScreenState extends State<HomeScreen> {
  static const String KEY = 'inBodyData';
  bool _loading = false;
  Map<DateTime, InBodyData> _history;
  FirebaseUser _user;
  StreamSubscription<QuerySnapshot> _measurementsSubscription;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser()
      .then((user) => _user = user)
      .then((_) => _measurementsSubscription = _subscribeMeasurements());
  }

  @override
  void dispose() {
    if (_measurementsSubscription != null) {
      _measurementsSubscription.cancel();
    }
    super.dispose();
  }

  void _signOut() =>
    FirebaseAuth.instance.signOut()
      .then((_) => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false));

  CollectionReference _getMeasurementsCollection() =>
    Firestore.instance.collection('users').document(_user.uid).collection('measurements');

  Future<void> _addMeasurement(InBodyData data) =>
    _getMeasurementsCollection().document().setData(data.toJson());

  StreamSubscription<QuerySnapshot> _subscribeMeasurements() =>
    _getMeasurementsCollection().snapshots().listen((data) {
      Map<DateTime, InBodyData> history = Map.fromIterable(data.documents,
        key: (doc) => DateTime.parse(doc['date']),
        value: (doc) => InBodyData.fromJson(doc.data),
      );
      setState(() {
        _history = history;
      });
    });

  Future<void> _scanImage(final File image) async {
    setState(() {
      _loading = true;
    });
    InBodyData data = await InBodyScanner.scan(image);
    setState(() {
      _loading = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return InBodyForm(data: data, onSubmit: _addMeasurement);
        },
        fullscreenDialog: true,
      )
    );
  }

  Future<void> _loadImage() async {
    if (_loading) {
      return;
    }
    final File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    await _scanImage(image);
  }

  Future<void> _takePhoto() async {
    if (_loading) {
      return;
    }
    await _scanImage(File(await EdgeDetection.detectEdge));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AppBarMenuItem.LoadImage,
                child: Text('写真を読み込む'),
              ),
              PopupMenuItem(
                value: AppBarMenuItem.SignOut,
                child: Text('ログアウト'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case AppBarMenuItem.LoadImage:
                  _loadImage();
                  break;
                case AppBarMenuItem.SignOut:
                  _signOut();
                  break;
                default:
                  break;
              }
            },
          ),
        ],
      ),
      body: _loading ? Stack(
        children: [
          Opacity(
            opacity: 0.3,
            child: const ModalBarrier(
              dismissible: false,
              color: Colors.grey,
            )
          ),
          Center(
            child: CircularProgressIndicator(),
          ),
        ]
      ) : Container(
        child: InBodyHistory(history: _history),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto,
        tooltip: '測定結果を撮影する',
        child: Icon(Icons.photo_camera),
      ),
    );
  }
}
