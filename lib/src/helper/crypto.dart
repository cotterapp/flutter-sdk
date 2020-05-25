import 'dart:convert';
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:cryptography/cryptography.dart';

class CotterKeyPair {
  KeyPair keyPair;

  CotterKeyPair(keyPair) {
    this.keyPair = keyPair;
  }

  String getPublicKeyBase64() {
    return base64Encode(keyPair.publicKey.bytes);
  }

  String getPrivateKeyBase64() {
    return base64Encode(keyPair.privateKey.extractSync());
  }

  static CotterKeyPair loadKeysFromString(
      {@required String publicKey, @required String privateKey}) {
    List<int> publicKeyBytes = base64Decode(publicKey);
    List<int> privateKeyBytes = base64Decode(privateKey);

    PublicKey pk = new PublicKey(publicKeyBytes);
    PrivateKey sk = new PrivateKey(privateKeyBytes);
    KeyPair keyPair = new KeyPair(privateKey: sk, publicKey: pk);
    return new CotterKeyPair(keyPair);
  }
}

class Crypto {
  static Future<CotterKeyPair> generateKeyPair() async {
    final keyPair = await ed25519.newKeyPair();
    return new CotterKeyPair(keyPair);
  }

  static Future<String> sign(
      {@required String message, @required CotterKeyPair cotterKeyPair}) async {
    KeyPair keyPair = cotterKeyPair.keyPair;
    List<int> messageBytes = utf8.encode(message);
    Signature signature = await ed25519.sign(
      messageBytes,
      keyPair,
    );
    return base64Encode(signature.bytes);
  }

  static String randomString(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });

    return new String.fromCharCodes(codeUnits);
  }
}
