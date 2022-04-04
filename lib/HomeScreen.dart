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
import 'Env.dart';
import 'Measurement.dart';
import 'FormWidget.dart';
import 'DashboardWidget.dart';
import 'Scanner.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum AppBarMenuItem {
  LoadImage,
  EditHistory,
  About,
  SignOut,
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
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

  void _navigateToList() =>
    Navigator.of(context).pushNamed('/list');

  void _navigateToAbout() =>
    Navigator.of(context).pushNamed('/about');

  void _signOut() =>
    FirebaseAuth.instance.signOut()
      .then((_) => Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false));

  CollectionReference _getMeasurementsCollection() =>
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('measurements');

  Future<File> _compressImage(File image) =>
    FlutterImageCompress.compressAndGetFile(image.absolute.path, image.absolute.path, quality: 80, minWidth: 720, minHeight: 480);

  Future<UploadTask> _addImage(String id, File image) =>
      _compressImage(image)
        .then((compressedImage) => FirebaseStorage.instance.ref().child('users/${FirebaseAuth.instance.currentUser.uid}/measurements/$id').putFile(compressedImage));

  Future<void> _scanImage(final File image) {
    setState(() =>_loading = true);
    return Scanner.scan(image)
      .then((measurement) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) =>
              FormWidget(measurement, Image.file(image), (Measurement measurement) =>
                _getMeasurementsCollection().add(measurement.toJson())
                  .then((doc) => _addImage(doc.id, image))
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
    final XFile image = await new ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    await _scanImage(File(image.path)); // TODO
  }

  Future<void> _takePhoto() async {
    if (_loading) {
      return;
    }
    final String path = await EdgeDetection.detectEdge;
    if (path == null) {
      return;
    }
    await _scanImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(Env.APP_NAME),
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
                value: AppBarMenuItem.About,
                child: Text('このアプリについて'),
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
                case AppBarMenuItem.About:
                  _navigateToAbout();
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
