import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:little_heroes_mobile/core/network/cookie_storage.dart';
import 'package:little_heroes_mobile/core/services/storage_service.dart';

/// Global signal for "the session is dead, take the user to login".
///
/// `AuthInterceptor` calls [expireSession] on any 401/403. The call is
/// idempotent — a burst of parallel 401s only emits once.
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  final _expiredController = StreamController<void>.broadcast();
  Stream<void> get onSessionExpired => _expiredController.stream;

  bool _alreadyFired = false;

  Future<void> expireSession({String? reason}) async {
    if (_alreadyFired) return;
    _alreadyFired = true;

    debugPrint('🔒 Session expired: ${reason ?? "401/403 from server"}');

    // Wipe both the cookie jar and the local auth flags.
    await CookieStorage.clearAll();
    await StorageService.instance.logout();

    if (!_expiredController.isClosed) {
      _expiredController.add(null);
    }
  }

  /// Call after a successful login so the next expiry can fire again.
  void reset() {
    _alreadyFired = false;
  }

  void dispose() {
    _expiredController.close();
  }
}
