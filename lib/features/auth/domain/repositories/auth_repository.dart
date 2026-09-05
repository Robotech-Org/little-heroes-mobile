import '../entities/otp_response.dart';

abstract class AuthRepository {
  Future<OtpResponse> sendOtp({
    required String phoneNumber,
  });
}