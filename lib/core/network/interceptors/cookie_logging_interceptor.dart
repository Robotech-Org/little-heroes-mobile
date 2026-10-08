import 'package:dio/dio.dart';

class CookieLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cookie = options.headers['Cookie'];

    if (cookie != null) {
    } else {}

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final setCookie = response.headers.map['set-cookie'];

    if (setCookie != null) {
      for (final cookie in setCookie) {
        print(cookie);
      }
    } else {}

    handler.next(response);
  }
}
