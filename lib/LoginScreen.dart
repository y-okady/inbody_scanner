import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:inbody_scanner/GoogleSignInButton.dart';

class LoginScreen extends StatelessWidget {
  Future<AuthResult> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GoogleSignInButton(
              onPressed: () {
                _handleSignIn()
                  .then((AuthResult result) {
                    if (result.user != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  })
                  .catchError((e) => print(e));
              },
            ),
          ],
        ),
      ),
    );
  }
}
