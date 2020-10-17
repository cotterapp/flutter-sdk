import 'package:cotter/cotter.dart';
import 'package:flutter/material.dart';
import 'package:example/apikeys.dart';
import 'package:example/main.dart';

void main() {
  runApp(Dashboard());
}

class Dashboard extends StatelessWidget {
  static const routeName = '/dashboard';
  Cotter cotter = new Cotter(apiKeyID: API_KEY_ID);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Cotter.url = COTTER_BASE_URL;
    Cotter.jsBaseURL = COTTER_JS_URL;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25)
              .add(EdgeInsets.only(top: 80)),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to the Dashboard",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              UserProfile(
                cotter: cotter,
              ),
              Settings(
                cotter: cotter,
              ),
              OAuthTokens(
                cotter: cotter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfile extends StatefulWidget {
  Cotter cotter;
  UserProfile({this.cotter});
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  User user;
  bool loading = true;
  String error;
  String redirectURL = "pay-merchant-app://auth_callback";

  void resetError() {
    setState(() {
      error = "";
    });
  }

  @override
  void initState() {
    resetError();
    getUser();
    super.initState();
  }

  void getUser() async {
    resetError();
    try {
      var usr = await widget.cotter.getUser();
      setState(() {
        user = usr;
        loading = false;
      });
    } catch (e) {
      loading = false;
      setState(() {
        error = e.toString();
      });
    }
  }

  void verifyEmail() async {
    try {
      user = await user.verifyEmailWithOTP(redirectURL: redirectURL);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  void verifyPhoneViaWhatsApp() async {
    try {
      user = await user.verifyPhoneWithOTPViaWhatsApp(redirectURL: redirectURL);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(loading
              ? "loading..."
              : error != null
                  ? error
                  : ""),
          user != null ? Text("ID: ${user.id}") : Text(""),
          user != null ? Text("Identifier: ${user.identifier}") : Text(""),
          user != null ? Text("Issuer: ${user.issuer}") : Text(""),
          user == null ? Text("User is not logged in") : Text(""),
          Container(
            child: MaterialButton(
              onPressed: () {
                verifyEmail();
              },
              child: Text("Verify Email"),
              color: colors["primary"],
              textColor: Colors.white,
            ),
          ),
          Container(
            child: MaterialButton(
              onPressed: () {
                verifyPhoneViaWhatsApp();
              },
              child: Text("Verify Phone via WhatsApp"),
              color: colors["primary"],
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class OAuthTokens extends StatefulWidget {
  Cotter cotter;
  OAuthTokens({this.cotter});
  @override
  OAuthTokensState createState() => OAuthTokensState();
}

class OAuthTokensState extends State<OAuthTokens> {
  var token;
  var tokenName = "Pick a token to display";
  String error = "";

  void resetError() {
    setState(() {
      error = "";
    });
  }

  void getAccessToken() async {
    resetError();
    try {
      var tok = await widget.cotter.getAccessToken();
      setState(() {
        token = tok;
        tokenName = "Access Token";
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  void getIDToken() async {
    resetError();
    try {
      var tok = await widget.cotter.getIDToken();
      setState(() {
        token = tok;
        tokenName = "ID Token";
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  void getRefreshToken() async {
    resetError();
    try {
      var tok = await widget.cotter.getRefreshToken();
      setState(() {
        token = tok;
        tokenName = "Refresh Token";
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  void logOut() async {
    resetError();
    await widget.cotter.logOut();
    _goToHome();
  }

  void _goToHome() {
    Navigator.popUntil(context, ModalRoute.withName(HomePage.routeName));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "OAuth Tokens",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.left,
            ),
            Text(error),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tokenName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "Token:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  Text(token != null
                      ? tokenName != "Refresh Token"
                          ? token.token
                          : token
                      : ''),
                  Text(
                    "Decoded:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  Text(token != null
                      ? tokenName != "Refresh Token"
                          ? token.payload.toString()
                          : ''
                      : ''),
                  Container(
                    child: MaterialButton(
                      onPressed: () {
                        getAccessToken();
                      },
                      child: Text("Get Access Token"),
                      color: colors["primary"],
                      textColor: Colors.white,
                    ),
                  ),
                  Container(
                    child: MaterialButton(
                      onPressed: () {
                        getIDToken();
                      },
                      child: Text("Get ID Token"),
                      color: colors["primary"],
                      textColor: Colors.white,
                    ),
                  ),
                  Container(
                    child: MaterialButton(
                      onPressed: () {
                        getRefreshToken();
                      },
                      child: Text("Get Refresh Token"),
                      color: colors["primary"],
                      textColor: Colors.white,
                    ),
                  ),
                  Container(
                    child: MaterialButton(
                      onPressed: () {
                        logOut();
                      },
                      child: Text("Log out"),
                      color: colors["primary"],
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ]),
    );
  }
}

class Settings extends StatefulWidget {
  Cotter cotter;
  Settings({this.cotter});
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  User user;
  bool thisDeviceIsTrusted = false;
  String error = "";

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void resetError() {
    setState(() {
      error = "";
    });
  }

  void getUser() async {
    resetError();
    try {
      var usr = await widget.cotter.getUser();
      print(usr);
      var trusted = await usr.isThisDeviceTrusted();
      setState(() {
        user = usr;
        thisDeviceIsTrusted = trusted;
      });
    } catch (e) {
      print(e);
      setState(() {
        error = e.toString();
      });
    }
  }

  checkLoginRequest(BuildContext context) async {
    try {
      Event event = await user.checkNewSignInRequest(context: context);
      print(event);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.left,
            ),
            Text(error),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: thisDeviceIsTrusted
                    ? [
                        Text(
                          "Approve Login Request",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                            "If another device tries to log in, press this button to view the login request and approve or reject it."),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: MaterialButton(
                            onPressed: () {
                              checkLoginRequest(context);
                            },
                            child: Text("Check New Login Request"),
                            color: colors["primary"],
                            textColor: Colors.white,
                          ),
                        ),
                      ]
                    : [
                        Text(
                            "This device is not trusted, but has been granted a temporary login."),
                      ],
              ),
            ),
          ]),
    );
  }
}
