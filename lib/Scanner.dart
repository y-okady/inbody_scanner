
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'Measurement.dart';

class Scanner {
  static Future<Measurement> scan(final File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final TextRecognizer textRecognizer = FirebaseVision.instance.cloudTextRecognizer();
    final VisionText visionText = await textRecognizer.processImage(visionImage);
    String text = '';
    visionText.blocks.forEach((TextBlock block) {
      block.lines.forEach((TextLine line) {
        text += line.text
          .replaceAll(',', '.')
          .replaceAll('O', '0')
          .replaceAll('I', '1')
          .replaceAll('l', '1')
          + ' ';
      });
    });
    textRecognizer.close();

    List<String> texts = text.split(' ');
    DateTime date;
    double bmi = 0;
    List<double> weights = [];
    List<double> percentages = [];
    for (int i = 0; i < texts.length; i++) {
      if (RegExp('^20[0-9]{2}\.').hasMatch(texts[i])) {
        String dateStr = texts[i];
        if (dateStr.endsWith('.')) { // 2019. or 2019.12
          dateStr += texts[++i];
        }
        if (dateStr.endsWith('.')) { // 2019.12
          dateStr += texts[++i];
        }
        List<String> substrings = dateStr.split('.');
        try {
          date = DateTime(int.parse(substrings[0]), int.parse(substrings[1]), int.parse(substrings[2]));
        } catch (e) {
          print(e);
        }
      } else if (texts[i].contains('kg/m')) {
        bmi = _findNumeric(texts[i].substring(0, texts[i].indexOf('kg/m')), texts, i);
      } else if (texts[i].endsWith('kg')) {
        double value = _findNumeric(texts[i].substring(0, texts[i].indexOf('kg')), texts, i);
        if (value > 0.0) {
          weights.add(value);
        }
      } else if (texts[i].endsWith('%')) {
        double value = _findNumeric(texts[i].substring(0, texts[i].indexOf('%')), texts, i);
        if (value > 0.0) {
          percentages.add(value);
        }
      }
    }
    if (weights.length == 0) {
      return Measurement();
    }

    Measurement measurement = Measurement(
      date: date,
      bodyWeight: weights[0],
      muscleWeight: weights[2],
      bodyFatWeight: weights[3],
      rightArmWeight: weights[4],
      leftArmWeight: weights[5],
      trunkWeight: weights[6],
      rightLegWeight: weights[7],
      leftLegWeight: weights[8],
      bmi: bmi,
      bodyFatPercentage: percentages[0],
      trunkPercentage: percentages[1],
      rightLegPercentage: percentages[2],
      leftLegPercentage: percentages[3]);

    return measurement;
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
    return double.tryParse(RegExp('([0-9]+\.[0-9]+)').firstMatch(text)?.group(0) ?? '') ?? 0.0;
  }
}