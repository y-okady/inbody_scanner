import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'Env.dart';
import 'ListScreen.dart';
import 'SplashScreen.dart';
import 'LoginScreen.dart';
import 'HomeScreen.dart';

void main() {
  Env.load().then((_) {
    SyncfusionLicense.registerLicense(Env.getSyncfusionLicenseKey());
    Admob.initialize(Env.getAdMobAppId());
    runApp(MyApp());
  });
}

const String TITLE = 'InBody Scanner';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TITLE,
      theme: ThemeData(
        primarySwatch: Colors.teal,
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
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(TITLE),
        '/login': (context) => LoginScreen(TITLE),
        '/home': (context) => HomeScreen(TITLE),
        '/list': (context) => ListScreen(),
      },
    );
  }
}
