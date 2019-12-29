import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'AboutScreen.dart';
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Env.APP_NAME,
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
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/list': (context) => ListScreen(),
        '/about': (context) => AboutScreen(),
      },
      // debugShowCheckedModeBanner: false,
    );
  }
}
