import 'package:dio/dio.dart';
import 'package:little_heroes_mobile/features/settings/data/models/user_profile_model.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/user_preferences_model.dart';

abstract class SettingsRemoteDataSource {
  Future<UserPreferencesModel> getPreferences();
  Future<UserPreferencesModel> updatePreferences(UserPreferencesModel prefs);
  Future<void> updateProfile({
    String? phoneNumber,
    String? emergencyPhone,
    String? userImage,
  });
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<UserProfileModel> getMyProfile();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio dio;
  SettingsRemoteDataSourceImpl(this.dio);

  /// Frappe wraps everything in `{ "message": ... }`.
  /// This strips that envelope so downstream code can read `success` / `data`.
  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is! Map) {
      throw Exception('Invalid response shape: $raw');
    }
    final map = Map<String, dynamic>.from(raw);
    final inner = map['message'];
    if (inner is Map) {
      return Map<String, dynamic>.from(inner);
    }
    return map;
  }

  @override
  Future<UserPreferencesModel> getPreferences() async {
    try {
      final response = await dio.get(ApiConstants.getPreferences);
      final body = _unwrap(response.data);

      if (body['success'] == true && body['data'] is Map) {
        return UserPreferencesModel.fromJson(
          Map<String, dynamic>.from(body['data']),
        );
      }
      throw Exception('Unexpected response: $body');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  @override
  Future<UserPreferencesModel> updatePreferences(
    UserPreferencesModel prefs,
  ) async {
    try {
      final response = await dio.put(
        ApiConstants.updatePreferences,
        data: prefs.toUpdatePayload(),
      );
      final body = _unwrap(response.data);

      if (body['success'] == true && body['data'] is Map) {
        return UserPreferencesModel.fromJson(
          Map<String, dynamic>.from(body['data']),
        );
      }
      throw Exception('Unexpected response: $body');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  // In SettingsRemoteDataSourceImpl:
  @override
  Future<UserProfileModel> getMyProfile() async {
    try {
      final response = await dio.get(ApiConstants.getMyProfile);
      final body = _unwrap(response.data);

      if (body['success'] == true && body['data'] is Map) {
        return UserProfileModel.fromJson(
          Map<String, dynamic>.from(body['data']),
        );
      }
      throw Exception('Unexpected response: $body');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  @override
  Future<void> updateProfile({
    String? phoneNumber,
    String? emergencyPhone,
    String? userImage,
  }) async {
    final payload = <String, dynamic>{};
    if (phoneNumber != null) payload['phone_number'] = phoneNumber;
    if (emergencyPhone != null) payload['emergency_phone'] = emergencyPhone;
    if (userImage != null) payload['user_image'] = userImage;
    if (payload.isEmpty) return;

    try {
      final response = await dio.put(ApiConstants.updateProfile, data: payload);
      final body = _unwrap(response.data);
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.changePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );
      final body = _unwrap(response.data);
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }
}
