import '../../../../core/constants/user_role.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/otp_response.dart';

class AuthMockDataSource {
  static const String testOtp = '123456';

  static const Map<String, MockUser> mockUsers = {
    '+251911111111': MockUser(password: '123456', role: UserRole.parent),

    '+251922222222': MockUser(password: '123456', role: UserRole.teacher),

    '+251933333333': MockUser(password: '123456', role: UserRole.adviser),
  };

  // ============================================================
  // LOGIN WITH PHONE + PASSWORD
  // ============================================================

  Future<OtpResponse> loginWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = mockUsers[phoneNumber];

    // ----------------------------------------------------------
    // PHONE NOT FOUND
    // ----------------------------------------------------------

    if (user == null) {
      throw Exception('This phone number is not registered.');
    }

    // ----------------------------------------------------------
    // PASSWORD INCORRECT
    // ----------------------------------------------------------

    if (user.password != password) {
      throw Exception('Incorrect password.');
    }

    // ----------------------------------------------------------
    // SUCCESS → SEND OTP
    // ----------------------------------------------------------

    return OtpResponse(
      success: true,
      message: 'OTP sent successfully',
      phoneNumber: phoneNumber,
    );
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<AuthUser> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // ----------------------------------------------------------
    // VALIDATE OTP
    // ----------------------------------------------------------

    if (otp != testOtp) {
      throw Exception('Invalid verification code');
    }

    // ----------------------------------------------------------
    // GET USER
    // ----------------------------------------------------------

    final user = mockUsers[phoneNumber];

    if (user == null) {
      throw Exception('User not found');
    }

    // ----------------------------------------------------------
    // AUTHENTICATED USER
    // ----------------------------------------------------------

    return AuthUser(phoneNumber: phoneNumber, role: user.role);
  }
}

// ================================================================
// MOCK USER MODEL
// ================================================================

class MockUser {
  final String password;
  final UserRole role;

  const MockUser({required this.password, required this.role});
}
