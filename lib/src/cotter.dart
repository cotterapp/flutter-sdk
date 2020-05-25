import 'package:cotter/src/handlers/verify.dart';
import 'package:meta/meta.dart';
import 'package:cotter/src/helper/enum.dart';

class Cotter {
  String apiKeyID;
  static String baseURL = CotterBaseURL;

  Cotter({@required this.apiKeyID});

  Future<bool> sendEmailWithCode({@required String email}) {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return verify.sendCode(identifier: email, identifierType: EmailType);
  }

  Future<Map<String, dynamic>> signInWithEmail(
      {@required String email, String code}) async {
    Verify verify = new Verify(apiKeyID: this.apiKeyID);
    return await verify.verifyCode(identifier: email, code: code);
  }

  static set url(String baseURL) {
    Cotter.baseURL = baseURL;
  }
}
