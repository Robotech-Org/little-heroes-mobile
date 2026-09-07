class FrameworkModel {
  final String domain;
  final String domainCode;
  final String description;
  final List<CategoryModel> categories;

  FrameworkModel({
    required this.domain,
    required this.domainCode,
    required this.description,
    required this.categories,
  });

  factory FrameworkModel.fromJson(Map<String, dynamic> json) {
    return FrameworkModel(
      domain: json['domain'] ?? '',
      domainCode: json['domain_code'] ?? '',
      description: json['description'] ?? '',
      categories: (json['categories'] as List? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'domain': domain,
      'domain_code': domainCode,
      'description': description,
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String code;
  final String description;
  final List<LevelModel> levels;

  CategoryModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.levels,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      levels: (json['levels'] as List? ?? [])
          .map((e) => LevelModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'levels': levels.map((e) => e.toJson()).toList(),
    };
  }
}

class LevelModel {
  final int level;
  final String description;
  final String? indicator;

  LevelModel({required this.level, required this.description, this.indicator});

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      level: json['level'] ?? 0,
      description: json['description'] ?? '',
      indicator: json['indicator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'level': level, 'description': description, 'indicator': indicator};
  }
}
