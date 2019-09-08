
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'InBodyData.dart';

class InBodyForm extends StatefulWidget {
  InBodyForm({Key key, this.data, this.onSubmit}) : super(key: key);

  final InBodyData data;
  final Function onSubmit;

  @override
  _InBodyFormState createState() => _InBodyFormState();
}

class _InBodyFormState extends State<InBodyForm> {
  final _formKey = GlobalKey<FormState>();

  _save() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    widget.onSubmit(widget.data);
    Navigator.pop(context);
  }

  _cancel() {
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
                    decoration: InputDecoration(labelText: 'BMI (kg/㎡)'),
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
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.blue,
                          child: Text(
                            '登録',
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                          onPressed: _save,
                        ),
                        FlatButton(
                          child: Text('キャンセル'),
                          onPressed: _cancel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
