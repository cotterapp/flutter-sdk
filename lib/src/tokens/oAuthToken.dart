import 'package:cotter/src/handlers/token.dart';

class OAuthToken {
  String? accessToken;
  String? idToken;
  String? refreshToken;
  int? expiresIn;
  String? tokenType;
  String? authMethod;

  OAuthToken({
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.expiresIn,
    this.tokenType,
    this.authMethod,
  });

  factory OAuthToken.fromJson(Map<String, dynamic> json) {
    return OAuthToken(
      accessToken: json['access_token'],
      idToken: json['id_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      tokenType: json['token_type'],
      authMethod: json['auth_method'],
    );
  }

  Future<void> store() async {
    await Token.store(this);
  }
}
