

import '../entities/auth_user.dart';
import '../entities/otp_response.dart';

abstract class AuthRepository {
  Future<OtpResponse> loginWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  });

  Future<AuthUser> verifyOtp({
    required String tmpId,
    required String otp,
    required String phoneNumber,
  });

  Future<void> logout();
}
