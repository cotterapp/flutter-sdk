import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

class CotterKeyPair {
  late SimpleKeyPair keyPair;
  static final type = KeyPairType.ed25519;

  CotterKeyPair(SimpleKeyPair keyPair) {
    this.keyPair = keyPair;
  }

  Future<String> getPublicKeyBase64() async {
    final pubKey = await keyPair.extractPublicKey();
    return base64Encode(pubKey.bytes);
  }

  Future<String> getPrivateKeyBase64() async {
    final bytes = await keyPair.extractPrivateKeyBytes();
    return base64Encode(bytes);
  }

  static CotterKeyPair loadKeysFromString(
      {required String publicKey, required String privateKey}) {
    List<int> publicKeyBytes = base64Decode(publicKey);
    List<int> privateKeyBytes = base64Decode(privateKey);

    final pubKey = SimplePublicKey(
      publicKeyBytes,
      type: CotterKeyPair.type,
    );

    // PublicKey pk = new PublicKey(publicKeyBytes);
    // PrivateKey sk = new PrivateKey(privateKeyBytes);
    // KeyPair keyPair = new KeyPair(privateKey: sk, publicKey: pk);
    SimpleKeyPair keyPair = new SimpleKeyPairData(
      privateKeyBytes,
      publicKey: Future.value(pubKey),
      type: CotterKeyPair.type,
    );

    return new CotterKeyPair(keyPair);
  }
}

class Crypto {
  static Future<CotterKeyPair> generateKeyPair() async {
    final keyPair = await Ed25519().newKeyPair();
    return new CotterKeyPair(keyPair);
  }

  static Future<String> sign(
      {required String message, required CotterKeyPair cotterKeyPair}) async {
    KeyPair keyPair = cotterKeyPair.keyPair;
    List<int> messageBytes = utf8.encode(message);
    Signature signature = await Ed25519().sign(
      messageBytes,
      keyPair: keyPair,
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
