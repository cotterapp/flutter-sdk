import 'package:cotter/src/api.dart';
import 'package:cotter/src/exceptions/token.dart';
import 'package:cotter/src/helper/storage.dart';
import 'package:cotter/src/helper/enum.dart';
import 'package:cotter/src/tokens/cotterAccessToken.dart';
import 'package:cotter/src/tokens/cotterIDToken.dart';
import 'package:cotter/src/tokens/cotterJwtToken.dart';
import 'package:cotter/src/tokens/oAuthToken.dart';

class Token {
  static OAuthToken? oAuthToken;
  static CotterAccessToken? accessToken;
  static CotterIDToken? idToken;

  static Future<void> store(OAuthToken oAuthToken) async {
    Token.oAuthToken = oAuthToken;
    if (oAuthToken.accessToken != null && oAuthToken.accessToken!.length > 0) {
      await Storage.write(key: ACCESS_TOKEN_KEY, value: oAuthToken.accessToken);
      Token.accessToken = new CotterAccessToken(token: oAuthToken.accessToken!);
    }
    if (oAuthToken.refreshToken != null && oAuthToken.refreshToken!.length > 0) {
      await Storage.write(
          key: REFRESH_TOKEN_KEY, value: oAuthToken.refreshToken);
    }
    if (oAuthToken.idToken != null && oAuthToken.idToken!.length > 0) {
      await Storage.write(key: ID_TOKEN_KEY, value: oAuthToken.idToken);
      Token.idToken = new CotterIDToken(token: oAuthToken.idToken!);
    }
    if (oAuthToken.tokenType != null && oAuthToken.tokenType!.length > 0) {
      await Storage.write(key: TOKEN_TYPE_KEY, value: oAuthToken.tokenType);
    }
  }

  static Future<CotterAccessToken?> getAccessToken(String apiKeyID) async {
    if (Token.accessToken == null) {
      var token = await Storage.read(key: ACCESS_TOKEN_KEY);
      if (token != null) {
        Token.accessToken = new CotterAccessToken(token: token);
      }
    }
    await Token.refreshIfNeeded(Token.accessToken, apiKeyID);
    return Token.accessToken;
  }

  static Future<CotterIDToken?> getIDToken(String? apiKeyID) async {
    if (Token.idToken == null) {
      var token = await Storage.read(key: ID_TOKEN_KEY);
      if (token != null) {
        Token.idToken = new CotterIDToken(token: token);
      }
    }
    await Token.refreshIfNeeded(Token.idToken, apiKeyID);
    return Token.idToken;
  }

  static Future<String?> getRefreshToken() async {
    var refreshToken = await Storage.read(key: REFRESH_TOKEN_KEY);
    return refreshToken;
  }

  static Future<void> refreshIfNeeded(
      CotterJwtToken? token, String? apiKeyID) async {
    if (token == null || token.isExpired()) {
      var refreshToken = await Token.getRefreshToken();
      if (refreshToken == null) {
        throw RefreshTokenNotExistException(
            message: 'Refresh token is not in storage, you need to log in.');
      }

      API api = new API(apiKeyID: apiKeyID);
      var oAuthToken = await api.getTokensFromRefreshToken(refreshToken);
      await oAuthToken.store();
    }
  }

  static Future<void> logOut() async {
    await Storage.delete(key: ACCESS_TOKEN_KEY);
    await Storage.delete(key: REFRESH_TOKEN_KEY);
    await Storage.delete(key: ID_TOKEN_KEY);
    await Storage.delete(key: TOKEN_TYPE_KEY);
    oAuthToken = null;
    accessToken = null;
    idToken = null;
  }
}
