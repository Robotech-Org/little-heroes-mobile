abstract class AuthEvent {}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  SendOtpRequested({required this.phoneNumber});
}
