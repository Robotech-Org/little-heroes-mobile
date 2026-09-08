// lib/features/home/data/models/moment_model.dart
class MomentModel {
  final String name;
  final String teacher;
  final String momentDate;
  final String momentTime;
  final String workflowState;
  final String momentPhoto;
  final String momentNotes;
  final int isAddedToGallery;
  final List<TaggedStudent> taggedStudents;
  final String creation;
  final String modified;

  MomentModel({
    required this.name,
    required this.teacher,
    required this.momentDate,
    required this.momentTime,
    required this.workflowState,
    required this.momentPhoto,
    required this.momentNotes,
    required this.isAddedToGallery,
    required this.taggedStudents,
    required this.creation,
    required this.modified,
  });

  factory MomentModel.fromJson(Map<String, dynamic> json) {
    final tagged = json['tagged_students'] as List? ?? [];
    return MomentModel(
      name: json['name']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      momentDate: json['moment_date']?.toString() ?? '',
      momentTime: json['moment_time']?.toString() ?? '',
      workflowState: json['workflow_state']?.toString() ?? 'Draft',
      momentPhoto: json['moment_photo']?.toString() ?? '',
      momentNotes: json['moment_notes']?.toString() ?? '',
      isAddedToGallery: json['is_added_to_gallery'] ?? 0,
      taggedStudents: tagged.map((e) => TaggedStudent.fromJson(e)).toList(),
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'teacher': teacher,
      'moment_date': momentDate,
      'moment_time': momentTime,
      'workflow_state': workflowState,
      'moment_photo': momentPhoto,
      'moment_notes': momentNotes,
      'is_added_to_gallery': isAddedToGallery,
      'tagged_students': taggedStudents.map((e) => e.toJson()).toList(),
      'creation': creation,
      'modified': modified,
    };
  }
}

class TaggedStudent {
  final String name;
  final String student;

  TaggedStudent({required this.name, required this.student});

  factory TaggedStudent.fromJson(Map<String, dynamic> json) {
    return TaggedStudent(
      name: json['name']?.toString() ?? '',
      student: json['student']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'student': student};
  }
}
