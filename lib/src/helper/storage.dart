import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

class Storage {
// Create storage
  static final storage = new FlutterSecureStorage();

  static write({@required String key, @required String value}) async {
    await storage.write(key: key, value: value);
  }

  static Future<String> read({@required String key}) async {
    String value = await storage.read(key: key);
    return value;
  }

  static delete({@required String key}) async {
    await storage.delete(key: key);
  }
}
