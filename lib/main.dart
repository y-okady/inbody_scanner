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

class InBodyData {
  String date;
  double bodyWeight;
  double muscleWeight;
  double bodyFatWeight;
  double rightArmWeight;
  double leftArmWeight;
  double trunkWeight;
  double rightLegWeight;
  double leftLegWeight;
  double bmi;
  double bodyFatPercentage;
  double trunkPercentage;
  double rightLegPercentage;
  double leftLegPercentage;

  void dump() {
    print("日付: " + date);
    print("体重: " + bodyWeight.toString() + " kg");
    print("筋肉: " + muscleWeight.toString() + " kg");
    print("体脂肪: " + bodyFatWeight.toString() + " kg");
    print("右腕: " + rightArmWeight.toString() + " kg");
    print("左腕: " + leftArmWeight.toString() + " kg");
    print("胴体: " + trunkWeight.toString() + " kg");
    print("右脚: " + rightLegWeight.toString() + " kg");
    print("左脚: " + leftLegWeight.toString() + " kg");
    print("BMI: " + bmi.toString() + " kg/m2");
    print("体脂肪率: " + bodyFatPercentage.toString() + " %");
    print("発達程度（胴体）: " + trunkPercentage.toString() + " %");
    print("発達程度（右脚）: " + rightLegPercentage.toString() + " %");
    print("発達程度（左脚）: " + leftLegPercentage.toString() + " %");
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

    InBodyData data = InBodyData();
    List<double> weights = [];
    List<double> percentages = [];
    for (int i = 0; i < texts.length; i++) {
      if ((new RegExp('^[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}\$').hasMatch(texts[i]))) {
        if (data.date == null) {
          data.date = texts[i];
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
        data.bmi = _findNumeric(texts[i].replaceAll('kg/m2', '').replaceAll('kg/m', ''), texts, i);
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

    data.bodyWeight = weights[0];
    data.muscleWeight = weights[1];
    data.bodyFatWeight = weights[2];
    data.rightArmWeight = weights[3];
    data.leftArmWeight = weights[4];
    data.trunkWeight = weights[5];
    data.rightLegWeight = weights[6];
    data.leftLegWeight = weights[7];
    data.bodyFatPercentage = percentages[0];
    data.trunkPercentage = percentages[1];
    data.rightLegPercentage = percentages[2];
    data.leftLegPercentage = percentages[3];
    // data.dump();

    return data;
  }

  Future<void> _loadImage() async {
    final File image = await _pickImage();
    if (image == null) {
      return;
    }
    InBodyData data = await _scanImage(image);
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // _image != null ? Container(
            //   height: 200.0,
            //   width: 200.0,
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: FileImage(_image),
            //       fit: BoxFit.cover,
            //     )
            //   ),
            // ) : Container(),
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

class InBodyForm extends StatefulWidget {
  InBodyForm({Key key, this.data}) : super(key: key);

  final InBodyData data;

  @override
  _InBodyFormState createState() => _InBodyFormState();
}

class _InBodyFormState extends State<InBodyForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _dateController;
  TextEditingController _bodyWeightController;
  TextEditingController _muscleWeightController;
  TextEditingController _bodyFatWeightController;
  TextEditingController _rightArmWeightController;
  TextEditingController _leftArmWeightController;
  TextEditingController _trunkWeightController;
  TextEditingController _rightLegWeightController;
  TextEditingController _leftLegWeightController;
  TextEditingController _bmiController;
  TextEditingController _bodyFatPercentageController;
  TextEditingController _trunkPercentageController;
  TextEditingController _rightLegPercentageController;
  TextEditingController _leftLegPercentageController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.data.date);
    _bodyWeightController = TextEditingController(text: widget.data.bodyWeight.toString());
    _muscleWeightController = TextEditingController(text: widget.data.muscleWeight.toString());
    _bodyFatWeightController = TextEditingController(text: widget.data.bodyFatWeight.toString());
    _rightArmWeightController = TextEditingController(text: widget.data.rightArmWeight.toString());
    _leftArmWeightController = TextEditingController(text: widget.data.leftArmWeight.toString());
    _trunkWeightController = TextEditingController(text: widget.data.trunkWeight.toString());
    _rightLegWeightController = TextEditingController(text: widget.data.rightLegWeight.toString());
    _leftLegWeightController = TextEditingController(text: widget.data.leftLegWeight.toString());
    _bmiController = TextEditingController(text: widget.data.bmi.toString());
    _bodyFatPercentageController = TextEditingController(text: widget.data.bodyFatPercentage.toString());
    _trunkPercentageController = TextEditingController(text: widget.data.trunkPercentage.toString());
    _rightLegPercentageController = TextEditingController(text: widget.data.rightLegPercentage.toString());
    _leftLegPercentageController = TextEditingController(text: widget.data.leftLegPercentage.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _bodyWeightController.dispose();
    _muscleWeightController.dispose();
    _bodyFatWeightController.dispose();
    _rightArmWeightController.dispose();
    _leftArmWeightController.dispose();
    _trunkWeightController.dispose();
    _rightLegWeightController.dispose();
    _leftLegWeightController.dispose();
    _bmiController.dispose();
    _bodyFatPercentageController.dispose();
    _trunkPercentageController.dispose();
    _rightLegPercentageController.dispose();
    _leftLegPercentageController.dispose();
  }

  _save() {
    if (_formKey.currentState.validate()) {
      InBodyData data = InBodyData();
      data.date = _dateController.text;
      data.bodyWeight = double.parse(_bodyWeightController.text);
      data.muscleWeight = double.parse(_muscleWeightController.text);
      data.bodyFatWeight = double.parse(_bodyFatWeightController.text);
      data.rightArmWeight = double.parse(_rightArmWeightController.text);
      data.leftArmWeight = double.parse(_leftArmWeightController.text);
      data.trunkWeight = double.parse(_trunkWeightController.text);
      data.rightLegWeight = double.parse(_rightLegWeightController.text);
      data.leftLegWeight = double.parse(_leftLegWeightController.text);
      data.bmi = double.parse(_bmiController.text);
      data.bodyFatPercentage = double.parse(_bodyFatPercentageController.text);
      data.trunkPercentage = double.parse(_trunkPercentageController.text);
      data.rightLegPercentage = double.parse(_rightLegPercentageController.text);
      data.leftLegPercentage = double.parse(_leftLegPercentageController.text);
      // data.dump();
      Navigator.pop(context);
    } else {
      // TODO: error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登録"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: new Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: '日付'),
                    keyboardType: TextInputType.text,
                    controller: _dateController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '体重 (kg)'),
                    keyboardType: TextInputType.text,
                    controller: _bodyWeightController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '筋肉 (kg)'),
                    keyboardType: TextInputType.text,
                    controller: _muscleWeightController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '体脂肪 (kg)'),
                    keyboardType: TextInputType.text,
                    controller: _bodyFatWeightController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '右腕 (kg)'),
                    keyboardType: TextInputType.text,
                    controller: _rightArmWeightController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '左腕 (kg)'),
                    keyboardType: TextInputType.text,
                    controller: _leftArmWeightController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '胴体 (kg)'),
                    keyboardType: TextInputType.text,
                    controller: _trunkWeightController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '右脚 (kg)'),
                    keyboardType: TextInputType.text,
                    controller: _rightLegWeightController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '左脚 (kg)'),
                    keyboardType: TextInputType.text,
                    controller: _leftLegWeightController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'BMI (kg/m2)'),
                    keyboardType: TextInputType.text,
                    controller: _bmiController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '体脂肪率 (%)'),
                    keyboardType: TextInputType.text,
                    controller: _bodyFatPercentageController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '発達程度:胴体 (%)'),
                    keyboardType: TextInputType.text,
                    controller: _trunkPercentageController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '発達程度:右脚 (%)'),
                    keyboardType: TextInputType.text,
                    controller: _rightLegPercentageController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '発達程度:左脚 (%)'),
                    keyboardType: TextInputType.text,
                    controller: _leftLegPercentageController,
                  ),
                  RaisedButton(
                    onPressed: _save,
                    child: Text("登録する"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
