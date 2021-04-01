import 'package:cotter/src/helper/jwt.dart';
import 'package:cotter/src/tokens/standardClaims.dart';
import 'package:jose/jose.dart';

class CotterJwtToken extends StandardClaims {
  String? token;
  Map<String, dynamic>? payload;

  CotterJwtToken(String token) : super(token);

  static Map<String, dynamic>? decodePayload(String token) {
    var jwt = new JsonWebToken.unverified(token);
    var payload = jwt.claims.toJson();
    return payload;
  }

  Future<bool> verify() async {
    return await JWT.verify(this.token!);
  }
}
