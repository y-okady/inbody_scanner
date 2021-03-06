import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key key, @required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.white,
      textColor: Colors.black,
      onPressed: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: AssetImage("assets/google_logo.png"),
            width: 16.0
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
          ),
          Text('Googleアカウントでログイン',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]
      )
    );
  }
}