import 'package:little_heroes_mobile/core/constants/api_constants.dart';

class UrlHelper {
  UrlHelper._();

  static String resolve(String? path) {
    if (path == null) return '';
    final trimmed = path.trim();
    if (trimmed.isEmpty) return '';

    // Already absolute
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // Protocol-relative
    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }

    // Ensure a single slash between base and path
    final base = ApiConstants.baseUrl.endsWith('/')
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
        : ApiConstants.baseUrl;

    final suffix = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$suffix';
  }
}
