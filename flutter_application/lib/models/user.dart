import 'package:flutter_application/models/role.dart';

class User {
  final String id;
  final String userName;
  final String fullName;
  final DateTime dateCreated;
  final Role role;

  const User({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.dateCreated,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] as String,
      userName: json["username"] as String,
      fullName: json["full_name"] as String,
      dateCreated: DateTime.parse(json["date_created"] as String),
      role: Role.parse(json["role"] as int),
    );
  }
}
