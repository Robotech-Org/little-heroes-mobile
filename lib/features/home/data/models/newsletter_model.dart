class NewsletterModel {
  final String name; // "LH-NL-2026-00001"
  final String title; // newsletter_title
  final String body; // newsletter_body (HTML)
  final String status; // Draft | Published
  final DateTime? publishedAt; // newsletter_published_at
  final String publishedBy; // newsletter_published_by
  final DateTime? creation;
  final DateTime? modified;
  final List<NewsletterTag> taggedParents;

  NewsletterModel({
    required this.name,
    required this.title,
    required this.body,
    required this.status,
    this.publishedAt,
    this.publishedBy = '',
    this.creation,
    this.modified,
    this.taggedParents = const [],
  });

  bool get isPublished => status.toLowerCase() == 'published';

  factory NewsletterModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tagged_parents'];
    final tags = <NewsletterTag>[];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t is Map) {
          tags.add(NewsletterTag.fromJson(Map<String, dynamic>.from(t)));
        }
      }
    }

    return NewsletterModel(
      name: json['name']?.toString() ?? '',
      title: json['newsletter_title']?.toString() ?? '',
      body: json['newsletter_body']?.toString() ?? '',
      status: json['newsletter_status']?.toString() ?? 'Draft',
      publishedAt: DateTime.tryParse(
        json['newsletter_published_at']?.toString() ?? '',
      ),
      publishedBy: json['newsletter_published_by']?.toString() ?? '',
      creation: DateTime.tryParse(json['creation']?.toString() ?? ''),
      modified: DateTime.tryParse(json['modified']?.toString() ?? ''),
      taggedParents: tags,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'newsletter_title': title,
    'newsletter_body': body,
    'newsletter_status': status,
    'tagged_parents': taggedParents.map((t) => t.toJson()).toList(),
  };
}

class NewsletterTag {
  final String parentRef;
  NewsletterTag({required this.parentRef});

  factory NewsletterTag.fromJson(Map<String, dynamic> json) =>
      NewsletterTag(parentRef: json['parent_ref']?.toString() ?? '');

  Map<String, dynamic> toJson() => {'parent_ref': parentRef};
}
