class AttendanceBatchResponse {
  final bool success;
  final String message;
  final List<BatchItemResult> results;

  AttendanceBatchResponse({
    required this.success,
    required this.message,
    required this.results,
  });

  factory AttendanceBatchResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final resultsList = (message['results'] as List? ?? [])
        .map((e) => BatchItemResult.fromJson(e as Map<String, dynamic>))
        .toList();

    return AttendanceBatchResponse(
      success: message['success'] ?? false,
      message: message['message']?.toString() ?? '',
      results: resultsList,
    );
  }
}

class BatchItemResult {
  final String studentId;
  final bool success;
  final String? message;
  final String? studentName;
  final String? status;
  final String? logType;

  BatchItemResult({
    required this.studentId,
    required this.success,
    this.message,
    this.studentName,
    this.status,
    this.logType,
  });

  factory BatchItemResult.fromJson(Map<String, dynamic> json) {
    return BatchItemResult(
      studentId: json['student_id']?.toString() ?? '',
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      studentName: json['student_name']?.toString(),
      status: json['status']?.toString(),
      logType: json['log_type']?.toString(),
    );
  }
}
