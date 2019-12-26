import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'GoogleSignInButton.dart';
import 'Env.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

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
                GoogleSignInButton(
                  onPressed: () {
                    setState(() => _loading = true);
                    _handleSignIn()
                      .then((AuthResult result) {
                        if (result.user != null) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      })
                      .catchError((e) => print(e))
                      .whenComplete(() => setState(() => _loading = false));
                  },
                ),
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
