class Challenge {
  final String name;
  final String description;
  final int difficulty;
  final DateTime? expirationDate;
  final int pointReward;
  final int? achievementId;
  final int id;
  final String? imageId;

  const Challenge({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.expirationDate,
    required this.pointReward,
    required this.achievementId,
    required this.id,
    required this.imageId,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      name: json["challenge_name"] as String,
      description: json["description"] as String,
      difficulty: json["difficulty_code"] as int,
      expirationDate: json["expiration_date"] == null ? null : DateTime.parse(json["expiration_date"] as String),
      pointReward: json["point_reward"] as int,
      achievementId: json["achievement_id"] as int?,
      id: json["id"] as int,
      imageId: json["image_id"] as String?,
    );
  }
}
