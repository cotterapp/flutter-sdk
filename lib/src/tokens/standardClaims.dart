import 'package:cotter/src/tokens/cotterJwtToken.dart';

class StandardClaims {
  String? audience; // client's api key id
  int? expiresAt;
  int? issuedAt;
  String? issuer; // Cotter
  String? subject; // User ID
  String? id; // token unique iD

  StandardClaims(String token) {
    Map<String, dynamic> json = CotterJwtToken.decodePayload(token)!;
    this.audience = json["aud"];
    this.expiresAt = json["exp"];
    this.issuedAt = json["iat"];
    this.issuer = json["iss"];
    this.id = json["jti"];
    this.subject = json["sub"];
  }

  int? getExpiresAt() {
    return this.expiresAt;
  }

  bool isExpired() {
    var timeNow =
        (new DateTime.now().millisecondsSinceEpoch / 1000).round() + 5;
    if (this.getExpiresAt() != null && this.getExpiresAt()! < timeNow) {
      return true;
    }
    return false;
  }

  int? getIssuedAt() {
    return this.issuedAt;
  }

  String? getAudience() {
    return this.audience;
  }

  String? getSubject() {
    return this.subject;
  }

  String? getUserID() {
    return this.subject;
  }

  String? getIssuer() {
    return this.issuer;
  }

  String? getTokenID() {
    return this.id;
  }
}
