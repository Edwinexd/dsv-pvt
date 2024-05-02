class Profile {
  final String description;
  final int age;
  final String interests;
  final int skillLevel;
  final bool isPrivate;

  const Profile ({
    required this.description,
    required this.age,
    required this.interests,
    required this.skillLevel,
    required this.isPrivate,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
    {
      "description": String description,
      "age": int age,
      "interests": String interests,
      "skill_level": int skillLevel,
      "is_private": bool isPrivate,
    } => 
      Profile(
        description: description,
        age: age,
        interests: interests,
        skillLevel: skillLevel,
        isPrivate: isPrivate,
    ),
    _ => throw const FormatException('Failed to build Profile.'),
  };

    
  }
}