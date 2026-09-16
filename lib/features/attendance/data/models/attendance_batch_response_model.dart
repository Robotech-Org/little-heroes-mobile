class AttendanceBatchResponse {
  final bool success;
  final String message;
  final int successCount;
  final int failedCount;
  final List<BatchItemResult> successfulScans;
  final List<BatchItemResult> failedScans;
  final String? geofenceStatus; // "Inside" | "Outside"
  final String? validationStatus; // "Accepted" | "Rejected"

  AttendanceBatchResponse({
    required this.success,
    required this.message,
    required this.successCount,
    required this.failedCount,
    required this.successfulScans,
    required this.failedScans,
    this.geofenceStatus,
    this.validationStatus,
  });

  factory AttendanceBatchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final successList = (data['successful_scans'] as List? ?? [])
        .map((e) => BatchItemResult.fromJson(e as Map<String, dynamic>))
        .toList();
    final failedList = (data['failed_scans'] as List? ?? [])
        .map((e) => BatchItemResult.fromJson(e as Map<String, dynamic>))
        .toList();

    return AttendanceBatchResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      successCount: data['success_count'] ?? successList.length,
      failedCount: data['failed_count'] ?? failedList.length,
      successfulScans: successList,
      failedScans: failedList,
      geofenceStatus: data['geofence_status']?.toString(),
      validationStatus: data['validation_status']?.toString(),
    );
  }
}

class BatchItemResult {
  final String name; // PUNCH-0001
  final String studentId; // STD-0001
  final String studentName;
  final String punchType; // "IN" | "OUT"
  final String punchDatetime;
  final String? message; // for failed scans

  BatchItemResult({
    required this.name,
    required this.studentId,
    required this.studentName,
    required this.punchType,
    required this.punchDatetime,
    this.message,
  });

  factory BatchItemResult.fromJson(Map<String, dynamic> json) {
    return BatchItemResult(
      name: json['name']?.toString() ?? '',
      studentId:
          json['student']?.toString() ?? json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      punchType: json['punch_type']?.toString() ?? '',
      punchDatetime: json['punch_datetime']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }

  bool get isIn => punchType.toUpperCase() == 'IN';
  bool get isOut => punchType.toUpperCase() == 'OUT';
}
