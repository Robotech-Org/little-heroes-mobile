// class OtpResponse {
//   final bool success;
//   final String message;
//   final String phoneNumber;

//   final String? tmpId;

//   const OtpResponse({
//     required this.success,
//     required this.message,
//     required this.phoneNumber,
//     this.tmpId,
//   });

//   @override
//   String toString() {
//     return 'OtpResponse('
//         'success: $success, '
//         'message: $message, '
//         'phoneNumber: $phoneNumber, '
//         'tmpId: $tmpId'
//         ')';
//   }
// }

import 'auth_user.dart';

class OtpResponse {
  final bool success;
  final String message;
  final String phoneNumber;

  /// Present when OTP is required.
  final String? tmpId;

  /// Present when OTP is OFF — backend returns user directly.
  final AuthUser? user;

  const OtpResponse({
    required this.success,
    required this.message,
    required this.phoneNumber,
    this.tmpId,
    this.user,
  });

  /// True → OTP page should be shown.
  /// False → log in directly (skip OTP).
  bool get needsOtp => tmpId != null && tmpId!.isNotEmpty;

  @override
  String toString() {
    return 'OtpResponse('
        'success: $success, '
        'message: $message, '
        'phoneNumber: $phoneNumber, '
        'tmpId: $tmpId, '
        'user: $user'
        ')';
  }
}
