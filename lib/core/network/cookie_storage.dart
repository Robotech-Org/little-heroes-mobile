import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class CookieStorage {
  static PersistCookieJar? _cookieJar;

  static Future<PersistCookieJar> getInstance() async {
    if (_cookieJar != null) return _cookieJar!;

    final directory = await getApplicationDocumentsDirectory();

    _cookieJar = PersistCookieJar(
      storage: FileStorage(
        '${directory.path}/.cookies/',
      ),
    );

    return _cookieJar!;
  }
}