import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<AuthUser> call({required String phoneNumber, required String otp}) {
    return repository.verifyOtp(phoneNumber: phoneNumber, otp: otp);
  }
}
