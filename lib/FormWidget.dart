import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'Measurement.dart';

class FormWidget extends StatefulWidget {
  FormWidget(this.measurement, this.image, this.onSubmit, {Key key}) : super(key: key);

  final Measurement measurement;
  final Image image;
  final Function onSubmit;

  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();

  _save() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    widget.onSubmit(widget.measurement)
      .then((_) => Navigator.of(context).pop());
  }

  _cancel() {
    Navigator.of(context).pop();
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
    final String mode = widget.measurement.id == null ? '登録' : '変更';
    return Scaffold(
      appBar: AppBar(
        title: Text(mode),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8.0),
          child: Column(
            children: [
              widget.image,
              Form(
                key: _formKey,
                child: new Column(
                  children: [
                    DateTimeField(
                      decoration: InputDecoration(labelText: '日付'),
                      format: DateFormat('y/M/d'),
                      initialValue: widget.measurement.date,
                      onShowPicker: (context, currentValue) => showDatePicker(
                        context: context,
                        locale: const Locale('ja'),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        initialDate: currentValue ?? DateTime.now(),
                      ),
                      onSaved: (date) => widget.measurement.date = date,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '体重 (kg)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.bodyWeight.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.bodyWeight = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '筋肉 (kg)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.muscleWeight.toString(),
                      onSaved: (text) => widget.measurement.muscleWeight = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '体脂肪 (kg)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.bodyFatWeight.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.bodyFatWeight = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '右腕の筋肉 (kg)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.rightArmWeight.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.rightArmWeight = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '左腕の筋肉 (kg)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.leftArmWeight.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.leftArmWeight = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '胴体の筋肉 (kg)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.trunkWeight.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.trunkWeight = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '右脚の筋肉 (kg)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.rightLegWeight.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.rightLegWeight = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '左脚の筋肉 (kg)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.leftLegWeight.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.leftLegWeight = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'BMI (kg/m²)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.bmi.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.bmi= double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '体脂肪率 (%)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.bodyFatPercentage.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.bodyFatPercentage = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '胴体の筋肉発達程度 (%)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.trunkPercentage.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.trunkPercentage = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '右脚の筋肉発達程度 (%)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.rightLegPercentage.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.rightLegPercentage = double.parse(text),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '左脚の筋肉発達程度 (%)'),
                      keyboardType: TextInputType.text,
                      initialValue: widget.measurement.leftLegPercentage.toString(),
                      validator: _requiredDoubleValueValidator,
                      onSaved: (text) => widget.measurement.leftLegPercentage = double.parse(text),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            color: Colors.blue,
                            child: Text(
                              mode,
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
            ],
          ),
        ),
      ),
    );
  }
}
