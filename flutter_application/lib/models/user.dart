// TODO: WHERE TO VALIDATE ROLE [0,1,2]?
class User {
  final String id;
  final String userName;
  final String fullName;
  final DateTime dateCreated;
  final int role;

  const User ({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.dateCreated,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json["id"] as String,
        userName: json["username"] as String,
        fullName: json["full_name"] as String,
        dateCreated: DateTime.parse(json["date_created"] as String),
        role: json["role"] as int,
      );
    } on FormatException {
      throw const FormatException("Failed to build User.");
    }
  //   return switch (json) {
  //   {
  //     'id': int id,
  //     'username': String userName,
  //     'full_name': String fullName,
  //     'date_created': String dateCreated,
  //   } => 
  //     User(
  //       id: id,
  //       userName: userName,
  //       fullName: fullName,
  //       dateCreated: dateCreated,
  //   ),
  //   _ => throw const FormatException('Failed to build User.'),
  // };

    
  }
}