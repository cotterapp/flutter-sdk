import 'dart:developer';

class VerifyRequestResponse {
  int challengeID;
  bool codeSent;
  String challenge;
  String expiry;

  VerifyRequestResponse(
      {this.challengeID, this.codeSent, this.challenge, this.expiry});

  factory VerifyRequestResponse.fromJson(Map<String, dynamic> json) {
    return VerifyRequestResponse(
      challengeID: json['challenge_id'],
      codeSent: json['code_sent'],
      challenge: json['challenge'],
      expiry: json['expiry'],
    );
  }
}

class VerifyRequest {
  String identifier;
  String identifierType;
  String publicKey;
  String deviceType;
  String deviceName;
  String sessionID;
  VerifyRequestResponse response;

  VerifyRequest(
      {this.identifier,
      this.identifierType,
      this.publicKey,
      this.deviceName,
      this.deviceType,
      this.sessionID});

  Map<String, dynamic> toJson() => {
        "identifier": this.identifier,
        "identifier_type": this.identifierType,
        "public_key": this.publicKey,
        "device_type": this.deviceType,
        "device_name": this.deviceName,
      };

  Map<String, dynamic> toRespondRequest(
      String code, String timestamp, String signature) {
    return {
      "identifier": this.identifier,
      "identifier_type": this.identifierType,
      "public_key": this.publicKey,
      "device_type": this.deviceType,
      "device_name": this.deviceName,
      "redirect_url": "-",
      "challenge_id": this.response.challengeID,
      "challenge": this.response.challenge,
      "code": code,
      "timestamp": timestamp,
      "signature": signature,
    };
  }

  String toRespondMessage(String code, String timestamp) {
    var message = [
      this.identifier,
      this.identifierType,
      this.deviceType,
      this.deviceName,
      "-",
      this.response.challengeID.toString(),
      this.response.challenge,
      code,
      timestamp,
    ];
    var msgStr = message.join();
    log(msgStr);
    return msgStr;
  }
}
