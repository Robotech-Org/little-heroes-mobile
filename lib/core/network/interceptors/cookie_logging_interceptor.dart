import 'package:dio/dio.dart';

class CookieLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cookie = options.headers['Cookie'];

    if (cookie != null) {
      // print('📤 Sending Cookie: $cookie');
    } else {
      // print('⚠️ No Cookie attached');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print('');
    // print('🍪 = COOKIE RESPONSE =');

    final setCookie = response.headers.map['set-cookie'];

    if (setCookie != null) {
      // print('📥 Set-Cookie received:');
      for (final cookie in setCookie) {
        print(cookie);
      }
    } else {
      // print('ℹ️ No Set-Cookie received');
    }

    // print('🍪 ===');

    handler.next(response);
  }
}
