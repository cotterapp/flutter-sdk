import 'package:cotter/cotter.dart';
import 'package:cotter/src/models/authRequestStrings.dart';
import 'package:flutter/material.dart';

class AuthRequest extends StatefulWidget {
  final Cotter cotter;
  AuthRequest({
    required this.cotter,
  }) {
    // strings = cotter.signInWithEmailUIStrings;
  }
  @override
  AuthRequestState createState() => AuthRequestState();
}

class AuthRequestState extends State<AuthRequest> {
  @override
  Widget build(BuildContext context) {
    AuthRequestStrings strings = widget.cotter.authRequestStrings;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      height: 300,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.centerLeft,
            child: Text(
              strings.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.centerLeft,
            child: Text(
              strings.subtitle,
              style: TextStyle(
                color: widget.cotter.colors.grey,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Image(
              image: AssetImage(
                strings.imagePath,
                package: 'cotter',
              ),
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }
}
