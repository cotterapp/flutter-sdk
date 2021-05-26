import 'package:cotter/cotter.dart';
import 'package:flutter/material.dart';
import 'package:example/apikeys.dart';
import 'package:example/dashboard.dart';
import 'package:example/main.dart';

void main() {
  runApp(RegisterWithPhoneVerification());
}

class RegisterWithPhoneVerification extends StatelessWidget {
  static const routeName = '/register_with_phone_verification';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25)
            .add(EdgeInsets.only(top: 80)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.bottomLeft,
              child: Text(
                "Verify user's phone number. If successful, create a user and trust this device.",
                style: TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
            ),
            InputForm(),
          ],
        ),
      ),
    );
  }
}

class InputForm extends StatefulWidget {
  @override
  InputFormState createState() => InputFormState();
}

class InputFormState extends State<InputForm> {
  final _formKey = GlobalKey<FormState>();
  var pubKey = "nothing";

  final inputController = TextEditingController();

  Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);

  void _goToDashboard() {
    Navigator.pushNamed(context, Dashboard.routeName);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Cotter.url = COTTER_BASE_URL;
    Cotter.jsBaseURL = COTTER_JS_URL;
    super.initState();
  }

  void signUp(String channel) async {
    try {
      User user;
      if (channel == "SMS") {
        user = await cotter.signUpWithPhoneOTPViaSMS(
          redirectURL: "myexample://auth_callback",
          phone: inputController.text,
        );
      } else {
        user = await cotter.signUpWithPhoneOTPViaWhatsApp(
          redirectURL: "myexample://auth_callback",
          phone: inputController.text,
        );
      }
      user = await user.registerDevice();
      _goToDashboard();
    } catch (e) {
      showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error Registering User'),
              content: Text(e.toString()),
            );
          });
      print(e);
    }
  }

  void signInWithPhone(String channel) async {
    try {
      if (channel == "SMS") {
        await cotter.signInWithPhoneOTPViaSMS(
          redirectURL: "myexample://auth_callback",
          phone: inputController.text,
        );
      } else {
        await cotter.signInWithPhoneOTPViaWhatsApp(
          redirectURL: "myexample://auth_callback",
          phone: inputController.text,
        );
      }
      _goToDashboard();
    } catch (e) {
      showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error signing in with Phone'),
              content: Text(e.toString()),
            );
          });
      print(e);
    }
  }

  void signInWithDevice(BuildContext context) async {
    // await hello(context);
    try {
      var event = await cotter.signInWithDevice(
        identifier: inputController.text,
        context: context,
      );
      print("RESULT EVENT");
      print(event);
      if (event.approved!) {
        _goToDashboard();
      }
    } catch (e) {
      showDialog<void>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error signing in with device'),
              content: Text(e.toString()),
            );
          });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Cotter.url = COTTER_BASE_URL;
    Cotter.jsBaseURL = COTTER_JS_URL;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Form(
            key: _formKey,
            child: TextField(
              decoration: InputDecoration(
                labelText: "Phone",
              ),
              controller: inputController,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                ButtonTheme(
                  minWidth: double.infinity,
                  child: MaterialButton(
                    onPressed: () {
                      signUp("SMS");
                    },
                    child: Text("Sign Up via SMS"),
                    color: colors["primary"],
                    textColor: Colors.white,
                  ),
                ),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: MaterialButton(
                    onPressed: () {
                      signUp("WHATSAPP");
                    },
                    child: Text("Sign Up via WhatsApp"),
                    color: colors["primary"],
                    textColor: Colors.white,
                  ),
                ),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: MaterialButton(
                    onPressed: () {
                      signInWithPhone("SMS");
                    },
                    child: Text("Sign In via SMS"),
                    color: Colors.white,
                    textColor: colors["primary"],
                  ),
                ),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: MaterialButton(
                    onPressed: () {
                      signInWithDevice(context);
                    },
                    child: Text("Sign In With Device"),
                    color: Colors.white,
                    textColor: colors["primary"],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
