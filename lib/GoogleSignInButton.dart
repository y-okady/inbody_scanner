import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key key, @required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      splashColor: Colors.grey,
      onPressed: this.onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 24.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Googleアカウントでログイン',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}