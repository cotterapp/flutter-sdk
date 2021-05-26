import 'dart:async';
import 'package:cotter/cotter.dart';
import 'package:cotter/src/api.dart';
import 'package:cotter/src/helper/enum.dart';
import 'package:cotter/src/models/canceler.dart';
import 'package:cotter/src/models/event.dart';
import 'package:cotter/src/models/user.dart';
import 'package:cotter/src/tokens/oAuthToken.dart';
import 'package:cotter/src/widgets/approveRequest.dart';
import 'package:cotter/src/widgets/authRequest.dart';
import 'package:flutter/material.dart';

import 'package:cotter/src/helper/crypto.dart';
import 'package:cotter/src/helper/storage.dart';

class Device {
  static final String _publicKey = "COTTER_DEVICE_PUBLIC_KEY";
  static final String _privateKey = "COTTER_DEVICE_PRIVATE_KEY";
  String apiKeyID;

  Device({required this.apiKeyID});

  String _getKeyStoreAliasPublicKey(String? userID) {
    if (userID == null) {
      throw "User ID is not specified, please specify user ID before calling other methods";
    }
    return _publicKey + this.apiKeyID + userID;
  }

  String _getKeyStoreAliasPrivateKey(String? userID) {
    if (userID == null) {
      throw "User ID is not specified, please specify user ID before calling other methods";
    }
    return _privateKey + this.apiKeyID + userID;
  }

  _storeKeys(String pubKey, String privKey, String? userID) async {
    await Storage.write(key: _getKeyStoreAliasPublicKey(userID), value: pubKey);
    await Storage.write(
        key: _getKeyStoreAliasPrivateKey(userID), value: privKey);
  }

  Future<CotterKeyPair> generateKeys(String? userID) async {
    CotterKeyPair cotterKeyPair = await Crypto.generateKeyPair();
    String pubKey = await cotterKeyPair.getPublicKeyBase64();
    String privKey = await cotterKeyPair.getPrivateKeyBase64();
    await this._storeKeys(pubKey, privKey, userID);
    return cotterKeyPair;
  }

  Future<String> getPublicKey(String userID) async {
    String? pubKey =
        await Storage.read(key: _getKeyStoreAliasPublicKey(userID));
    if (pubKey == null) {
      CotterKeyPair cotterKeyPair = await this.generateKeys(userID);
      pubKey = await cotterKeyPair.getPublicKeyBase64();
    }
    return pubKey;
  }

  Future<CotterKeyPair> getKeyPair(String? userID) async {
    String? pubKey =
        await Storage.read(key: _getKeyStoreAliasPublicKey(userID));
    String? privKey =
        await Storage.read(key: _getKeyStoreAliasPrivateKey(userID));
    if (pubKey == null || privKey == null) {
      CotterKeyPair cotterKeyPair = await this.generateKeys(userID);
      return cotterKeyPair;
    }

    CotterKeyPair cotterKeyPair = CotterKeyPair.loadKeysFromString(
        publicKey: pubKey, privateKey: privKey);
    return cotterKeyPair;
  }

  Future<User> signUpWithDevice({required String identifier}) async {
    API api = new API(apiKeyID: this.apiKeyID);
    User user = await api.registerUserToCotter(identifier);
    return await this.registerDevice(user: user);
  }

  Future<User> registerDevice({required User user}) async {
    API api = new API(apiKeyID: this.apiKeyID);
    CotterKeyPair keyPair = await this.getKeyPair(user.id);

    try {
      String pubKeyBase64 = await keyPair.getPublicKeyBase64();
      var resp = await (api.updateMethodsWithCotterUserID(
        cotterUserID: user.id,
        method: TrustedDeviceMethod,
        enrolled: true,
        code: pubKeyBase64,
        algorithm: TrustedDeviceAlgorithm,
      ) as FutureOr<Map<String, dynamic>>);

      user = User.fromJson(resp);
      OAuthToken oAuthToken = OAuthToken.fromJson(resp["oauth_token"]);
      await oAuthToken.store();
    } catch (e) {
      throw e;
    }
    await user.store();
    return user;
  }

  Future<Event> signInWithDevice({
    required String identifier,
    required BuildContext context,
    required Cotter cotter,
  }) async {
    API api = new API(apiKeyID: this.apiKeyID);
    User user = await api.getUserByIdentifier(identifier);
    Event event;

    var thisDeviceIsTrusted = await (this
        .isThisDeviceTrusted(cotterUserID: user.id) as FutureOr<bool>);

    if (thisDeviceIsTrusted) {
      event = await this.authorizeDevice(cotterUserID: user.id);
    } else {
      event = await this.requestAuthentication(
        cotterUserID: user.id,
        context: context,
        cotter: cotter,
      );
    }
    if (event.approved!) {
      await user.store();
    }
    return event;
  }

  Future<Event> authorizeDevice({required String? cotterUserID}) async {
    API api = new API(apiKeyID: this.apiKeyID);
    String timestamp =
        (new DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
    CotterKeyPair keyPair = await this.getKeyPair(cotterUserID);

    Event ev = Event.createWithCotterUserID(
      apiKeyID: this.apiKeyID,
      cotterUserID: cotterUserID,
      event: LoginWithDeviceEvent,
      timestamp: timestamp,
      method: TrustedDeviceMethod,
    );
    String stringToSign = ev.constructApprovedEventMsg();
    String signature =
        await Crypto.sign(message: stringToSign, cotterKeyPair: keyPair);
    String pubKeyBase64 = await keyPair.getPublicKeyBase64();

    Map<String, dynamic> req = await ev.constructApprovedEventJSON(
      codeOrSignature: signature,
      publicKey: pubKeyBase64,
      algorithm: TrustedDeviceAlgorithm,
    );

    Map<String, dynamic> resp = await (api.createApprovedEventRequest(req)
        as FutureOr<Map<String, dynamic>>);

    Event event = Event.fromJson(resp);
    OAuthToken oAuthToken = OAuthToken.fromJson(resp["oauth_token"]);
    await oAuthToken.store();
    return event;
  }

  Future<Event> requestAuthentication(
      {required String? cotterUserID,
      required BuildContext context,
      required Cotter cotter}) async {
    API api = new API(apiKeyID: this.apiKeyID);
    String timestamp =
        (new DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    Event ev = Event.createWithCotterUserID(
      apiKeyID: this.apiKeyID,
      cotterUserID: cotterUserID,
      event: LoginWithDeviceEvent,
      timestamp: timestamp,
      method: TrustedDeviceMethod,
    );

    Map<String, dynamic> req = await ev.constructPendingEventJSON();

    Map<String, dynamic> resp = await (api.createPendingEventRequest(req)
        as FutureOr<Map<String, dynamic>>);
    Event event = Event.fromJson(resp);

    if (!event.approved!) {
      Future<void> closed = showModalBottomSheet(
        backgroundColor: Colors.black26,
        context: context,
        builder: (context) => AuthRequest(cotter: cotter),
      );
      Canceler canceler = Canceler(canceled: false);
      closed.then((value) => canceler.cancel());

      Event ev = await pollGetEvent(
        event: event,
        canceler: canceler,
        onFinished: () {
          Navigator.pop(context);
        },
      );
      if (ev == null) {
        throw "Event is null";
      }
      return ev;
    }
    return event;
  }

  Future<Event> pollGetEvent(
      {required Event event,
      required Canceler canceler,
      required Function onFinished}) async {
    int tick = 0;
    Event ev = event;
    while (tick < AuthRequestDuration && !canceler.canceled!) {
      API api = new API(apiKeyID: this.apiKeyID);
      var resp = await (api.getEvent(event.id.toString())
          as FutureOr<Map<String, dynamic>>);
      if (resp["approved"]) {
        ev = Event.fromJson(resp);
        OAuthToken oAuthToken = OAuthToken.fromJson(resp["oauth_token"]);
        await oAuthToken.store();
        break;
      }
      tick = tick + 1;
      await Future.delayed(new Duration(seconds: 1));
    }
    if (!canceler.canceled!) {
      onFinished();
    }
    return ev;
  }

  Future<Event?> checkNewSignInRequest(
      {required String? cotterUserID,
      required BuildContext context,
      required Cotter? cotter}) async {
    API api = new API(apiKeyID: this.apiKeyID);
    CotterKeyPair keyPair = await this.getKeyPair(cotterUserID);
    var thisDeviceIsTrusted = await (this
        .isThisDeviceTrusted(cotterUserID: cotterUserID) as FutureOr<bool>);
    if (!thisDeviceIsTrusted) {
      throw "This is not a trusted device, you can only approve logins from a trusted device.";
    }

    Event? event = await api.checkNewEvent(cotterUserID: cotterUserID);

    if (event == null) {
      return null;
    }
    final bool? approved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApproveRequest(
          cotter: cotter,
        ),
        fullscreenDialog: true,
      ),
    );

    event.approved = approved;
    String stringToSign = event.constructRespondEventMsg();
    String signature =
        await Crypto.sign(message: stringToSign, cotterKeyPair: keyPair);

    String pubKeyBase64 = await keyPair.getPublicKeyBase64();

    Map<String, dynamic> req = await event.constructRespondEventJSON(
      method: TrustedDeviceMethod,
      codeOrSignature: signature,
      publicKey: pubKeyBase64,
      algorithm: TrustedDeviceAlgorithm,
    );

    event = await api.createRespondEventRequest(event.id.toString(), req);
    return event;
  }

  Future<bool?> isThisDeviceTrusted({required String? cotterUserID}) async {
    API api = new API(apiKeyID: this.apiKeyID);
    CotterKeyPair keyPair = await this.getKeyPair(cotterUserID);
    String pubKeyBase64 = await keyPair.getPublicKeyBase64();
    return await api.checkEnrolledMethodWithCotterUserID(
      cotterUserID: cotterUserID,
      method: TrustedDeviceMethod,
      pubKey: pubKeyBase64,
    );
  }
}
