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
