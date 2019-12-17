
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'InBodyData.dart';

class InBodyScanner {
  static Future<InBodyData> scan(final File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final TextRecognizer textRecognizer = FirebaseVision.instance.cloudTextRecognizer();
    final VisionText visionText = await textRecognizer.processImage(visionImage);
    String text = '';
    visionText.blocks.forEach((TextBlock block) {
      block.lines.forEach((TextLine line) {
        text += line.text.replaceAll(',', '.').replaceAll('O', '0') + ' ';
      });
    });
    textRecognizer.close();

    List<String> texts = text.split(' ');
    DateTime date;
    double bmi = 0;
    List<double> weights = [];
    List<double> percentages = [];
    for (int i = 0; i < texts.length; i++) {
      if ((new RegExp('^[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}\$').hasMatch(texts[i]))) {
        if (date == null) {
          List<String> substrings = texts[i].split('.');
          try {
            date = DateTime(int.parse(substrings[0]), int.parse(substrings[1]), int.parse(substrings[2]));
          } catch (e) {
            print(e);
          }
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

  static double _findNumeric(String text, List<String> texts, int index) {
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
}