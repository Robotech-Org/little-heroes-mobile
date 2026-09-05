

import '../entities/otp_response.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhoneAndPassword {
  final AuthRepository repository;

  LoginWithPhoneAndPassword(this.repository);

  Future<OtpResponse> call({
    required String phoneNumber,
    required String password,
  }) {
    return repository.loginWithPhoneAndPassword(
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
