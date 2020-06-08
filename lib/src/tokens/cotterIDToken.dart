import 'package:cotter/src/tokens/cotterJwtToken.dart';
import 'package:flutter/material.dart';

class CotterIDToken extends CotterJwtToken {
  String token;
  String clientUserID;
  String authTime;
  String identifier;
  String type;

  CotterIDToken({@required this.token}) : super(token) {
    this.token = token;
    var payload = CotterJwtToken.decodePayload(token);
    this.payload = payload;
    this.clientUserID = payload["client_user_id"];
    this.authTime = payload["auth_time"];
    this.identifier = payload["identifier"];
    this.type = payload["type"];
  }

  String getAuthTime() {
    return this.authTime;
  }

  String getIdentifier() {
    return this.identifier;
  }

  String getClientUserID() {
    return this.clientUserID;
  }

  String getTokenType() {
    return this.type;
  }
}
