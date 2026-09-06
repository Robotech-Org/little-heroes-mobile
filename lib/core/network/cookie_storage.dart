import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class CookieStorage {
  static PersistCookieJar? _cookieJar;

  static Future<PersistCookieJar> getInstance() async {
    if (_cookieJar != null) return _cookieJar!;

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/.cookies/';

    _cookieJar = PersistCookieJar(
      storage: FileStorage(path),
      ignoreExpires: false,
    );

    return _cookieJar!;
  }

  static Future<void> clearAll() async {
    try {
      final cookieJar = await getInstance();
      await cookieJar.deleteAll();
    } catch (e) {
      // Silent fail
    }
  }
}
