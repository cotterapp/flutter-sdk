import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class RandomString {
  static const _charset =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static String getRandomString(int length) {
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _charset.codeUnitAt(_rnd.nextInt(_charset.length))));
  }

  /// Randomly generate a 128 character string to be used as the PKCE code verifier
  static String createCodeVerifier() {
    return List.generate(
        128, (i) => _charset[Random.secure().nextInt(_charset.length)]).join();
  }

  static String createCodeChallegeFromVerifier(String codeVerifier) {
    var codeChallenge = base64Url
        .encode(sha256.convert(ascii.encode(codeVerifier)).bytes)
        .replaceAll('=', '');
    return codeChallenge;
  }
}
