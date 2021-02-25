import 'dart:convert';

import 'package:cotter/src/cotter.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';

class JWT {
  /// Get web key to validate tokens.
  static Future<Map<String, dynamic>> getJsonWebKey() async {
    var path = '/token/jwks';
    final http.Response response = await http.get("${Cotter.baseURL}$path");

    if (response.statusCode == 200) {
      Map<String, dynamic> resp = json.decode(response.body);
      List<Map<String, dynamic>> keys = resp["keys"];
      Map<String, dynamic> jwtKey;
      keys.forEach((k) {
        if (k["kid"] == Cotter.kid) {
          jwtKey = k;
          return;
        }
      });
      return jwtKey;
    } else {
      var respStr = json.decode(response.body.toString());
      throw respStr;
    }
  }

  /// Verify if the token that is passed in is valid.
  static Future<bool> verify(String token) async {
    // decode the jwt, note: this constructor can only be used for JWT inside JWS
    // structures
    var jwt = new JsonWebToken.unverified(token);

    var jwk = await getJsonWebKey();
    // create key store to verify the signature
    var keyStore = new JsonWebKeyStore()..addKey(new JsonWebKey.fromJson(jwk));

    return await jwt.verify(keyStore);
  }
}
