// import 'package:dio/dio.dart';

// class AuthInterceptor extends Interceptor {
//   @override
//   void onRequest(
//     RequestOptions options,
//     RequestInterceptorHandler handler,
//   ) {
//     // TODO: Get access token from local storage
//     // and add:
//     // options.headers['Authorization'] = 'Bearer $token';

//     handler.next(options);
//   }
// }

import 'package:dio/dio.dart';
import 'package:little_heroes_mobile/core/services/session_manager.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add bearer token here if you ever switch to token auth.
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;

    if (status == 401 || status == 403) {
      SessionManager.instance.expireSession(
        reason: 'HTTP $status on ${err.requestOptions.uri}',
      );
    }

    handler.next(err);
  }
}
