class ObservationModel {
  final String id;
  final String student;
  final String teacher;
  final String observationDate;
  final String observationClassSchedule;
  final String? observationPhoto; // null in list response
  final String? observationNotes; // null in list response
  final List<dynamic> taggedStudents;
  final String creation;
  final String modified;

  ObservationModel({
    required this.id,
    required this.student,
    required this.teacher,
    required this.observationDate,
    required this.observationClassSchedule,
    this.observationPhoto,
    this.observationNotes,
    this.taggedStudents = const [],
    required this.creation,
    required this.modified,
  });

  // Backward-compat getters
  String get studentName => student;
  String get activity => observationClassSchedule;
  String get note => observationNotes ?? '';
  String? get fileUrl => observationPhoto;
  String? get fileName => _fileNameFromUrl(observationPhoto);

  bool get hasPhoto => observationPhoto != null && observationPhoto!.isNotEmpty;
  bool get hasNotes => observationNotes != null && observationNotes!.isNotEmpty;

  factory ObservationModel.fromJson(Map<String, dynamic> json) {
    return ObservationModel(
      id: json['name']?.toString() ?? '',
      student: json['student']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      observationDate: json['observation_date']?.toString() ?? '',
      observationClassSchedule:
          json['observation_class_schedule']?.toString() ?? '',
      observationPhoto: json['observation_photo']?.toString(),
      observationNotes: json['observation_notes']?.toString(),
      taggedStudents: (json['tagged_students'] as List?) ?? const [],
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': id,
    'student': student,
    'teacher': teacher,
    'observation_date': observationDate,
    'observation_class_schedule': observationClassSchedule,
    'observation_photo': observationPhoto,
    'observation_notes': observationNotes,
    'tagged_students': taggedStudents,
    'creation': creation,
    'modified': modified,
  };

  static String? _fileNameFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final last = url.split('/').last;
      return last.isEmpty ? null : last;
    } catch (_) {
      return null;
    }
  }
}
