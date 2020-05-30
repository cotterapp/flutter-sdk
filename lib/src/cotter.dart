import 'package:cotter/src/handlers/verify.dart';
import 'package:cotter/src/helper/colors.dart';
import 'package:cotter/src/models/verifyStrings.dart';
import 'package:cotter/src/screens/emailInputScreen.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:cotter/src/helper/enum.dart';

class Cotter {
  String apiKeyID;
  static String baseURL = CotterBaseURL;

  CotterColors colors;
  VerifyStrings signInWithEmailUIStrings = VerifyStrings();

  Cotter({@required this.apiKeyID}) {
    colors = CotterColors();
  }

  setTheme({@required Color primaryColor, bool darkTheme = false}) {
    colors = CotterColors(primary: primaryColor, darkTheme: darkTheme);
  }

  Future<bool> sendEmailWithCode({@required String email}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.sendCode(identifier: email, identifierType: EmailType);
  }

  Future<Map<String, dynamic>> signInWithEmail(
      {@required String email, String code}) async {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return await verify.verifyCode(identifier: email, code: code);
  }

  static set url(String baseURL) {
    Cotter.baseURL = baseURL;
  }

  signInWithEmailUI({
    @required BuildContext context,
    @required Function onSuccess,
    @required Function onError,
    VerifyStrings strings,
  }) {
    this.signInWithEmailUIStrings = strings;
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return EmailInputScreen(
        onSuccess: onSuccess,
        onError: onError,
        cotter: this,
      );
    }));
  }
}
