class OtpResponse {
  final bool success;
  final String message;
  final String phoneNumber;

  final String? tmpId;

  const OtpResponse({
    required this.success,
    required this.message,
    required this.phoneNumber,
    this.tmpId,
  });

  @override
  String toString() {
    return 'OtpResponse('
        'success: $success, '
        'message: $message, '
        'phoneNumber: $phoneNumber, '
        'tmpId: $tmpId'
        ')';
  }
}
