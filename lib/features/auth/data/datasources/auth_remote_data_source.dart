import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/user_role.dart';
import '../../../../core/error/dio_error_handler.dart';
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

      ;

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
