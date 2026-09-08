class LevelModel {
  final int level;
  final String description;

  LevelModel({required this.level, required this.description});

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      level: json['level'] ?? 0,
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'level': level, 'description': description};
  }
}
