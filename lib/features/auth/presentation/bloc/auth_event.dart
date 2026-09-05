// abstract class AuthEvent {}

// class SendOtpRequested extends AuthEvent {
//   final String phoneNumber;

//   SendOtpRequested({required this.phoneNumber});
// }

// class VerifyOtpRequested extends AuthEvent {
//   final String phoneNumber;
//   final String otp;

//   VerifyOtpRequested({required this.phoneNumber, required this.otp});
// }


// ============================================================
// AUTH EVENTS
// ============================================================

abstract class AuthEvent {}

// ============================================================
// LOGIN WITH PHONE + PASSWORD
// ============================================================

class LoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  LoginRequested({required this.phoneNumber, required this.password});
}

// ============================================================
// VERIFY OTP
// ============================================================

class VerifyOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;

  VerifyOtpRequested({required this.phoneNumber, required this.otp});
}
