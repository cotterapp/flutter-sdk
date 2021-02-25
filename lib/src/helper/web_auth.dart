import 'package:cotter/src/helper/url_parser.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class WebAuth {
  // startWebAuth spins up a web browser for users to get authenticated by OAuth
  // Based on FlutterWebAuth, authenticate function takes only the URL scheme
  // and not the entire redirectURL.
  static Future<String> startWebAuth(String authURL, String redirectURL) async {
    final scheme = URLParser.getSchemeFromURL(redirectURL);
    final result = await FlutterWebAuth.authenticate(
      url: authURL,
      callbackUrlScheme: scheme,
    );

    return result;
  }
}
