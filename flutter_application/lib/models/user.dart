/*
Lace Up & Lead The Way - A pre-race training app and social platform for runners.
Copyright (C) 2024 Group 71 (PVT 7.5) Stockholm University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
*/
import 'package:flutter_application/models/role.dart';

class User {
  final String id;
  final String userName;
  final String fullName;
  final DateTime dateCreated;
  final Role role;
  final String? imageId;
  final String email;

  const User({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.dateCreated,
    required this.role,
    required this.email,
    required this.imageId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] as String,
      userName: json["username"] as String,
      fullName: json["full_name"] as String,
      dateCreated: DateTime.parse(json["date_created"] as String),
      role: Role.parse(json["role"] as int),
      imageId: json["image_id"] as String?,
      email: json["email"] as String,
    );
  }
}
