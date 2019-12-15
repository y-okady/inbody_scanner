import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'HomeScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InBody Scanner for ルネサンス',
      theme: ThemeData(
        primarySwatch: Colors.pink,
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
      home: HomeScreen(),
    );
  }
}
