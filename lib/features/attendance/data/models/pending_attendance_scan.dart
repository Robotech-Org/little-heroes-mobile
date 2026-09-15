class PendingAttendanceScan {
  final String studentId;
  final String qrPayload;
  final DateTime scannedAt;

  PendingAttendanceScan({
    required this.studentId,
    required this.qrPayload,
    required this.scannedAt,
  });

  /// Exact item shape inside `scans[]`.
  Map<String, dynamic> toRequestItem() => {
    'student_id': studentId,
    'qr_payload': qrPayload,
    'scanned_at': scannedAt.toUtc().toIso8601String(),
  };

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'qrPayload': qrPayload,
    'scannedAt': scannedAt.toIso8601String(),
  };

  factory PendingAttendanceScan.fromMap(Map<String, dynamic> map) {
    return PendingAttendanceScan(
      studentId: map['studentId'] as String,
      qrPayload: map['qrPayload'] as String,
      scannedAt: DateTime.parse(map['scannedAt'] as String),
    );
  }
}
