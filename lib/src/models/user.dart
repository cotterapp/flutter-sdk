import 'dart:convert';

import 'package:cotter/cotter.dart';
import 'package:cotter/src/exceptions/user.dart';
import 'package:cotter/src/handlers/device.dart';
import 'package:cotter/src/handlers/token.dart';
import 'package:cotter/src/handlers/verify.dart';
import 'package:cotter/src/helper/enum.dart';
import 'package:cotter/src/helper/storage.dart';
import 'package:flutter/material.dart';

class User {
  String id;
  String issuer;
  String clientUserID;
  List<dynamic> enrolled;
  String identifier;
  Cotter cotter;

  User({
    this.id,
    this.issuer,
    this.clientUserID,
    this.enrolled,
    this.identifier,
  });

  User withCotter(Cotter cotter) {
    this.cotter = cotter;
    return this;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['ID'],
      issuer: json['issuer'],
      clientUserID: json['client_user_id'],
      enrolled: json['enrolled'],
      identifier: json['identifier'],
    );
  }

  Map<String, dynamic> toJson() => {
        "ID": this.id,
        "issuer": this.issuer,
        "client_user_id": this.clientUserID,
        "enrolled": this.enrolled,
        "identifier": this.identifier,
      };

  String toString() => jsonEncode(this.toJson());

  Future<void> store() async {
    await Storage.write(key: LOGGED_IN_USER_KEY, value: this.toString());
  }

  static Future<void> logOut() async {
    await Storage.delete(key: LOGGED_IN_USER_KEY);
  }

  static Future<User> getLoggedInUser({Cotter cotter}) async {
    var userStr = await Storage.read(key: LOGGED_IN_USER_KEY);
    if (userStr == null) {
      throw UserNotLoggedInException;
    }
    var user = User.fromJson(json.decode(userStr));
    user.cotter = cotter;
    // if this fails, then the user is not logged-in
    // or the refresh token failed to refresh
    await Token.getIDToken(user.issuer);
    return user;
  }

  // ========= Authentication Methods: Device Based ==========

  // Sign up with this device, identifier can be user's email, phone, or any string to identify your user
  Future<User> registerDevice() {
    Device device = new Device(apiKeyID: this.issuer);
    return device.registerDevice(user: this);
  }

  Future<Event> checkNewSignInRequest({@required BuildContext context}) {
    Device device = new Device(apiKeyID: this.issuer);
    if (this.cotter == null) {
      throw "Cotter is not specified, either call `user = await cotter.getUser(); user.checkNewSignInRequest(context)` or `user.WithCotter(cotter).checkNewSignInRequest(context)`. This allows you to pass strings and colors into the Cotter object to be used in the approve sign in modal.";
    }
    return device.checkNewSignInRequest(
        context: context, cotterUserID: this.id, cotter: this.cotter);
  }

  Future<bool> isThisDeviceTrusted() async {
    Device device = new Device(apiKeyID: this.issuer);
    return await device.isThisDeviceTrusted(cotterUserID: this.id);
  }

  // ========= Authentication Methods: Email / Phone Based ==========

  /// Verify user email with OTP.
  Future<User> verifyEmailWithOTP({@required String redirectURL}) {
    Verify verify = new Verify(apiKeyID: this.issuer);
    return verify.verifyEmail(redirectURL: redirectURL, email: this.identifier);
  }

  /// Verify user email with OTP via text messages (SMS).
  Future<User> verifyPhoneWithOTPViaSMS({@required String redirectURL}) {
    Verify verify = new Verify(apiKeyID: this.issuer);
    return verify.verifyPhone(
      redirectURL: redirectURL,
      phone: this.identifier,
      channel: PhoneChannel.SMS,
    );
  }

  /// Verify user email with OTP via text messages (WhatsApp).
  Future<User> verifyPhoneWithOTPViaWhatsApp({@required String redirectURL}) {
    Verify verify = new Verify(apiKeyID: this.issuer);
    return verify.verifyPhone(
      redirectURL: redirectURL,
      phone: this.identifier,
      channel: PhoneChannel.WHATSAPP,
    );
  }
}
