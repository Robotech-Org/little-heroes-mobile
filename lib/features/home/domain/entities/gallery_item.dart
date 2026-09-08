// lib/features/home/domain/entities/gallery_item.dart
import 'package:little_heroes_mobile/features/home/data/models/gallery_item_model.dart';

class GalleryItem {
  final String id;
  final String momentId;
  final String studentId;
  final String parentId;
  final String teacher;
  final String photoUrl;
  final DateTime momentDate;
  final String? notes;
  final String? studentName;

  GalleryItem({
    required this.id,
    required this.momentId,
    required this.studentId,
    required this.parentId,
    required this.teacher,
    required this.photoUrl,
    required this.momentDate,
    this.notes,
    this.studentName,
  });

  factory GalleryItem.fromModel(GalleryItemModel model) {
    return GalleryItem(
      id: model.name,
      momentId: model.moment,
      studentId: model.taggedStudent,
      parentId: model.parentLink,
      teacher: model.teacher,
      photoUrl: model.galleryPhoto,
      momentDate: DateTime.tryParse(model.momentDate) ?? DateTime.now(),
      notes: model.galleryNotes,
      studentName: model.studentName,
    );
  }
}
