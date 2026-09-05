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
    required String phoneNumber,
    required String otp,
  });

  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  // LOGIN

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

      return OtpResponse(
        success: data['success'] ?? true,
        message: data['message'] ?? 'Login successful',
        phoneNumber: phoneNumber,
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    }
  }

  // REQUEST OTP

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
        message: data['message'] ?? 'OTP sent successfully',
        phoneNumber: phoneNumber,
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    }
  }

  // VERIFY OTP

  @override
  Future<AuthUser> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.verifyOtp,
        data: {'usr': phoneNumber, 'otp': otp},
      );

      final data = _extractResponse(response);

      return AuthUser(
        phoneNumber: data['usr'] ?? phoneNumber,
        role: _parseRole(data['role']),
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
    }
  }

  // RESET PASSWORD

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
    }
  }

  // RESPONSE EXTRACTION

  Map<String, dynamic> _extractResponse(Response<dynamic> response) {
    final responseData = response.data;

    if (responseData is Map<String, dynamic>) {
      // Frappe custom APIs commonly return:
      // { "message": { ... } }
      if (responseData['message'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(responseData['message']);
      }

      return responseData;
    }

    return {};
  }

  // ROLE PARSER

  UserRole _parseRole(dynamic role) {
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
