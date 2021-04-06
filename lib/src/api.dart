import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cotter/cotter.dart';
import 'package:cotter/src/helper/enum.dart';
import 'package:cotter/src/models/user.dart';
import 'package:cotter/src/tokens/oAuthToken.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:cotter/src/cotter.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class API {
  String? apiKeyID;

  API({required this.apiKeyID});

  Map<String, String?> headers() {
    Map<String, String?> headers = {
      'API_KEY_ID': this.apiKeyID,
      'Content-Type': 'application/json',
    };
    return headers;
  }

  /// Register a new user with specified identifier to Cotter.
  /// Duplicate identifier will result in an error.
  Future<User> registerUserToCotter(String identifier) async {
    final uri = Uri.parse('${Cotter.baseURL}/user/create');
    Map<String, dynamic> req = {
      "identifier": identifier,
    };

    final http.Response response = await http.post(uri,
        headers: this.headers() as Map<String, String>?, body: jsonEncode(req));

    if (response.statusCode == 200) {
      User resp = User.fromJson(json.decode(response.body));
      return resp;
    } else {
      return _handleError(response) as FutureOr<User>;
    }
  }

  Future<User> getUserByIdentifier(String identifier) async {
    final uri = Uri.parse(
        '${Cotter.baseURL}/user?identifier=${Uri.encodeComponent(identifier)}');
    final http.Response response =
        await http.get(uri, headers: this.headers() as Map<String, String>?);

    if (response.statusCode == 200) {
      User resp = User.fromJson(json.decode(response.body));
      return resp;
    } else {
      return _handleError(response) as FutureOr<User>;
    }
  }

  Future<Map<String, dynamic>?> updateMethodsWithClientUserID({
    required String clientUserID,
    required String method,
    required bool enrolled,
    required String code, // Code for PIN or Public Key
    String? algorithm,
    bool changeCode = false,
    String? currentCode,
  }) async {
    String url = "${Cotter.baseURL}/user/$clientUserID?oauth_token=true";
    return await updateMethods(
        url: url,
        method: method,
        enrolled: enrolled,
        code: code,
        algorithm: algorithm,
        changeCode: changeCode,
        currentCode: currentCode);
  }

  Future<Map<String, dynamic>?> updateMethodsWithCotterUserID({
    required String? cotterUserID,
    required String method,
    required bool enrolled,
    required String code, // Code for PIN or Public Key
    String? algorithm,
    bool changeCode = false,
    String? currentCode,
  }) async {
    String url =
        "${Cotter.baseURL}/user/methods?cotter_user_id=$cotterUserID&oauth_token=true";
    return await updateMethods(
        url: url,
        method: method,
        enrolled: enrolled,
        code: code,
        algorithm: algorithm,
        changeCode: changeCode,
        currentCode: currentCode);
  }

  Future<Map<String, dynamic>?> updateMethods({
    required String url,
    required String method,
    required bool enrolled,
    required String code, // Code for PIN or Public Key
    String? algorithm,
    bool changeCode = false,
    String? currentCode,
  }) async {
    Map<String, dynamic> req = {
      "method": method,
      "enrolled": enrolled,
      "code": code, // Code for PIN or Public Key

      // for Trusted Devices
      "device_type": this.getDeviceType(),
      "device_name": await this.getDeviceName(),
      "algorithm": algorithm,

      // updating code
      "change_code": changeCode,
      "current_code": currentCode,
    };

    final uri = Uri.parse(url);
    final http.Response response = await http.put(uri,
        headers: this.headers() as Map<String, String>?, body: jsonEncode(req));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return _handleError(response) as FutureOr<Map<String, dynamic>?>;
    }
  }

  Future<bool?> checkEnrolledMethodWithCotterUserID({
    required String? cotterUserID,
    required String method,
    String? pubKey,
  }) async {
    String url =
        "${Cotter.baseURL}/user/methods?cotter_user_id=$cotterUserID&method=$method";
    if (pubKey != null) {
      var bytes = utf8.encode(pubKey);
      var pubKeyB64 = base64Encode(bytes);
      url = "$url&public_key=$pubKeyB64";
    }

    return await checkEnrolledMethod(url: url, method: method);
  }

  Future<bool?> checkEnrolledMethodWithClientUserID({
    required String clientUserID,
    required String method,
    String? pubKey,
  }) async {
    String url = "${Cotter.baseURL}/user/enrolled/$clientUserID/$method";
    if (pubKey != null) {
      var bytes = utf8.encode(pubKey);
      var pubKeyB64 = base64Encode(bytes);
      url = "$url/$pubKeyB64";
    }

    return await checkEnrolledMethod(url: url, method: method);
  }

  Future<bool?> checkEnrolledMethod(
      {required String url, required String method}) async {
    final uri = Uri.parse(url);
    final http.Response response =
        await http.get(uri, headers: this.headers() as Map<String, String>?);

    if (response.statusCode == 200) {
      Map<String, dynamic> resp = json.decode(response.body);
      if (resp["method"] == method && resp["enrolled"] != null) {
        return resp["enrolled"];
      }
      return false;
    } else {
      return _handleError(response) as FutureOr<bool?>;
    }
  }

  Future<Map<String, dynamic>?> createApprovedEventRequest(
      Map<String, dynamic> req) async {
    var path = '/event/create?oauth_token=true';
    return await createEventRequest(path, req);
  }

  Future<Map<String, dynamic>?> createPendingEventRequest(
      Map<String, dynamic> req) async {
    var path = '/event/create_pending';
    return await createEventRequest(path, req);
  }

  Future<Event> createRespondEventRequest(
      String eventID, Map<String, dynamic> req) async {
    var path = '/event/respond/$eventID';
    var resp =
        await (createEventRequest(path, req) as FutureOr<Map<String, dynamic>>);
    return Event.fromJson(resp);
  }

  Future<Map<String, dynamic>?> createEventRequest(
      String path, Map<String, dynamic> req) async {
    final uri = Uri.parse("${Cotter.baseURL}$path");
    final http.Response response = await http.post(uri,
        headers: this.headers() as Map<String, String>?, body: jsonEncode(req));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return _handleError(response) as FutureOr<Map<String, dynamic>?>;
    }
  }

  Future<OAuthToken> getTokensFromRefreshToken(String refreshToken) async {
    var path = "/token/${this.apiKeyID}";
    Map<String, dynamic> req = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    };

    final uri = Uri.parse("${Cotter.baseURL}$path");
    final http.Response response = await http.post(uri,
        headers: this.headers() as Map<String, String>?, body: jsonEncode(req));

    if (response.statusCode == 200) {
      var resp = json.decode(response.body);
      OAuthToken oAuthToken = OAuthToken.fromJson(resp);
      return oAuthToken;
    } else {
      return _handleError(response) as FutureOr<OAuthToken>;
    }
  }

  Future<Map<String, dynamic>?> getEvent(String eventID) async {
    var path = '/event/get/$eventID?oauth_token=true';
    final uri = Uri.parse("${Cotter.baseURL}$path");
    final http.Response response =
        await http.get(uri, headers: this.headers() as Map<String, String>?);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return _handleError(response) as FutureOr<Map<String, dynamic>?>;
    }
  }

  Future<Event?> checkNewEvent({
    String? cotterUserID,
    String? clientUserID,
  }) async {
    var path = '/event/new';
    if (cotterUserID != null) {
      path = '$path?cotter_user_id=$cotterUserID';
    } else if (clientUserID != null) {
      path = '$path?client_user_id=$clientUserID';
    } else {
      throw "Cotter user ID and client user ID can't both be null, please specify one of them";
    }

    final uri = Uri.parse("${Cotter.baseURL}$path");
    final http.Response response =
        await http.get(uri, headers: this.headers() as Map<String, String>?);

    if (response.statusCode == 200) {
      var resp = json.decode(response.body);
      if (resp == null) {
        return null;
      }
      Event event = Event.fromJson(resp);
      return event;
    } else {
      return _handleError(response) as FutureOr<Event?>;
    }
  }

  Future<Map<String, dynamic>?> getIdentity(
    String? authCode,
    String? state,
    String challengeID,
    String? codeVerifier,
    String redirectURL,
  ) async {
    var path = '/verify/get_identity?oauth_token=true';

    var req = {
      "code_verifier": codeVerifier,
      "authorization_code": authCode,
      "challenge_id": int.parse(challengeID),
      "redirect_url": redirectURL,
    };

    final uri = Uri.parse("${Cotter.baseURL}$path");
    final http.Response response = await http.post(uri,
        headers: this.headers() as Map<String, String>?, body: jsonEncode(req));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return _handleError(response) as FutureOr<Map<String, dynamic>?>;
    }
  }
  // ========== HELPER METHODS ==========

  Future<dynamic> _handleError(http.Response response) {
    var respStr = json.decode(response.body.toString());
    if (respStr["msg"] != null) {
      throw respStr["msg"];
    } else {
      throw 'Failed to request: $respStr';
    }
  }

  Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
        return build.model + " " + build.version.release;
      } else if (Platform.isIOS) {
        IosDeviceInfo build = await DeviceInfoPlugin().iosInfo;
        return build.name + " " + build.model + " " + build.systemVersion;
      }
    } on PlatformException {
      return "unknown";
    }
    return "unknown";
  }

  String getDeviceType() {
    return Mobile;
  }

  Future<IPLocation> getIPAddress() async {
    final uri = Uri.parse('https://geoip-db.com/json/');
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> resp = json.decode(response.body);
      return IPLocation(ip: resp["IPv4"], location: resp["city"]);
    } else {
      return _handleError(response) as FutureOr<IPLocation>;
    }
  }
}

class IPLocation {
  String? ip;
  String? location;

  IPLocation({
    this.ip = 'unknown',
    this.location = 'unknown',
  });
}
