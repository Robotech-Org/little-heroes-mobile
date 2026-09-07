class ObservationModel {
  final String id;
  final String student;
  final String studentName;
  final String activity;
  final String note;
  final String startTime;
  final String endTime;
  final String? fileName;
  final String? fileUrl;
  final String creation;
  final String modified;

  ObservationModel({
    required this.id,
    required this.student,
    required this.studentName,
    required this.activity,
    required this.note,
    required this.startTime,
    required this.endTime,
    this.fileName,
    this.fileUrl,
    required this.creation,
    required this.modified,
  });

  factory ObservationModel.fromJson(Map<String, dynamic> json) {
    return ObservationModel(
      id: json['name']?.toString() ?? '',
      student: json['student']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      activity: json['activity']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      fileName: json['file_name']?.toString(),
      fileUrl: json['file_url']?.toString(),
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': id,
      'student': student,
      'student_name': studentName,
      'activity': activity,
      'note': note,
      'start_time': startTime,
      'end_time': endTime,
      'file_name': fileName,
      'file_url': fileUrl,
      'creation': creation,
      'modified': modified,
    };
  }
}
