import 'package:cotter/src/api.dart';
import 'package:cotter/src/handlers/device.dart';
import 'package:cotter/src/handlers/token.dart';
import 'package:cotter/src/handlers/verify.dart';
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
  static String jsBaseURL = CotterJSBaseURL;
  static String kid = JwtKID;

  late CotterColors colors;
  AuthRequestStrings authRequestStrings = AuthRequestStrings();
  ApproveRequestStrings approveRequestStrings = ApproveRequestStrings();

  /// Initialize Cotter with specified API Key ID.
  Cotter({required this.apiKeyID}) {
    colors = CotterColors();
  }

  /// Sets Color theme
  Cotter withTheme({required Color primaryColor, bool darkTheme = false}) {
    colors = CotterColors(primary: primaryColor, darkTheme: darkTheme);
    return this;
  }

  /// Localization setting for authentication requests on trusted device
  Cotter withAuthRequestStrings(AuthRequestStrings authRequestStrings) {
    this.authRequestStrings = authRequestStrings;
    return this;
  }

  /// Localization setting for approval request on trusted device
  Cotter withApproveRequestStrings(
      ApproveRequestStrings approveRequestStrings) {
    this.approveRequestStrings = approveRequestStrings;
    return this;
  }

  /// Sets base url for Cotter's SDK
  static set url(String baseURL) {
    Cotter.baseURL = baseURL;
  }

  static set jwtKid(String kid) {
    Cotter.kid = kid;
  }

  /// Returns currently logged in user
  Future<User> getUser() {
    return User.getLoggedInUser(cotter: this);
  }

  /// Fetches user from Cotter using a specific identifier(email or phone num)
  Future<User> getUserByIdentifier(String identifier) async {
    API api = new API(apiKeyID: this.apiKeyID);
    User user = await api.getUserByIdentifier(identifier);
    return user;
  }

  // ===== Authentication Methods: Device Based =====

  /// Sign up with this device, identifier can be user's email, phone, or any string to identify your user
  Future<User> signUpWithDevice({required String identifier}) {
    Device device = new Device(apiKeyID: this.apiKeyID);
    return device.signUpWithDevice(identifier: identifier);
  }

  /// Sign up with this device, identifier can be user's email, phone, or any string to identify your user
  Future<Event> signInWithDevice({
    required String identifier,
    required BuildContext context,
  }) {
    Device device = new Device(apiKeyID: this.apiKeyID);
    return device.signInWithDevice(
      identifier: identifier,
      context: context,
      cotter: this,
    );
  }

  // ===== Authentication Methods: Email / Phone Number Based =====

  /// Verify user's email, then create a user if email verification is successful
  Future<User> signUpWithEmailOTP(
      {required String redirectURL, String? email}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.signUpWithEmail(redirectURL: redirectURL, email: email);
  }

  /// Sign in with email allows existing user to authenticate by email verification.
  /// This method will CREATE A NEW USER if one doesn't exist with this email
  Future<User> signInWithEmailOTP(
      {required String redirectURL, required String email}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.verifyEmail(redirectURL: redirectURL, email: email);
  }

  /// Verify user's phone number, then create a user if phone verification is successful
  /// This method will allow the user to enter the phone number inside THE IN-APP BROWSER
  /// channels will show the options for the user to pick, can be SMS or WHATSAPP
  Future<User> signUpWithPhoneOTP(
      {required String redirectURL, List<PhoneChannel>? channels}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.signUpWithPhone(
        redirectURL: redirectURL, phoneChannels: channels);
  }

  /// Sign in with phone allows existing user to authenticate by phone verification.
  /// This method will allow the user to enter the phone number inside THE IN-APP BROWSER
  /// channels will show the options for the user to pick, can be SMS or WHATSAPP
  /// This method will CREATE A NEW USER if one doesn't exist with this email
  Future<User> signInWithPhoneOTP(
      {required String redirectURL, List<PhoneChannel>? channels}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.signUpWithPhone(
        redirectURL: redirectURL, phoneChannels: channels);
  }

  /// Verify user's phone number, then create a user if phone verification is successful
  /// This method will allow the user to enter the phone number inside YOUR APP
  /// and automatically send verification code via SMS
  Future<User> signUpWithPhoneOTPViaSMS(
      {required String redirectURL, required String phone}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.signUpWithPhoneViaSMS(redirectURL: redirectURL, phone: phone);
  }

  /// Sign in with phone via SMS allows existing users to authenticate by
  /// phone verification using SMS.
  /// This method will CREATE A NEW USER if one doesn't exist with this phone number
  Future<User> signInWithPhoneOTPViaSMS(
      {required String redirectURL, required String phone}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.verifyPhone(
        redirectURL: redirectURL, phone: phone, channel: PhoneChannel.SMS);
  }

  /// Verify user's phone number, then create a user if phone verification is successful
  /// This method will allow the user to enter the phone number inside YOUR APP
  /// and automatically send verification code via WhatsApp
  Future<User> signUpWithPhoneOTPViaWhatsApp(
      {required String redirectURL, required String phone}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.signUpWithPhoneViaWhatsApp(
        redirectURL: redirectURL, phone: phone);
  }

  /// Sign in with phone via WhatsApp allows existing users to authenticate by
  /// phone verification using WhatsApp.
  /// This method will CREATE A NEW USER if one doesn't exist with this phone number
  Future<User> signInWithPhoneOTPViaWhatsApp(
      {required String redirectURL, required String phone}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.verifyPhone(
        redirectURL: redirectURL, phone: phone, channel: PhoneChannel.WHATSAPP);
  }

  // ===== OAuth Token Handlers =====

  /// Get access token that is currently stored in the storage
  Future<CotterAccessToken?> getAccessToken() {
    return Token.getAccessToken(this.apiKeyID);
  }

  /// Get ID token that is currently stored in the storage
  Future<CotterIDToken?> getIDToken() {
    return Token.getIDToken(this.apiKeyID);
  }

  /// Get refresh token that is currently stored in the storage
  Future<String?> getRefreshToken() {
    return Token.getRefreshToken();
  }

  /// Logout user from the system.
  /// This is done by removing all authentication token stored in system storage
  Future<void> logOut() {
    return Token.logOut();
  }
}
