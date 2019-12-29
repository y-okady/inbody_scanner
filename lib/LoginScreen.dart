import 'dart:io';
import 'package:apple_sign_in/apple_id_request.dart';
import 'package:apple_sign_in/apple_sign_in.dart' as asi;
import 'package:apple_sign_in/scope.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'GoogleSignInButton.dart';
import 'AppleSignInButton.dart';
import 'Env.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<AuthResult> _handleGoogleSignIn() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<AuthResult> _handleAppleSignIn() async {
    final asi.AuthorizationResult result = await asi.AppleSignIn.performRequests([
      AppleIdRequest(
        requestedScopes: [Scope.email, Scope.fullName],
      ),
    ]);
    if (result.status == asi.AuthorizationStatus.error) {
      throw 'Apple sign in failed: ${result.error.localizedFailureReason ?? ''} ${result.error.localizedDescription ?? ''}';
    }
    if (result.status == asi.AuthorizationStatus.cancelled) {
      throw 'Apple sign in cancelled';
    }
    final AuthCredential credential = OAuthProvider(providerId: "apple.com").getCredential(
      accessToken: String.fromCharCodes(result.credential.authorizationCode),
      idToken: String.fromCharCodes(result.credential.identityToken),
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    Text('スポーツクラブ ルネサンスで',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text('InBody 測定をして、',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text('結果をカメラで読み取ろう。',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Image.asset('assets/guide.png', width: MediaQuery.of(context).size.width - 64),
                Column(
                  children: [
                    Text('${Env.APP_NAME} があなたの',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text('理想の体づくりをサポートします。',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(12),
                ),
                Container(
                  width: 280,
                  height: 40,
                  margin: EdgeInsets.all(4),
                  child: GoogleSignInButton(
                    onPressed: () {
                      setState(() => _loading = true);
                      _handleGoogleSignIn()
                        .then((AuthResult result) {
                          if (result.user != null) {
                            Navigator.of(context).pushReplacementNamed('/home');
                          }
                        })
                        .catchError((e) => print(e))
                        .whenComplete(() => setState(() => _loading = false));
                    },
                  ),
                ),
                Platform.isIOS ? Container(
                  width: 280,
                  height: 40,
                  margin: EdgeInsets.all(4),
                  child: AppleSignInButton(
                    onPressed: () {
                      setState(() => _loading = true);
                      _handleAppleSignIn()
                        .then((AuthResult result) {
                          if (result.user != null) {
                            Navigator.of(context).pushReplacementNamed('/home');
                          }
                        })
                        .catchError((e) => print(e))
                        .whenComplete(() => setState(() => _loading = false));
                    },
                  ),
                ) : Container(),
              ],
            ),
          ),
          _loading ? Stack(
            children: [
              Opacity(
                opacity: 0.3,
                child: const ModalBarrier(
                  dismissible: false,
                  color: Colors.grey,
                )
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ) : Container(),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
