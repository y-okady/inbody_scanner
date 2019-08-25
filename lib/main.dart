import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InBody履歴',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'InBody履歴'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;

  Future<File> _pickImage() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  double _findNumeric(String text, List<String> texts, int index) {
    int prevIndex = index - 1;
    if (text.isEmpty) {
      text = texts[prevIndex];
      prevIndex -= 1;
    }
    if (!text.contains(".") || text.startsWith(".")) {
      text = texts[prevIndex] + text;
      prevIndex -= 1;
    }
    return double.tryParse(text) ?? 0.0;
  }

  Future<void> _scanImage(final File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final TextRecognizer textRecognizer = FirebaseVision.instance.cloudTextRecognizer();
    final VisionText visionText = await textRecognizer.processImage(visionImage);
    List<String> texts = [];
    visionText.blocks.forEach((TextBlock block) {
      block.lines.forEach((TextLine line) {
        texts.addAll(line.elements.map((element) => element.text.replaceAll(",", ".").replaceAll("O", "0")));
      });
    });
    textRecognizer.close();
    String date;
    List<double> weights = [];
    List<double> percentages = [];
    double bmi;
    for (int i = 0; i < texts.length; i++) {
      if ((new RegExp("^[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}\$").hasMatch(texts[i]))) {
        if (date == null) {
          date = texts[i];
        }
      } else if (texts[i].endsWith("kg")) {
        double value = _findNumeric(texts[i].replaceAll("kg", ""), texts, i);
        if (value > 0.0) {
          weights.add(value);
        }
      } else if (texts[i].endsWith("%")) {
        double value = _findNumeric(texts[i].replaceAll("%", ""), texts, i);
        if (value > 0.0) {
          percentages.add(value);
        }
      } else if (texts[i].contains("kg/m")) {
        bmi = _findNumeric(texts[i].replaceAll("kg/m2", "").replaceAll("kg/m", ""), texts, i);
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

    // texts.forEach((text) => print(text));
    print("日付: " + date);
    print("体重: " + weights[0].toString() + " kg");
    print("筋肉: " + weights[1].toString() + " kg");
    print("体脂肪: " + weights[2].toString() + " kg");
    print("右腕: " + weights[3].toString() + " kg");
    print("左腕: " + weights[4].toString() + " kg");
    print("胴体: " + weights[5].toString() + " kg");
    print("右脚: " + weights[6].toString() + " kg");
    print("左脚: " + weights[7].toString() + " kg");
    print("BMI: " + bmi.toString() + " kg/m2");
    print("体脂肪率: " + percentages[0].toString() + " %");
    print("発達程度（胴体）: " + percentages[1].toString() + " %");
    print("発達程度（右脚）: " + percentages[2].toString() + " %");
    print("発達程度（左脚）: " + percentages[3].toString() + " %");
    // print(weights.join(", "));
    // print(percentages.join(", "));
  }

  Future<void> _loadImage() async {
    final File image = await _pickImage();
    if (image == null) {
      return;
    }
    setState(() {
      _image = image;
    });
    _scanImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null ? Container(
              height: 200.0,
              width: 200.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(_image),
                  fit: BoxFit.cover,
                )
              ),
            ) : Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadImage,
        tooltip: '画像を読み込む',
        child: Icon(Icons.add),
      ),
    );
  }
}
