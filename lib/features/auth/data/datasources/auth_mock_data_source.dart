import '../../../../core/constants/user_role.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/otp_response.dart';

class AuthMockDataSource {
  static const String testOtp = '123456';

  static const Map<String, UserRole> mockUsers = {
    '+251911111111': UserRole.parent,
    '+251922222222': UserRole.teacher,
    '+251933333333': UserRole.adviser,
  };

  Future<OtpResponse> sendOtp({
    required String phoneNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mockUsers.containsKey(phoneNumber)) {
      throw Exception(
        'This phone number is not registered. Please use a test account.',
      );
    }

    return OtpResponse(
      success: true,
      message: 'OTP sent successfully',
      phoneNumber: phoneNumber,
    );
  }

  Future<AuthUser> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (otp != testOtp) {
      throw Exception('Invalid verification code');
    }

    final role = mockUsers[phoneNumber];

    if (role == null) {
      throw Exception('User not found');
    }

    return AuthUser(
      phoneNumber: phoneNumber,
      role: role,
    );
  }
}