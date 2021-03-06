import 'package:example/dashboard.dart';
import 'package:example/register.dart';
import 'package:example/registerWithEmailVerification.dart';
import 'package:example/registerWithPhoneVerification.dart';
import 'package:flutter/material.dart';

var colors = {
  "light": Color(0xFFF3F3F3),
  "primary": Color(0xFF8650fa),
  "error": Color(0xFFF4416E),
};

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotter Example App',
      theme: ThemeData(
        primaryColor: colors["primary"],
      ),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        // '/': (context) => HomePage(),
        '/': (context) => HomePage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        Dashboard.routeName: (context) => Dashboard(),
        Register.routeName: (context) => Register(),
        RegisterWithEmailVerification.routeName: (context) =>
            RegisterWithEmailVerification(),
        RegisterWithPhoneVerification.routeName: (context) =>
            RegisterWithPhoneVerification(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  static String routeName = '/';

  @override
  Widget build(BuildContext context) {
    void _goToRegister() {
      Navigator.pushNamed(context, Register.routeName);
    }

    void _goToRegisterWithEmailVerification() {
      Navigator.pushNamed(context, RegisterWithEmailVerification.routeName);
    }

    void _goToRegisterWithPhoneVerification() {
      Navigator.pushNamed(context, RegisterWithPhoneVerification.routeName);
    }

    void _goToDashboard() {
      Navigator.pushNamed(context, Dashboard.routeName);
    }

    return Scaffold(
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16)
              .add(EdgeInsets.only(top: 80)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        "🐱",
                        style: TextStyle(fontSize: 40),
                      ),
                      Text(
                        "Welcome to Cotter Example App",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    ButtonTheme(
                      minWidth: double.infinity,
                      child: MaterialButton(
                        onPressed: () {
                          _goToRegister();
                        },
                        child: Text("Sign Up With Device"),
                        color: colors["primary"],
                        textColor: Colors.white,
                      ),
                    ),
                    ButtonTheme(
                      minWidth: double.infinity,
                      child: MaterialButton(
                        onPressed: () {
                          _goToRegisterWithEmailVerification();
                        },
                        child: Text("Sign Up With Email"),
                        color: colors["primary"],
                        textColor: Colors.white,
                      ),
                    ),
                    ButtonTheme(
                      minWidth: double.infinity,
                      child: MaterialButton(
                        onPressed: () {
                          _goToRegisterWithPhoneVerification();
                        },
                        child: Text("Sign Up With Phone"),
                        color: colors["primary"],
                        textColor: Colors.white,
                      ),
                    ),
                    ButtonTheme(
                      minWidth: double.infinity,
                      child: OutlineButton(
                        onPressed: () {
                          _goToDashboard();
                        },
                        child: Text("Go To Dashboard"),
                        color: colors["primary"],
                        textColor: colors["primary"],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
