import 'package:cotter/cotter.dart';
import 'package:cotter/src/api.dart';
import 'package:cotter/src/helper/enum.dart';
import 'package:cotter/src/helper/random.dart';
import 'package:cotter/src/helper/web_auth.dart';
import 'package:cotter/src/tokens/oAuthToken.dart';
import 'package:meta/meta.dart';

class Verify {
  String apiKeyID;
  String state;
  String codeVerifier;
  String codeChallenge;

  Verify({@required String apiKeyID}) {
    this.apiKeyID = apiKeyID;
    this.state = _generateState();
    var codeVerifier = RandomString.createCodeVerifier();
    this.codeVerifier = codeVerifier;
    this.codeChallenge =
        RandomString.createCodeChallegeFromVerifier(codeVerifier);
  }

  Future<bool> _checkIfUserExist(String identifier) async {
    API api = new API(apiKeyID: this.apiKeyID);
    try {
      User user = await api.getUserByIdentifier(identifier);
      if (user != null &&
          user.id != null &&
          user.id.length > 0 &&
          user.id != "00000000-0000-0000-0000-000000000000") {
        return true;
      }
    } catch (e) {
      if (e.toString() == "User already exists") {
        return true;
      }
    }
    return false;
  }

  // ======= Email Verification ========
  Future<User> signUpWithEmail({
    @required String redirectURL,
    String email,
  }) async {
    var url = this
        ._constructURLPath(identifierType: EmailType, redirectURL: redirectURL);
    if (email != null && email.length > 0) {
      if (await this._checkIfUserExist(email)) {
        throw "User already exists";
      }
      url = this._constructURLPathWithInput(
          identifier: email,
          identifierType: EmailType,
          redirectURL: redirectURL);
    }

    final result = await WebAuth.startWebAuth(url, redirectURL);

    return await this._processRedirectURL(result, redirectURL);
  }

  Future<User> verifyEmail({
    @required String redirectURL,
    @required String email,
  }) async {
    var url = this._constructURLPathWithInput(
        identifier: email, identifierType: EmailType, redirectURL: redirectURL);

    final result = await WebAuth.startWebAuth(url, redirectURL);

    return await this._processRedirectURL(result, redirectURL);
  }

  // ======= Phone Verification ========
  Future<User> signUpWithPhone({
    @required String redirectURL,
    List<PhoneChannel> phoneChannels = DefaultPhoneChannels,
  }) async {
    var url = this._constructURLPath(
        identifierType: PhoneType,
        redirectURL: redirectURL,
        phoneChannels: phoneChannels);
      
    final result = await WebAuth.startWebAuth(url, redirectURL);

    return await this._processRedirectURL(result, redirectURL);
  }

  Future<User> signUpWithPhoneViaSMS({
    @required String redirectURL,
    @required String phone,
  }) async {
    if (await this._checkIfUserExist(phone)) {
      throw "User already exists";
    }
    return verifyPhone(
        redirectURL: redirectURL, phone: phone, channel: PhoneChannel.SMS);
  }

  Future<User> signUpWithPhoneViaWhatsApp({
    @required String redirectURL,
    @required String phone,
  }) async {
    if (await this._checkIfUserExist(phone)) {
      throw "User already exists";
    }
    return verifyPhone(
        redirectURL: redirectURL, phone: phone, channel: PhoneChannel.WHATSAPP);
  }

  Future<User> verifyPhone({
    @required String redirectURL,
    @required String phone,
    @required PhoneChannel channel,
  }) async {
    var url = this._constructURLPathWithInput(
        identifier: phone,
        identifierType: PhoneType,
        redirectURL: redirectURL,
        channel: channel);
    
    final result = await WebAuth.startWebAuth(url, redirectURL);

    return await this._processRedirectURL(result, redirectURL);
  }

  Future<User> _processRedirectURL(String result, String redirectURL) async {
    // Parse redirect URL
    var uri = Uri.parse(result);
    if (!uri.queryParameters.containsKey("state") ||
        !uri.queryParameters.containsKey("challenge_id") ||
        !uri.queryParameters.containsKey("code")) {
      throw "Redirect URL is invalid, it doesn't contain one of the following parameters: state, challenge_id, code";
    }
    var state = uri.queryParameters["state"];
    if (this.state != state) {
      throw "State from the in-app browser is not the same as the original state.";
    }

    var challengeID = uri.queryParameters["challenge_id"];
    var code = uri.queryParameters["code"];

    // Call Get Identity with authorization code
    API api = new API(apiKeyID: this.apiKeyID);
    var resp = await api.getIdentity(
        code, state, challengeID, this.codeVerifier, redirectURL);

    User user = User.fromJson(resp["user"]);
    await user.store();
    OAuthToken oAuthToken = OAuthToken.fromJson(resp["oauth_token"]);
    await oAuthToken.store();
    return user;
  }

  String _generateState() {
    return RandomString.getRandomString(VERIFICATION_STATE_LENGTH);
  }

  String _constructURLPath({
    @required String identifierType,
    @required String redirectURL,
    List<PhoneChannel> phoneChannels,
    String cotterUserID,
  }) {
    var url = "${Cotter.jsBaseURL}?api_key=${this.apiKeyID}";
    url = url + "&redirect_url=$redirectURL";
    url = url + "&type=$identifierType";
    url = url + "&code_challenge=${this.codeChallenge}";
    url = url + "&state=${this.state}";

    if (phoneChannels != null && phoneChannels.length > 0) {
      phoneChannels.forEach((c) =>
          (url = url + "&phone_channels[]=${c.toString().split('.').last}"));
    }
    if (cotterUserID != null && cotterUserID.length > 0) {
      url = url + "&cotter_user_id=$cotterUserID";
    }
    return url;
  }

  String _constructURLPathWithInput({
    @required String identifier,
    @required String identifierType,
    @required String redirectURL,
    String cotterUserID,
    PhoneChannel channel,
  }) {
    var url = _constructURLPath(
        identifierType: identifierType,
        redirectURL: redirectURL,
        cotterUserID: cotterUserID);
    url = url + "&direct_login=true";
    url = url + "&input=${Uri.encodeComponent(identifier)}";

    String channelStr = channel.toString().split('.').last;
    ;
    if (channelStr != null && channelStr.length > 0) {
      url = url + "&use_channel=$channelStr";
    }
    return url;
  }
}
