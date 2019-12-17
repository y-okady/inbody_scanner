import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'InBodyData.dart';
import 'InBodyForm.dart';
import 'InBodyCharts.dart';
import 'InBodyListScreen.dart';
import 'InBodyScanner.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum AppBarMenuItem {
  LoadImage,
  EditHistory,
  SignOut,
}

class _HomeScreenState extends State<HomeScreen> {
  static const String KEY = 'inBodyData';
  bool _loading = false;
  List<InBodyData> _measurements = List();
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

  void _navigateToEditHistory() =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return InBodyListScreen();
        },
      )
    );

  void _signOut() =>
    FirebaseAuth.instance.signOut()
      .then((_) => Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false));

  Future<CollectionReference> _getMeasurementsCollection() =>
    FirebaseAuth.instance.currentUser()
      .then((user) => Firestore.instance.collection('users').document(user.uid).collection('measurements'));

  Future<void> _addMeasurement(InBodyData data) =>
    _getMeasurementsCollection()
      .then((collection) => collection.document().setData(data.toJson()));

  Future<StreamSubscription<QuerySnapshot>> _subscribeMeasurements() =>
    _getMeasurementsCollection()
      .then((collection) => collection.orderBy('date', descending: true).snapshots().listen((data) {
        setState(() {
          _measurements = data.documents.map((doc) => InBodyData.fromJson(doc.documentID, doc.data)).toList();
        });
      }));

  Future<void> _scanImage(final File image) async {
    setState(() {
      _loading = true;
    });
    InBodyData measurement = await InBodyScanner.scan(image);
    setState(() {
      _loading = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) =>
          InBodyForm(measurement, _addMeasurement),
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
                value: AppBarMenuItem.EditHistory,
                child: Text('データを編集する'),
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
                case AppBarMenuItem.EditHistory:
                  _navigateToEditHistory();
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
        child: InBodyCharts(_measurements),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto,
        tooltip: '測定結果を撮影する',
        child: Icon(Icons.photo_camera),
      ),
    );
  }
}
