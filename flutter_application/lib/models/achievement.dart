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
