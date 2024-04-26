class User {
  final int id;
  final String userName;
  final String fullName;
  final String dateCreated;

  const User ({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.dateCreated,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
    {
      'id': int id,
      'username': String userName,
      'full_name': String fullName,
      'date_created': String dateCreated,
    } => 
      User(
        id: id,
        userName: userName,
        fullName: fullName,
        dateCreated: dateCreated,
    ),
    _ => throw const FormatException('Failed to build User.'),
  };

    
  }
}