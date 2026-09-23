// import 'package:dio/dio.dart';

// class LoggingInterceptor extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     handler.next(options);
//   }

//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     handler.next(response);
//   }

//   @override
//   void onError(DioException error, ErrorInterceptorHandler handler) {
//     print('Error: ${error.message}');

//     handler.next(error);
//   }
// }

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    this.maxBodyChars = 3000,
    this.hiddenHeaders = const {'authorization', 'cookie', 'set-cookie'},
  });

  final int maxBodyChars;
  final Set<String> hiddenHeaders;

  // ═══════════════════════════════════════════════════════════
  // REQUEST
  // ═══════════════════════════════════════════════════════════
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final b = StringBuffer()
        ..writeln('┌──────────────────────── REQUEST ────────────────────────')
        ..writeln('│ ${options.method}  ${options.uri}')
        ..writeln('├─────────────────────────────────────────────────────────');

      if (options.headers.isNotEmpty) {
        b.writeln('│ Headers:');
        options.headers.forEach((k, v) {
          final shown = hiddenHeaders.contains(k.toLowerCase()) ? '***' : v;
          b.writeln('│   $k: $shown');
        });
      }

      if (options.queryParameters.isNotEmpty) {
        b.writeln('│ Query:');
        options.queryParameters.forEach((k, v) {
          b.writeln('│   $k: $v');
        });
      }

      if (options.data != null) {
        b.writeln('│ Body:');
        b.writeln('│   ${_pretty(options.data)}');
      }

      b.write('└─────────────────────────────────────────────────────────');
      debugPrint(b.toString());
    }
    handler.next(options);
  }

  // ═══════════════════════════════════════════════════════════
  // RESPONSE
  // ═══════════════════════════════════════════════════════════
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final b = StringBuffer()
        ..writeln('┌──────────────────────── RESPONSE ───────────────────────')
        ..writeln('│ ✅ ${response.statusCode}  ${response.requestOptions.uri}')
        ..writeln('├─────────────────────────────────────────────────────────')
        ..writeln('│ Body:')
        ..writeln('│   ${_pretty(response.data)}')
        ..write('└─────────────────────────────────────────────────────────');
      debugPrint(b.toString());
    }
    handler.next(response);
  }

  // ═══════════════════════════════════════════════════════════
  // ERROR
  // ═══════════════════════════════════════════════════════════
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final b = StringBuffer()
        ..writeln('┌────────────────────────── ERROR ────────────────────────')
        ..writeln(
          '│ ❌ ${err.response?.statusCode ?? '-'}  ${err.requestOptions.uri}',
        )
        ..writeln('├─────────────────────────────────────────────────────────')
        ..writeln('│ Type   : ${err.type}')
        ..writeln('│ Message: ${err.message}');

      if (err.response?.data != null) {
        b.writeln('│ Body:');
        b.writeln('│   ${_pretty(err.response?.data)}');
      }

      b.write('└─────────────────────────────────────────────────────────');
      debugPrint(b.toString());
    }
    handler.next(err);
  }

  // ═══════════════════════════════════════════════════════════
  // Pretty-printer
  // ═══════════════════════════════════════════════════════════
  String _pretty(dynamic data) {
    if (data == null) return 'null';
    try {
      dynamic value = data;

      // If it's a JSON string, try to decode for pretty output
      if (value is String) {
        try {
          value = jsonDecode(value);
        } catch (_) {
          // not JSON, leave as string
        }
      }

      String out;
      if (value is Map || value is List) {
        out = const JsonEncoder.withIndent('  ').convert(value);
      } else {
        out = value.toString();
      }

      // Indent every line so it aligns with the box
      final indented = out.split('\n').map((line) => '│   $line').join('\n');

      if (indented.length > maxBodyChars) {
        return '${indented.substring(0, maxBodyChars)}\n│   ... [truncated ${indented.length - maxBodyChars} chars]';
      }
      return indented;
    } catch (e) {
      return '<unable to stringify: $e>';
    }
  }
}
