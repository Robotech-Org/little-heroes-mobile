import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    print('Error: ${error.message}');

    handler.next(error);
  }
}

// lib/core/network/interceptors/logging_interceptor.dart

// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';

// class LoggingInterceptor extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     debugPrint('┌── 📤 REQUEST ─────────────────────────────');
//     debugPrint('│ ${options.method} ${options.uri}');
//     debugPrint('│ Headers: ${options.headers}');
//     if (options.queryParameters.isNotEmpty) {
//       debugPrint('│ Query: ${options.queryParameters}');
//     }
//     if (options.data != null) {
//       debugPrint('│ Body: ${_formatBody(options.data)}');
//     }
//     debugPrint('└───────────────────────────────────────────');
//     handler.next(options);
//   }

//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     debugPrint('┌── 📥 RESPONSE ────────────────────────────');
//     debugPrint(
//       '│ ${response.statusCode} '
//       '${response.requestOptions.method} '
//       '${response.requestOptions.uri}',
//     );
//     if (response.data != null) {
//       debugPrint('│ Body: ${_formatBody(response.data)}');
//     }
//     debugPrint('└───────────────────────────────────────────');
//     handler.next(response);
//   }

//   @override
//   void onError(DioException error, ErrorInterceptorHandler handler) {
//     debugPrint('┌── ❌ ERROR ───────────────────────────────');
//     debugPrint(
//       '│ ${error.requestOptions.method} '
//       '${error.requestOptions.uri}',
//     );
//     debugPrint('│ Type: ${error.type}');
//     if (error.response != null) {
//       debugPrint('│ Status: ${error.response!.statusCode}');
//       if (error.response!.data != null) {
//         debugPrint('│ Body: ${_formatBody(error.response!.data)}');
//       }
//     }
//     debugPrint('│ Message: ${error.message}');
//     debugPrint('└───────────────────────────────────────────');
//     handler.next(error);
//   }

//   String _formatBody(dynamic data) {
//     String text;
//     if (data is Map || data is List) {
//       try {
//         text = const JsonEncoder.withIndent('  ').convert(data);
//       } catch (_) {
//         text = data.toString();
//       }
//     } else {
//       text = data.toString();
//     }
//     if (text.length > 1500) {
//       text = '${text.substring(0, 1500)}… [truncated]';
//     }
//     return text;
//   }
// }
