import 'package:cotter/src/handlers/device.dart';
import 'package:cotter/src/handlers/token.dart';
import 'package:cotter/src/helper/colors.dart';
import 'package:cotter/src/models/approveRequestStrings.dart';
import 'package:cotter/src/models/authRequestStrings.dart';
import 'package:cotter/src/models/event.dart';
import 'package:cotter/src/models/user.dart';
import 'package:cotter/src/tokens/cotterAccessToken.dart';
import 'package:cotter/src/tokens/cotterIDToken.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:cotter/src/helper/enum.dart';

class Cotter {
  String apiKeyID;
  static String baseURL = CotterBaseURL;
  static String kid = JwtKID;

  CotterColors colors;
  AuthRequestStrings authRequestStrings = AuthRequestStrings();
  ApproveRequestStrings approveRequestStrings = ApproveRequestStrings();

  Cotter({@required this.apiKeyID}) {
    colors = CotterColors();
  }

  Cotter withTheme({@required Color primaryColor, bool darkTheme = false}) {
    colors = CotterColors(primary: primaryColor, darkTheme: darkTheme);
    return this;
  }

  Cotter withAuthRequestStrings(AuthRequestStrings authRequestStrings) {
    this.authRequestStrings = authRequestStrings;
    return this;
  }

  Cotter withApproveRequestStrings(
      ApproveRequestStrings approveRequestStrings) {
    this.approveRequestStrings = approveRequestStrings;
    return this;
  }

  static set url(String baseURL) {
    Cotter.baseURL = baseURL;
  }

  static set jwtKid(String kid) {
    Cotter.kid = kid;
  }

  Future<User> getUser() {
    return User.getLoggedInUser(cotter: this);
  }

  // ===== Authentication Methods =====

  // Sign up with this device, identifier can be user's email, phone, or any string to identify your user
  Future<User> signUpWithDevice({@required String identifier}) {
    Device device = new Device(apiKeyID: this.apiKeyID);
    return device.signUpWithDevice(identifier: identifier);
  }

  // Sign up with this device, identifier can be user's email, phone, or any string to identify your user
  Future<Event> signInWithDevice({
    @required String identifier,
    @required BuildContext context,
  }) {
    Device device = new Device(apiKeyID: this.apiKeyID);
    return device.signInWithDevice(
      identifier: identifier,
      context: context,
      cotter: this,
    );
  }

  // ===== OAuth Token Handlers =====
  Future<CotterAccessToken> getAccessToken() {
    return Token.getAccessToken(this.apiKeyID);
  }

  Future<CotterIDToken> getIDToken() {
    return Token.getIDToken(this.apiKeyID);
  }

  Future<String> getRefreshToken() {
    return Token.getRefreshToken();
  }

  Future<void> logOut() {
    return Token.logOut();
  }
}
