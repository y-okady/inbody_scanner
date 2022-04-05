import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static const APP_NAME = 'InBody Scanner';

  static Future<dynamic> load() => dotenv.load(fileName: '.env');

  static String getAdMobAppId() =>
      dotenv.env['ADMOB_APP_ID_${Platform.isIOS ? "IOS" : "ANDROID"}'];

  static String getAdMobUnitId() =>
      dotenv.env['ADMOB_UNIT_ID_${Platform.isIOS ? "IOS" : "ANDROID"}'];
}
