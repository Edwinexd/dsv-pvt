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
class Profile {
  final String description;
  final int age;
  final String interests;
  final int skillLevel;
  final bool isPrivate;
  final String location;
  final String? runnerId;
  final String? imageId;

  const Profile({
    required this.description,
    required this.age,
    required this.interests,
    required this.skillLevel,
    required this.isPrivate,
    required this.location,
    this.runnerId,
    this.imageId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      description: json['description'] as String,
      age: json['age'] as int,
      interests: json['interests'] as String,
      skillLevel: json['skill_level'] as int,
      isPrivate: json['is_private'] as bool,
      location: json['location'] as String,
      runnerId: json['runner_id'] as String?,
      imageId: json['image_id'] as String?,
    );
  }
}
