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
    return Scaffold(
      body: Center(
        child: Image.asset('assets/logo.png', width: 96.0),
      ),
    );
  }
}
