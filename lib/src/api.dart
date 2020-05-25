import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:cotter/src/helper/crypto.dart';
import 'package:cotter/src/helper/enum.dart';
import 'package:meta/meta.dart';
import 'package:cotter/src/cotter.dart';
import 'package:cotter/src/models/verify.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class API {
  String apiKeyID;

  API({@required this.apiKeyID});

  Map<String, String> headers() {
    Map<String, String> headers = {
      'API_KEY_ID': this.apiKeyID,
      'Content-Type': 'application/json',
    };
    return headers;
  }

  Future<VerifyRequest> verifyRequest(String identifier, String identifierType,
      String pubKey, String sessionID) async {
    VerifyRequest req = new VerifyRequest(
        identifier: identifier,
        identifierType: identifierType,
        publicKey: pubKey,
        deviceName: await this.getDeviceName(),
        deviceType: this.getDeviceType(),
        sessionID: sessionID);

    String url = Cotter.baseURL + "/verify/request/" + sessionID;

    final http.Response response = await http.post(url,
        headers: this.headers(), body: jsonEncode(req.toJson()));

    if (response.statusCode == 200) {
      VerifyRequestResponse resp =
          VerifyRequestResponse.fromJson(json.decode(response.body));
      req.response = resp;
      return req;
    } else {
      throw Exception('Failed to make a verification request: ' +
          json.decode(response.body));
    }
  }

  verifyRespond({@required Map<String, dynamic> req}) async {
    var state = Crypto.randomString(5);
    String url =
        Cotter.baseURL + "/verify/respond/" + state + "?oauth_token=true";

    final http.Response response =
        await http.post(url, headers: this.headers(), body: jsonEncode(req));

    if (response.statusCode == 200) {
      Map<String, dynamic> resp = json.decode(response.body);
      var body = response.body;
      log('data: $body');
      if (resp["state"] != state) {
        throw Exception(
            'State received in the response is not the same as requested');
      }
      return resp;
    } else {
      var respStr = jsonDecode(response.body);
      log('data: $respStr');
      throw Exception('Failed to make a verification respond: ');
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
}
