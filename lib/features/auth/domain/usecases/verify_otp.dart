
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<AuthUser> call({
    required String tmpId,
    required String otp,
    required String phoneNumber,
  }) {
    return repository.verifyOtp(
      tmpId: tmpId,
      otp: otp,
      phoneNumber: phoneNumber,
    );
  }
}
