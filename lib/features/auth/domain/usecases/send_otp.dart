import '../entities/otp_response.dart';
import '../repositories/auth_repository.dart';

class SendOtp {
  final AuthRepository repository;

  SendOtp(this.repository);

  Future<OtpResponse> call({required String phoneNumber}) {
    return repository.sendOtp(phoneNumber: phoneNumber);
  }
}
