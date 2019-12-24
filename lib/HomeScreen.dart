import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'Measurement.dart';
import 'FormWidget.dart';
import 'DashboardWidget.dart';
import 'Scanner.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(this.title, {Key key}) : super(key: key);

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
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

  void _navigateToList() =>
    Navigator.of(context).pushNamed('/list');

  void _signOut() =>
    FirebaseAuth.instance.signOut()
      .then((_) => Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false));

  Future<CollectionReference> _getMeasurementsCollection() =>
    FirebaseAuth.instance.currentUser()
      .then((user) => Firestore.instance.collection('users').document(user.uid).collection('measurements'));

  Future<DocumentReference> _addMeasurement(Measurement measurement) =>
    _getMeasurementsCollection()
      .then((collection) => collection.document())
      .then((doc) => doc.setData(measurement.toJson()).then((_) => doc));

  Future<File> _compressImage(File image) =>
    FlutterImageCompress.compressAndGetFile(image.absolute.path, image.absolute.path, quality: 80, minWidth: 720, minHeight: 480);

  Future<StorageUploadTask> _addImage(String id, File image) =>
    FirebaseAuth.instance.currentUser()
      .then((user) => _compressImage(image)
        .then((compressedImage) => FirebaseStorage.instance.ref().child('users/${user.uid}/measurements/$id').putFile(compressedImage)));

  Future<StreamSubscription<QuerySnapshot>> _subscribeMeasurements() =>
    _getMeasurementsCollection()
      .then((collection) => collection.orderBy('date', descending: true).snapshots().listen((data) {
        setState(() {
          _measurements = data.documents.map((doc) => Measurement.fromJson(doc.documentID, doc.data)).toList();
        });
      }));

  Future<void> _scanImage(final File image) {
    setState(() =>_loading = true);
    return Scanner.scan(image)
      .then((measurement) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) =>
              FormWidget(measurement, Image.file(image), (Measurement measurement) =>
                _addMeasurement(measurement)
                  .then((doc) => _addImage(doc.documentID, image))
                  .then((_) => _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('${DateFormat('y/M/d').format(measurement.date)} の測定結果を登録しました！'),
                  ))
              )),
            fullscreenDialog: true,
          )
        );
      })
      .whenComplete(() => setState(() =>_loading = false));
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
      key: _scaffoldKey,
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
                  _navigateToList();
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
      body: Stack(
        children: [
          DashboardWidget(_measurements),
          _loading ? Stack(
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
            ],
          ) : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto,
        tooltip: '測定結果を撮影する',
        child: Icon(Icons.photo_camera),
      ),
    );
  }
}
