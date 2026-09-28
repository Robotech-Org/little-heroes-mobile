class PendingScan {
  final String studentId;
  final String qrPayload;
  final DateTime scannedAt;

  const PendingScan({
    required this.studentId,
    required this.qrPayload,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'qrPayload': qrPayload,
    'scannedAt': scannedAt.toIso8601String(),
  };

  factory PendingScan.fromMap(Map<String, dynamic> m) => PendingScan(
    studentId: m['studentId'] as String,
    qrPayload: m['qrPayload'] as String,
    scannedAt: DateTime.parse(m['scannedAt'] as String),
  );
}
