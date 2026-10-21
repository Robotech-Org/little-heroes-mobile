// import 'package:dio/dio.dart';
// import 'package:little_heroes_mobile/core/services/session_manager.dart';

// class AuthInterceptor extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     // Add bearer token here if you ever switch to token auth.
//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     final status = err.response?.statusCode;

//     if (status == 401 || status == 403) {
//       SessionManager.instance.expireSession(
//         reason: 'HTTP $status on ${err.requestOptions.uri}',
//       );
//     }

//     handler.next(err);
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:little_heroes_mobile/core/constants/api_constants.dart';
import 'package:little_heroes_mobile/core/services/session_manager.dart';

class AuthInterceptor extends Interceptor {
  /// Auth endpoints — a 401 here means "wrong credentials", not "session dead".
  /// Using the constants (not string matching) so any URL change stays in sync.
  static final Set<String> _authEndpoints = {
    ApiConstants.login,
    ApiConstants.requestOtp,
    ApiConstants.verifyOtp,
    ApiConstants.resetPassword,
    ApiConstants.changePassword,
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;

    if (status == 401 || status == 403) {
      final path = err.requestOptions.path;

      // Exact-prefix match against known auth paths.
      final isAuthEndpoint = _authEndpoints.any(
        (endpoint) => path.startsWith(endpoint),
      );

      if (isAuthEndpoint) {
        debugPrint('🚫 Auth endpoint 401 — NOT a session expiry: $path');
      } else {
        debugPrint('🔒 Real session expiry: $path');
        SessionManager.instance.expireSession(
          reason: 'HTTP $status on ${err.requestOptions.uri}',
        );
      }
    }

    handler.next(err);
  }
}
