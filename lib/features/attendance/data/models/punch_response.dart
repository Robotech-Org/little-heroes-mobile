class PunchResponse {
  final bool success;
  final String message;
  final int successCount;
  final int failedCount;
  final List<PunchItem> successfulScans;
  final List<PunchItem> failedScans;

  const PunchResponse({
    required this.success,
    required this.message,
    required this.successCount,
    required this.failedCount,
    required this.successfulScans,
    required this.failedScans,
  });

  factory PunchResponse.fromJson(Map<String, dynamic> json) {
    // Handle `{data: {...}}` or `{message: {data: {...}}}`
    final data = json['data'] ?? json['message']?['data'] ?? json;

    return PunchResponse(
      success: json['success'] == true || data['success'] == true,
      message: (json['message'] ?? '').toString(),
      successCount: (data['success_count'] as num?)?.toInt() ?? 0,
      failedCount: (data['failed_count'] as num?)?.toInt() ?? 0,
      successfulScans: ((data['successful_scans'] as List?) ?? [])
          .map((e) => PunchItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      failedScans: ((data['failed_scans'] as List?) ?? [])
          .map((e) => PunchItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class PunchItem {
  final String name;
  final String studentId;
  final String studentName;
  final String punchType;
  final String? qrPayload;
  final String? reason;

  const PunchItem({
    required this.name,
    required this.studentId,
    required this.studentName,
    required this.punchType,
    this.qrPayload,
    this.reason,
  });

  factory PunchItem.fromJson(Map<String, dynamic> m) => PunchItem(
    name: m['name']?.toString() ?? '',
    studentId: (m['student'] ?? m['student_id'])?.toString() ?? '',
    studentName: m['student_name']?.toString() ?? '',
    punchType: m['punch_type']?.toString() ?? '',
    qrPayload: m['qr_payload']?.toString(),
    reason: m['reason']?.toString(),
  );
}
