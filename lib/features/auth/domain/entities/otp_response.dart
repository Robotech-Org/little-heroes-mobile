class OtpResponse {
  final bool success;
  final String message;
  final String phoneNumber;

  const OtpResponse({
    required this.success,
    required this.message,
    required this.phoneNumber,
  });
}
