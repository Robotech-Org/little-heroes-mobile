import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // TODO: Get access token from local storage
    // and add:
    // options.headers['Authorization'] = 'Bearer $token';

    handler.next(options);
  }
}