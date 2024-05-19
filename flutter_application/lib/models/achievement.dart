class Achievement {
  final int id;
  final String achievementName;
  final String description;
  final String? imageId;
  final int requirement;

  const Achievement({
    required this.id,
    required this.achievementName,
    required this.description,
    this.imageId,
    required this.requirement,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json["id"] as int,
      achievementName: json["achievement_name"] as String,
      description: json["description"] as String,
      imageId: json["image_id"] as String?,
      requirement: json["requirement"] as int,
    );
  }
}
