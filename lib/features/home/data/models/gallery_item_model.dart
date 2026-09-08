// lib/features/home/data/models/gallery_item_model.dart
class GalleryItemModel {
  final String name;
  final String moment;
  final String taggedStudent;
  final String parentLink;
  final String teacher;
  final String galleryPhoto;
  final String momentDate;
  final String momentTime;
  final String galleryNotes;
  final String? studentName;
  final String creation;
  final String modified;

  GalleryItemModel({
    required this.name,
    required this.moment,
    required this.taggedStudent,
    required this.parentLink,
    required this.teacher,
    required this.galleryPhoto,
    required this.momentDate,
    required this.momentTime,
    required this.galleryNotes,
    this.studentName,
    required this.creation,
    required this.modified,
  });

  factory GalleryItemModel.fromJson(Map<String, dynamic> json) {
    return GalleryItemModel(
      name: json['name']?.toString() ?? '',
      moment: json['moment']?.toString() ?? '',
      taggedStudent: json['tagged_student']?.toString() ?? '',
      parentLink: json['parent_link']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      galleryPhoto: json['gallery_photo']?.toString() ?? '',
      momentDate: json['moment_date']?.toString() ?? '',
      momentTime: json['moment_time']?.toString() ?? '',
      galleryNotes: json['gallery_notes']?.toString() ?? '',
      studentName: json['student_name']?.toString(),
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'moment': moment,
      'tagged_student': taggedStudent,
      'parent_link': parentLink,
      'teacher': teacher,
      'gallery_photo': galleryPhoto,
      'moment_date': momentDate,
      'moment_time': momentTime,
      'gallery_notes': galleryNotes,
      'student_name': studentName,
      'creation': creation,
      'modified': modified,
    };
  }
}
