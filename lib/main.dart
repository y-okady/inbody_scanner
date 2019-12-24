import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'ListScreen.dart';
import 'SplashScreen.dart';
import 'LoginScreen.dart';
import 'HomeScreen.dart';

void main() async {
  await DotEnv().load('.env');
  SyncfusionLicense.registerLicense(DotEnv().env['SYNCFUSION_LICENSE_KEY']);
  runApp(MyApp());
}

const String TITLE = 'InBody Scanner for ルネサンス';

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
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(title: TITLE),
        '/list': (context) => ListScreen(),
      },
    );
  }
}
