
// abstract class AuthEvent {}

// // ============================================================
// // LOGIN WITH PHONE + PASSWORD
// // ============================================================

// class LoginRequested extends AuthEvent {
//   final String phoneNumber;
//   final String password;

//   LoginRequested({required this.phoneNumber, required this.password});
// }

// // ============================================================
// // VERIFY OTP
// // ============================================================

// class VerifyOtpRequested extends AuthEvent {
//   final String tmpId;
//   final String otp;

//   VerifyOtpRequested({required this.tmpId, required this.otp});
// }


abstract class AuthEvent {}

// ============================================================
// LOGIN
// ============================================================

class LoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  LoginRequested({
    required this.phoneNumber,
    required this.password,
  });
}

// ============================================================
// VERIFY OTP
// ============================================================

class VerifyOtpRequested extends AuthEvent {
  final String tmpId;
  final String otp;
  final String phoneNumber;

  VerifyOtpRequested({
    required this.tmpId,
    required this.otp,
    required this.phoneNumber,
  });
}
