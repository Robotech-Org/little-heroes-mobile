// lib/features/home/data/models/classroom_model.dart
class ClassroomModel {
  final String name;
  final String classroomName;
  final String classroomAgeGroup;
  final int classroomCapacity;
  final String creation;
  final String modified;

  ClassroomModel({
    required this.name,
    required this.classroomName,
    required this.classroomAgeGroup,
    required this.classroomCapacity,
    required this.creation,
    required this.modified,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      name: json['name']?.toString() ?? '',
      classroomName: json['classroom_name']?.toString() ?? '',
      classroomAgeGroup: json['classroom_age_group']?.toString() ?? '',
      classroomCapacity: json['classroom_capacity'] ?? 0,
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'classroom_name': classroomName,
      'classroom_age_group': classroomAgeGroup,
      'classroom_capacity': classroomCapacity,
      'creation': creation,
      'modified': modified,
    };
  }

  @override
  String toString() => classroomName;
}
