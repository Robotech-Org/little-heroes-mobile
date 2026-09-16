class PendingAttendanceScan {
  final String studentId; // kept for local display + dedup
  final String qrPayload;
  final DateTime scannedAt;

  PendingAttendanceScan({
    required this.studentId,
    required this.qrPayload,
    required this.scannedAt,
  });

  /// Exact item shape inside `scans[]`.
  Map<String, dynamic> toRequestItem() => {
    'qr_payload': qrPayload,
    'scanned_at': _fmtLocal(scannedAt),
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

  /// Frappe typically parses `YYYY-MM-DD HH:mm:ss` — send local time in that format.
  static String _fmtLocal(DateTime dt) {
    final l = dt.toLocal();
    final y = l.year.toString().padLeft(4, '0');
    final mo = l.month.toString().padLeft(2, '0');
    final d = l.day.toString().padLeft(2, '0');
    final h = l.hour.toString().padLeft(2, '0');
    final mi = l.minute.toString().padLeft(2, '0');
    final s = l.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:$s';
  }
}
