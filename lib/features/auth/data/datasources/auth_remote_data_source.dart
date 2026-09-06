// import 'package:dio/dio.dart';
// import 'package:dio_cookie_manager/dio_cookie_manager.dart';

// import '../../../../core/constants/api_constants.dart';
// import '../../../../core/constants/user_role.dart';
// import '../../../../core/error/dio_error_handler.dart';
// import '../../domain/entities/auth_user.dart';
// import '../../domain/entities/otp_response.dart';

// abstract class AuthRemoteDataSource {
//   Future<OtpResponse> loginWithPhoneAndPassword({
//     required String phoneNumber,
//     required String password,
//   });

//   Future<OtpResponse> requestOtp({required String phoneNumber});

//   Future<AuthUser> verifyOtp({
//     required String tmpId,
//     required String otp,
//     required String phoneNumber,
//   });

//   Future<void> resetPassword({
//     required String phoneNumber,
//     required String newPassword,
//   });

//   Future<void> logout();

//   Future<void> changePassword({
//     required String oldPassword,
//     required String newPassword,
//   });
// }

// class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
//   final Dio dio;

//   AuthRemoteDataSourceImpl(this.dio);

//   // ============================================================
//   // LOGIN
//   // ============================================================

//   @override
//   Future<OtpResponse> loginWithPhoneAndPassword({
//     required String phoneNumber,
//     required String password,
//   }) async {
//     try {
//       final response = await dio.post(
//         ApiConstants.login,
//         data: {'usr': phoneNumber, 'pwd': password},
//       );

//       ;

//       final data = _extractResponse(response);

//       final tmpId = data['tmp_id']?.toString();

//       print('TMP ID: $tmpId');

//       final verification = data['verification'];

//       String message = 'OTP sent successfully';

//       if (verification is Map<String, dynamic>) {
//         message = verification['prompt']?.toString() ?? message;
//       } else if (data['message'] != null) {
//         message = data['message'].toString();
//       }

//       return OtpResponse(
//         success: true,
//         message: message,
//         phoneNumber: phoneNumber,
//         tmpId: tmpId,
//       );
//     } on DioException catch (e) {
//       DioErrorHandler.handle(e);
//       rethrow;
//     } catch (e, stackTrace) {
//       throw Exception(e.toString());
//     }
//   }

//   // ============================================================
//   // REQUEST OTP
//   // ============================================================

//   @override
//   Future<OtpResponse> requestOtp({required String phoneNumber}) async {
//     try {
//       final response = await dio.post(
//         ApiConstants.requestOtp,
//         data: {'usr': phoneNumber},
//       );

//       final data = _extractResponse(response);

//       return OtpResponse(
//         success: data['success'] ?? true,
//         message: data['message']?.toString() ?? 'OTP sent successfully',
//         phoneNumber: phoneNumber,
//         tmpId: data['tmp_id']?.toString(),
//       );
//     } on DioException catch (e) {
//       DioErrorHandler.handle(e);
//       rethrow;
//     }
//   }

//   @override
//   Future<AuthUser> verifyOtp({
//     required String tmpId,
//     required String otp,
//     required String phoneNumber,
//   }) async {
//     try {
//       final response = await dio.post(
//         ApiConstants.verifyOtp,
//         data: {'tmp_id': tmpId, 'otp': otp},
//       );

//       final data = _extractResponse(response);

//       final fullName = data['full_name']?.toString() ?? '';

//       final roles = data['roles'] ?? data['role'];

//       final role = _parseRole(roles);

//       return AuthUser(phoneNumber: phoneNumber, fullName: fullName, role: role);
//     } on DioException catch (e) {
//       DioErrorHandler.handle(e);
//       rethrow;
//     }
//   }

//   // ============================================================
//   // RESET PASSWORD
//   // ============================================================

//   @override
//   Future<void> resetPassword({
//     required String phoneNumber,
//     required String newPassword,
//   }) async {
//     try {
//       await dio.post(
//         ApiConstants.resetPassword,
//         data: {'usr': phoneNumber, 'new_password': newPassword},
//       );
//     } on DioException catch (e) {
//       DioErrorHandler.handle(e);
//       rethrow;
//     }
//   }

//   // ============================================================
//   // CHANGE PASSWORD - NEW
//   // ============================================================

//   @override
//   Future<void> changePassword({
//     required String oldPassword,
//     required String newPassword,
//   }) async {
//     try {
//       final response = await dio.post(
//         ApiConstants.changePassword,
//         data: {'old_password': oldPassword, 'new_password': newPassword},
//       );

//       print('Change password response: ${response.data}');
//     } on DioException catch (e) {
//       DioErrorHandler.handle(e);
//       rethrow;
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }

//   // ============================================================
//   // LOGOUT
//   // ============================================================

//   @override
//   Future<void> logout() async {
//     try {
//       // Call logout API
//       await dio.post(ApiConstants.logout);
//     } on DioException catch (e) {
//       // Even if API fails, we should still clear local data
//       print('Logout API error: ${e.message}');
//       // Don't rethrow - we want to clear local data anyway
//     } catch (e) {
//       print('Logout error: $e');
//       // Don't rethrow - we want to clear local data anyway
//     } finally {
//       // Always clear cookies regardless of API response
//       await _clearCookies();
//     }
//   }

//   // ============================================================
//   // CLEAR COOKIES
//   // ============================================================

//   Future<void> _clearCookies() async {
//     try {
//       // Get cookie manager interceptor
//       final cookieManager = dio.interceptors.firstWhere(
//         (interceptor) => interceptor is CookieManager,
//         orElse: () => throw Exception('CookieManager not found'),
//       ) as CookieManager;

//       // Clear all cookies
//       await cookieManager.cookieJar.deleteAll();

//       print('🍪 Cookies cleared successfully');
//     } catch (e) {
//       print('Failed to clear cookies: $e');
//     }
//   }
//   // ============================================================
//   // RESPONSE EXTRACTION
//   // ============================================================

//   Map<String, dynamic> _extractResponse(Response<dynamic> response) {
//     final responseData = response.data;

//     if (responseData is Map<String, dynamic>) {
//       if (responseData['message'] is Map<String, dynamic>) {
//         return Map<String, dynamic>.from(responseData['message']);
//       }

//       return Map<String, dynamic>.from(responseData);
//     }

//     return {};
//   }

//   // ============================================================
//   // ROLE PARSER
//   // ============================================================

//   UserRole _parseRole(dynamic role) {
//     if (role is List && role.isNotEmpty) {
//       role = role.first;
//     }

//     final roleString = role?.toString().trim().toLowerCase();

//     switch (roleString) {
//       case 'teacher':
//         return UserRole.teacher;

//       case 'adviser':
//       case 'advisor':
//         return UserRole.adviser;

//       case 'parent':
//         return UserRole.parent;

//       default:
//         return UserRole.parent;
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/user_role.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../../../../core/network/cookie_storage.dart'; // ADD THIS
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/otp_response.dart';

abstract class AuthRemoteDataSource {
  Future<OtpResponse> loginWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  });

  Future<OtpResponse> requestOtp({required String phoneNumber});

  Future<AuthUser> verifyOtp({
    required String tmpId,
    required String otp,
    required String phoneNumber,
  });

  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
  });

  Future<void> logout();

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  // ============================================================
  // LOGIN
  // ============================================================

  @override
  Future<OtpResponse> loginWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {'usr': phoneNumber, 'pwd': password},
      );

      final data = _extractResponse(response);

      final tmpId = data['tmp_id']?.toString();

      print('TMP ID: $tmpId');

      final verification = data['verification'];

      String message = 'OTP sent successfully';

      if (verification is Map<String, dynamic>) {
        message = verification['prompt']?.toString() ?? message;
      } else if (data['message'] != null) {
        message = data['message'].toString();
      }

      return OtpResponse(
        success: true,
        message: message,
        phoneNumber: phoneNumber,
        tmpId: tmpId,
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e, stackTrace) {
      throw Exception(e.toString());
    }
  }

  // ============================================================
  // REQUEST OTP
  // ============================================================

  @override
  Future<OtpResponse> requestOtp({required String phoneNumber}) async {
    try {
      final response = await dio.post(
        ApiConstants.requestOtp,
        data: {'usr': phoneNumber},
      );

      final data = _extractResponse(response);

      return OtpResponse(
        success: data['success'] ?? true,
        message: data['message']?.toString() ?? 'OTP sent successfully',
        phoneNumber: phoneNumber,
        tmpId: data['tmp_id']?.toString(),
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  @override
  Future<AuthUser> verifyOtp({
    required String tmpId,
    required String otp,
    required String phoneNumber,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.verifyOtp,
        data: {'tmp_id': tmpId, 'otp': otp},
      );

      // DEBUG: Check cookies after login
      await _debugCookies();

      final data = _extractResponse(response);

      final fullName = data['full_name']?.toString() ?? '';

      final roles = data['roles'] ?? data['role'];

      final role = _parseRole(roles);

      return AuthUser(phoneNumber: phoneNumber, fullName: fullName, role: role);
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    try {
      await dio.post(
        ApiConstants.resetPassword,
        data: {'usr': phoneNumber, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // DEBUG: Check cookies before request
      await _debugCookies();

      print('🔐 Changing password...');
      print('🔐 Old password length: ${oldPassword.length}');
      print('🔐 New password length: ${newPassword.length}');

      final response = await dio.post(
        ApiConstants.changePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );

      print('✅ Change password response: ${response.data}');
    } on DioException catch (e) {
      print('❌ Change password error: ${e.message}');
      print('❌ Error response: ${e.response?.data}');
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  @override
  Future<void> logout() async {
    try {
      // DEBUG: Check cookies before logout
      await _debugCookies();

      // Call logout API
      final response = await dio.post(ApiConstants.logout);
      print('✅ Logout response: ${response.data}');
    } on DioException catch (e) {
      // Even if API fails, we should still clear local data
      print('Logout API error: ${e.message}');
      // Don't rethrow - we want to clear local data anyway
    } catch (e) {
      print('Logout error: $e');
      // Don't rethrow - we want to clear local data anyway
    } finally {
      // Always clear cookies regardless of API response
      await _clearCookies();
    }
  }

  // ============================================================
  // CLEAR COOKIES
  // ============================================================

  Future<void> _clearCookies() async {
    try {
      // Use CookieStorage to clear all cookies
      await CookieStorage.clearAll();
      print('🍪 Cookies cleared successfully');
    } catch (e) {
      print('Failed to clear cookies: $e');
    }
  }

  // ============================================================
  // DEBUG - CHECK COOKIES
  // ============================================================

  Future<void> _debugCookies() async {
    try {
      final cookieJar = await CookieStorage.getInstance();

      // Load cookies for the base URL
      final cookies = await cookieJar.loadForRequest(
        Uri.parse(ApiConstants.baseUrl),
      );

      print('🍪 ===== CURRENT COOKIES =====');
      if (cookies.isEmpty) {
        print('🍪 No cookies found');
      } else {
        for (var cookie in cookies) {
          print('🍪 ${cookie.name}: ${cookie.value}');
          if (cookie.expires != null) {
            print('   Expires: ${cookie.expires}');
          }
          print('   HttpOnly: ${cookie.httpOnly}');
          print('   Domain: ${cookie.domain}');
        }
      }
      print('🍪 ===========================');
    } catch (e) {
      print('Failed to get cookies: $e');
    }
  }

  // ============================================================
  // RESPONSE EXTRACTION
  // ============================================================

  Map<String, dynamic> _extractResponse(Response<dynamic> response) {
    final responseData = response.data;

    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(responseData['message']);
      }

      return Map<String, dynamic>.from(responseData);
    }

    return {};
  }

  // ============================================================
  // ROLE PARSER
  // ============================================================

  UserRole _parseRole(dynamic role) {
    if (role is List && role.isNotEmpty) {
      role = role.first;
    }

    final roleString = role?.toString().trim().toLowerCase();

    switch (roleString) {
      case 'teacher':
        return UserRole.teacher;

      case 'adviser':
      case 'advisor':
        return UserRole.adviser;

      case 'parent':
        return UserRole.parent;

      default:
        return UserRole.parent;
    }
  }
}
