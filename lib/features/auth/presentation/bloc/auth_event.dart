abstract class AuthEvent {}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  SendOtpRequested({required this.phoneNumber});
}

class VerifyOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;

  VerifyOtpRequested({required this.phoneNumber, required this.otp});
}
