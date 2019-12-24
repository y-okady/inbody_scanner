import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), _navigateToTop);
  }

  void _navigateToTop() {
    FirebaseAuth.instance.currentUser().then((user) {
      Navigator.of(context).pushReplacementNamed(user == null ? '/login' : '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Image.asset('assets/icon.png', width: (width < height ? width : height) / 2),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
