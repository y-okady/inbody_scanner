import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'InBodyData.dart';
import 'InBodyForm.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;

  Future<File> _pickImage() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  double _findNumeric(String text, List<String> texts, int index) {
    int prevIndex = index - 1;
    if (text.isEmpty) {
      text = texts[prevIndex];
      prevIndex -= 1;
    }
    if (!text.contains('.') || text.startsWith('.')) {
      text = texts[prevIndex] + text;
      prevIndex -= 1;
    }
    return double.tryParse(text) ?? 0.0;
  }

  Future<InBodyData> _scanImage(final File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final TextRecognizer textRecognizer = FirebaseVision.instance.cloudTextRecognizer();
    final VisionText visionText = await textRecognizer.processImage(visionImage);
    List<String> texts = [];
    visionText.blocks.forEach((TextBlock block) {
      block.lines.forEach((TextLine line) {
        texts.addAll(line.elements.map((element) => element.text.replaceAll(',', '.').replaceAll('O', '0')));
      });
    });
    textRecognizer.close();

    DateTime date;
    double bmi;
    List<double> weights = [];
    List<double> percentages = [];
    for (int i = 0; i < texts.length; i++) {
      if ((new RegExp('^[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}\$').hasMatch(texts[i]))) {
        if (date == null) {
          List<String> substrings = texts[i].split('.');
          date = DateTime(int.parse(substrings[0]), int.parse(substrings[1]), int.parse(substrings[2]));
        }
      } else if (texts[i].endsWith('kg')) {
        double value = _findNumeric(texts[i].replaceAll('kg', ''), texts, i);
        if (value > 0.0) {
          weights.add(value);
        }
      } else if (texts[i].endsWith('%')) {
        double value = _findNumeric(texts[i].replaceAll('%', ''), texts, i);
        if (value > 0.0) {
          percentages.add(value);
        }
      } else if (texts[i].contains('kg/m')) {
        bmi = _findNumeric(texts[i].replaceAll('kg/m2', '').replaceAll('kg/m', ''), texts, i);
      }
    }
    // ヘッダーの体重
    weights.removeAt(0);
    // エクササイズプランの体重
    if (weights[3] == weights[0]) {
      weights.removeAt(3);
    } else if (weights[4] == weights[0]) {
      weights.removeAt(4);
    }

    InBodyData data = InBodyData(date, weights[0], weights[1], weights[2],
      weights[3], weights[4], weights[5], weights[6], weights[7],
      bmi, percentages[0], percentages[1], percentages[2], percentages[3]);

    return data;
  }

  Future<void> _loadImage() async {
    if (_loading) {
      return;
    }
    final File image = await _pickImage();
    if (image == null) {
      return;
    }
    setState(() {
      _loading = true;
    });
    InBodyData data = await _scanImage(image);
    setState(() {
      _loading = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return InBodyForm(data: data);
        },
        fullscreenDialog: true,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
      ) : Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadImage,
        tooltip: '画像を読み込む',
        child: Icon(Icons.add),
      ),
    );
  }
}
