class Profile {
  final String description;
  final int age;
  final String interests;
  final int skillLevel;
  final bool isPrivate;

  const Profile({
    required this.description,
    required this.age,
    required this.interests,
    required this.skillLevel,
    required this.isPrivate,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      description: json['description'] as String,
      age: json['age'] as int,
      interests: json['interests'] as String,
      skillLevel: json['skill_level'] as int,
      isPrivate: json['is_private'] as bool,
    );
    
  }
}
