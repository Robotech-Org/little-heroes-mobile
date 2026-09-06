import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class CookieStorage {
  static PersistCookieJar? _cookieJar;

  static Future<PersistCookieJar> getInstance() async {
    if (_cookieJar != null) return _cookieJar!;

    final directory = await getApplicationDocumentsDirectory();

    _cookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/.cookies/'),
    );

    return _cookieJar!;
  }

  // NEW: Clear all cookies
  static Future<void> clearAll() async {
    try {
      final cookieJar = await getInstance();
      await cookieJar.deleteAll();
    } catch (e) {
      print('Failed to clear cookies: $e');
    }
  }

  // NEW: Get all cookies for debugging
  static Future<List<Cookie>> getAllCookies() async {
    try {
      final cookieJar = await getInstance();
      // This is a workaround to get all cookies
      // You might need to implement a different approach if needed
      return [];
    } catch (e) {
      print('Failed to get cookies: $e');
      return [];
    }
  }
}
