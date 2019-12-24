import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<dynamic> load() =>
    DotEnv().load('.env');

  static String getAdMobAppId() =>
    DotEnv().env['ADMOB_APP_ID_${Platform.isIOS ? "IOS" : "ANDROID"}'];

  static String getAdMobUnitId() =>
    DotEnv().env['ADMOB_UNIT_ID_${Platform.isIOS ? "IOS" : "ANDROID"}'];

  static String getSyncfusionLicenseKey() =>
    DotEnv().env['SYNCFUSION_LICENSE_KEY'];
}
