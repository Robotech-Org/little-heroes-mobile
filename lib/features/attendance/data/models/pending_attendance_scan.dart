class PendingAttendanceScan {
  final String studentId;
  final String qrPayload;
  final DateTime scannedAt;

  /// True once the server has accepted this scan.
  final bool synced;

  /// Populated only when the server rejected this scan.
  final String? failureReason;

  PendingAttendanceScan({
    required this.studentId,
    required this.qrPayload,
    required this.scannedAt,
    this.synced = false,
    this.failureReason,
  });

  bool get hasFailed => failureReason != null;

  /// True if this scan still needs to be sent to the server.
  bool get isPending => !synced || hasFailed;

  PendingAttendanceScan copyWith({
    String? studentId,
    String? qrPayload,
    DateTime? scannedAt,
    bool? synced,
    String? failureReason,
    bool clearFailure = false,
  }) {
    return PendingAttendanceScan(
      studentId: studentId ?? this.studentId,
      qrPayload: qrPayload ?? this.qrPayload,
      scannedAt: scannedAt ?? this.scannedAt,
      synced: synced ?? this.synced,
      failureReason: clearFailure
          ? null
          : (failureReason ?? this.failureReason),
    );
  }

  Map<String, dynamic> toRequestItem() => {
    'qr_payload': qrPayload,
    'scanned_at': _fmtLocal(scannedAt),
  };

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'qrPayload': qrPayload,
    'scannedAt': scannedAt.toIso8601String(),
    'synced': synced,
    if (failureReason != null) 'failureReason': failureReason,
  };

  factory PendingAttendanceScan.fromMap(Map<String, dynamic> map) {
    return PendingAttendanceScan(
      studentId: map['studentId'] as String,
      qrPayload: map['qrPayload'] as String,
      scannedAt: DateTime.parse(map['scannedAt'] as String),
      synced: map['synced'] as bool? ?? false,
      failureReason: map['failureReason']?.toString(),
    );
  }

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
