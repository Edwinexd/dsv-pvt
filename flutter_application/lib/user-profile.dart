class UserProfile {
  final String name;
  final String email;
  final String interests;
  final String skillLevel;

  UserProfile({required this.name, required this.email, required this.interests, required this.skillLevel});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'interests': interests,
      'skillLevel': skillLevel,
    };
  }
}
