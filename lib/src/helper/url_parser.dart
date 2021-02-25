import 'dart:core';

class URLParser {
  // getSchemeFromURL takes in the full URL string, then returns the scheme
  // of the URL in the form of a string
  static String getSchemeFromURL(String url) {
    final uriObj = Uri.parse(url);
    return uriObj.scheme;
  }
}
