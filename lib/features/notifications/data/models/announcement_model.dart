class AnnouncementModel {
  final String name;
  final String title;
  final String body;
  final String postedAt;
  final String postedBy;
  final String? classroom;
  final String creation;
  final String modified;

  AnnouncementModel({
    required this.name,
    required this.title,
    required this.body,
    required this.postedAt,
    required this.postedBy,
    this.classroom,
    required this.creation,
    required this.modified,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      name: json['name']?.toString() ?? '',
      title: json['announcement_title']?.toString() ?? '',
      body: json['announcement_body']?.toString() ?? '',
      postedAt: json['announcement_posted_at']?.toString() ?? '',
      postedBy: json['announcement_posted_by']?.toString() ?? '',
      classroom: json['announcement_classroom']?.toString(),
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'announcement_title': title,
      'announcement_body': body,
      'announcement_posted_at': postedAt,
      'announcement_posted_by': postedBy,
      'announcement_classroom': classroom,
      'creation': creation,
      'modified': modified,
    };
  }
}
