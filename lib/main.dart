import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InBody履歴',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('ja'),
      ],
      home: MyHomePage(title: 'InBody履歴'),
    );
  }
}

class InBodyData {
  DateTime date;
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
    print("日付: " + date.toString());
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

    InBodyData data = InBodyData();
    List<double> weights = [];
    List<double> percentages = [];
    for (int i = 0; i < texts.length; i++) {
      if ((new RegExp('^[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}\$').hasMatch(texts[i]))) {
        if (data.date == null) {
          List<String> substrings = texts[i].split('.');
          data.date = DateTime(int.parse(substrings[0]), int.parse(substrings[1]), int.parse(substrings[2]));
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

class InBodyForm extends StatefulWidget {
  InBodyForm({Key key, this.data}) : super(key: key);

  final InBodyData data;

  @override
  _InBodyFormState createState() => _InBodyFormState();
}

class _InBodyFormState extends State<InBodyForm> {
  final _formKey = GlobalKey<FormState>();

  _save() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    // widget.data.dump();
    _formKey.currentState.save();
    Navigator.pop(context);
  }

  String _requiredDoubleValueValidator(String value) {
    if (value.isEmpty) {
      return '必須です';
    }
    try {
      double.parse(value);
    } on FormatException {
      return '数値を入力してください';
    }
    return null;
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
                  DateTimeField(
                    decoration: InputDecoration(labelText: '日付'),
                    format: DateFormat("yyyy-MM-dd"),
                    initialValue: widget.data.date,
                    onShowPicker: (context, currentValue) => showDatePicker(
                      context: context,
                      locale: const Locale('ja'),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                      initialDate: currentValue ?? widget.data.date,
                    ),
                    onSaved: (date) => widget.data.date = date,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '体重 (kg)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.bodyWeight.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.bodyWeight = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '筋肉 (kg)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.muscleWeight.toString(),
                    onSaved: (text) => widget.data.muscleWeight = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '体脂肪 (kg)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.bodyFatWeight.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.bodyFatWeight = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '右腕 (kg)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.rightArmWeight.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.rightArmWeight = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '左腕 (kg)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.leftArmWeight.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.leftArmWeight = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '胴体 (kg)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.trunkWeight.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.trunkWeight = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '右脚 (kg)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.rightLegWeight.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.rightLegWeight = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '左脚 (kg)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.leftLegWeight.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.leftLegWeight = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'BMI (kg/m2)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.bmi.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.bmi= double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '体脂肪率 (%)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.bodyFatPercentage.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.bodyFatPercentage = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '発達程度:胴体 (%)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.trunkPercentage.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.trunkPercentage = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '発達程度:右脚 (%)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.rightLegPercentage.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.rightLegPercentage = double.parse(text),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '発達程度:左脚 (%)'),
                    keyboardType: TextInputType.text,
                    initialValue: widget.data.leftLegPercentage.toString(),
                    validator: _requiredDoubleValueValidator,
                    onSaved: (text) => widget.data.leftLegPercentage = double.parse(text),
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
