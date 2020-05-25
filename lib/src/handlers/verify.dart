import 'dart:convert';
import 'dart:developer';

import 'package:cotter/src/api.dart';
import 'package:cotter/src/helper/crypto.dart';
import 'package:cotter/src/helper/storage.dart';
import 'package:cotter/src/models/verify.dart';
import 'package:meta/meta.dart';

class Verify {
  static final String _publicKey = "COTTER_VERIFICATION_PUBLIC_KEY";
  static final String _privateKey = "COTTER_VERIFICATION_PRIVATE_KEY";
  static final String _sessionID = "COTTER_VERIFICATION_SESSION_ID";
  static final int _sessionIDLength = 8;

  static Map<String, VerifyRequest> requestManager = {};

  String apiKeyID;

  Verify({@required this.apiKeyID});

  _storeKeys(String pubKey, String privKey) async {
    await Storage.write(key: _publicKey, value: pubKey);
    await Storage.write(key: _privateKey, value: privKey);
  }

  Future<String> _generateSessionID() async {
    var sessionID = Crypto.randomString(_sessionIDLength);
    await Storage.write(key: _sessionID, value: sessionID);
    return sessionID;
  }

  Future<String> getSessionID() async {
    String sessionID = await Storage.read(key: _sessionID);
    if (sessionID == null) {
      return _generateSessionID();
    }
    return sessionID;
  }

  Future<CotterKeyPair> generateKeys() async {
    CotterKeyPair cotterKeyPair = await Crypto.generateKeyPair();
    String pubKey = cotterKeyPair.getPublicKeyBase64();
    String privKey = cotterKeyPair.getPrivateKeyBase64();
    log("KEYS $pubKey $privKey");
    await this._storeKeys(pubKey, privKey);
    return cotterKeyPair;
  }

  Future<String> getPublicKey() async {
    String pubKey = await Storage.read(key: _publicKey);
    if (pubKey == null) {
      CotterKeyPair cotterKeyPair = await this.generateKeys();
      pubKey = cotterKeyPair.getPublicKeyBase64();
    }
    return pubKey;
  }

  Future<CotterKeyPair> getKeyPair() async {
    String pubKey = await Storage.read(key: _publicKey);
    String privKey = await Storage.read(key: _privateKey);
    if (pubKey == null || privKey == null) {
      CotterKeyPair cotterKeyPair = await this.generateKeys();
      return cotterKeyPair;
    }

    CotterKeyPair cotterKeyPair = CotterKeyPair.loadKeysFromString(
        publicKey: pubKey, privateKey: privKey);
    return cotterKeyPair;
  }

  // sendCode sends a verification code if needed,
  // returns a boolean indicating whether the user need to
  // enter the verification code or not.
  Future<bool> sendCode(
      {@required String identifier, @required String identifierType}) async {
    String sessionID = await this.getSessionID();
    String pubKey = await this.getPublicKey();

    API api = new API(apiKeyID: this.apiKeyID);
    VerifyRequest req =
        await api.verifyRequest(identifier, identifierType, pubKey, sessionID);
    requestManager[identifier] = req;
    return req.response.codeSent;
  }

  Future<Map<String, dynamic>> verifyCode(
      {@required String identifier, String code}) async {
    if (code == null) {
      code = "";
    }
    VerifyRequest req = requestManager[identifier];
    if (req == null) {
      throw Exception(
          "Fail finding verification request for the email/phone number. Did you close the app before entering the code?");
    }

    String timestamp =
        (new DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    String message = req.toRespondMessage(code, timestamp);
    CotterKeyPair cotterKeyPair = await this.getKeyPair();
    String signature =
        await Crypto.sign(message: message, cotterKeyPair: cotterKeyPair);

    log(jsonEncode(signature));
    Map<String, dynamic> request =
        req.toRespondRequest(code, timestamp, signature);

    log(jsonEncode(request));
    API api = new API(apiKeyID: this.apiKeyID);
    Map<String, dynamic> resp = await api.verifyRespond(req: request);

    return {
      "identity": resp["identifier"],
      "oauth_token": resp["oauth_token"],
    };
  }
}
