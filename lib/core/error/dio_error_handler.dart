import 'dart:convert';

import 'package:dio/dio.dart';

import 'exceptions.dart';

class DioErrorHandler {
  DioErrorHandler._();

  // MAIN ERROR HANDLER

  static Never handle(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = _extractMessage(error);

    switch (error.type) {
      // TIMEOUT ERRORS

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        throw TimeoutException(
          message ?? 'The request timed out. Please try again.',
        );

      // NO INTERNET / CONNECTION FAILED

      case DioExceptionType.connectionError:
        throw NetworkException(
          message ??
              'Unable to connect to the server. '
                  'Please check your internet connection.',
        );

      // BAD HTTP RESPONSE

      case DioExceptionType.badResponse:
        return _handleStatusCode(statusCode, message);

      // REQUEST CANCELLED

      case DioExceptionType.cancel:
        throw UnknownException('The request was cancelled.');

      // BAD SSL CERTIFICATE

      case DioExceptionType.badCertificate:
        throw UnknownException(
          message ?? 'Unable to verify the server certificate.',
        );

      // UNKNOWN ERROR

      case DioExceptionType.unknown:
        throw UnknownException(
          message ?? 'Something went wrong. Please try again.',
        );
    }
  }

  // HTTP STATUS CODE HANDLER

  static Never _handleStatusCode(int? statusCode, String? message) {
    switch (statusCode) {
      case 400:
        throw ValidationException(message ?? 'Invalid request.');

      case 401:
        throw UnauthorizedException(
          message ?? 'Your session has expired. Please login again.',
        );

      case 403:
        throw UnauthorizedException(
          message ?? 'You do not have permission to perform this action.',
        );

      case 404:
        throw NotFoundException(
          message ?? 'The requested resource was not found.',
        );

      case 408:
        throw TimeoutException(message ?? 'The request timed out.');

      case 409:
        throw ValidationException(
          message ?? 'The request conflicts with existing data.',
        );

      case 422:
        throw ValidationException(message ?? 'Invalid data provided.');

      case 429:
        throw ServerException(
          message ?? 'Too many requests. Please try again later.',
          statusCode: statusCode,
        );

      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        throw ServerException(
          message ?? 'Server error. Please try again later.',
          statusCode: statusCode,
        );

      default:
        throw ServerException(
          message ?? 'Something went wrong.',
          statusCode: statusCode,
        );
    }
  }

  // EXTRACT ERROR MESSAGE

  static String? _extractMessage(DioException error) {
    final data = error.response?.data;

    if (data == null) {
      return null;
    }

    // MAP RESPONSE

    if (data is Map<String, dynamic>) {
      // Standard custom API message
      if (data['message'] is String && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }

      // Frappe exception
      if (data['exception'] != null) {
        return _cleanFrappeException(data['exception'].toString());
      }

      // Frappe server messages
      if (data['_server_messages'] != null) {
        return _parseServerMessages(data['_server_messages']);
      }

      // Common error field
      if (data['error'] != null) {
        return data['error'].toString();
      }

      // Detail field
      if (data['detail'] != null) {
        return data['detail'].toString();
      }
    }

    // STRING RESPONSE

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }

  // CLEAN FRAPPE EXCEPTION

  static String _cleanFrappeException(String exception) {
    // Example:
    //
    // frappe.exceptions.ValidationError: Invalid OTP
    //
    // Returns:
    //
    // Invalid OTP

    final parts = exception.split(':');

    if (parts.length > 1) {
      return parts.last.trim();
    }

    return exception;
  }

  // PARSE FRAPPE SERVER MESSAGES

  static String? _parseServerMessages(dynamic serverMessages) {
    try {
      dynamic messages = serverMessages;

      // Frappe sometimes returns JSON as String
      if (messages is String) {
        try {
          messages = jsonDecode(messages);
        } catch (_) {
          return messages;
        }
      }

      // Frappe usually returns:
      //
      // [
      //   "{\"message\":\"Invalid OTP\",\"indicator\":\"red\"}"
      // ]

      if (messages is List && messages.isNotEmpty) {
        final firstMessage = messages.first;

        if (firstMessage is String) {
          try {
            final decoded = jsonDecode(firstMessage);

            if (decoded is Map && decoded['message'] != null) {
              return decoded['message'].toString();
            }

            return firstMessage;
          } catch (_) {
            return firstMessage;
          }
        }

        if (firstMessage is Map && firstMessage['message'] != null) {
          return firstMessage['message'].toString();
        }

        return firstMessage.toString();
      }

      if (messages is Map && messages['message'] != null) {
        return messages['message'].toString();
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
