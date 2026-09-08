import 'level_model.dart';

class CompetencyModel {
  final String name;
  final String domain; // Parent - e.g., "Social Studies"
  final String? domainTitle;
  final String competencyCode; // e.g., "FF"
  final String title; // Child - e.g., "Knowledge of self and others"
  final int sequence; // Order within domain
  final int maxLevel;
  final int isActive;
  final String creation;
  final String modified;
  final List<LevelModel> levels; // Levels 0-5 with descriptions

  CompetencyModel({
    required this.name,
    required this.domain,
    this.domainTitle,
    required this.competencyCode,
    required this.title,
    required this.sequence,
    required this.maxLevel,
    required this.isActive,
    required this.creation,
    required this.modified,
    this.levels = const [],
  });

  factory CompetencyModel.fromJson(Map<String, dynamic> json) {
    final levelsList = json['levels'] as List? ?? [];
    final levels = levelsList.map((item) => LevelModel.fromJson(item)).toList();

    return CompetencyModel(
      name: json['name']?.toString() ?? '',
      domain: json['domain']?.toString() ?? '',
      domainTitle: json['domain_title']?.toString(),
      competencyCode: json['competency_code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      sequence: json['sequence'] ?? 0,
      maxLevel: json['max_level'] ?? 5,
      isActive: json['is_active'] ?? 1,
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
      levels: levels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'domain': domain,
      'domain_title': domainTitle,
      'competency_code': competencyCode,
      'title': title,
      'sequence': sequence,
      'max_level': maxLevel,
      'is_active': isActive,
      'creation': creation,
      'modified': modified,
      'levels': levels.map((e) => e.toJson()).toList(),
    };
  }
}
