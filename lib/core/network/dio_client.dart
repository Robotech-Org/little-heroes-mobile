import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../constants/api_constants.dart';
import 'cookie_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient._(this.dio);

  static Future<DioClient> create() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final cookieJar = await CookieStorage.getInstance();

    // IMPORTANT: Cookie manager should be added
    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(AuthInterceptor());

    dio.interceptors.add(LoggingInterceptor());

    return DioClient._(dio);
  }
}
