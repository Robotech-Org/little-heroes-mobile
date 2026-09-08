// lib/features/home/data/models/classroom_schedule_model.dart
class ClassroomScheduleModel {
  final String name;
  final String classroom;
  final String academicYear;
  final String term;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String activity;
  final int isActive;
  final String creation;
  final String modified;

  ClassroomScheduleModel({
    required this.name,
    required this.classroom,
    required this.academicYear,
    required this.term,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.activity,
    required this.isActive,
    required this.creation,
    required this.modified,
  });

  factory ClassroomScheduleModel.fromJson(Map<String, dynamic> json) {
    return ClassroomScheduleModel(
      name: json['name']?.toString() ?? '',
      classroom: json['classroom']?.toString() ?? '',
      academicYear: json['academic_year']?.toString() ?? '',
      term: json['term']?.toString() ?? '',
      dayOfWeek: json['day_of_week']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      activity: json['activity']?.toString() ?? '',
      isActive: json['is_active'] ?? 0,
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'classroom': classroom,
      'academic_year': academicYear,
      'term': term,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'activity': activity,
      'is_active': isActive,
      'creation': creation,
      'modified': modified,
    };
  }

  String get displayName =>
      '$activity - $dayOfWeek (${startTime.substring(0, 5)} - ${endTime.substring(0, 5)})';
  String get timeRange =>
      '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}';
  String get shortDay => dayOfWeek.substring(0, 3);
}

// Classroom Schedule Response Model
class ClassroomScheduleResponseModel {
  final List<ClassroomScheduleModel> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  ClassroomScheduleResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ClassroomScheduleResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? json['data'] ?? {};
    final items = data['items'] as List? ?? [];

    return ClassroomScheduleResponseModel(
      items: items
          .map((item) => ClassroomScheduleModel.fromJson(item))
          .toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
      totalPages: data['total_pages'] ?? 1,
    );
  }
}
