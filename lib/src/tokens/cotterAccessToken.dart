import 'package:cotter/src/tokens/cotterJwtToken.dart';

class CotterAccessToken extends CotterJwtToken {
  String? token;
  String? clientUserID;
  String? authenticationMethod;
  String? scope;
  String? type;

  CotterAccessToken({required String this.token}) : super(token) {
    this.token = token;
    var payload = CotterJwtToken.decodePayload(token!)!;
    this.payload = payload;
    this.clientUserID = payload["client_user_id"];
    this.authenticationMethod = payload["authentication_method"];
    this.scope = payload["scope"];
    this.type = payload["type"];
  }

  String? getAuthMethod() {
    return this.authenticationMethod;
  }

  String? getScope() {
    return this.scope;
  }

  String? getClientUserID() {
    return this.clientUserID;
  }
}
