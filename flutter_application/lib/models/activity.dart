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
import 'package:flutter_application/models/challenges.dart';

class Activity {
  final String name;
  final DateTime scheduledDateTime;
  final int difficulty;
  final int id;
  final bool isCompleted;
  final int groupId;
  final String ownerId;
  final double latitude;
  final double longitude;
  final String address;
  final List<Challenge> challenges;


  const Activity({
    required this.name,
    required this.scheduledDateTime,
    required this.difficulty,
    required this.id,
    required this.isCompleted,
    required this.groupId,
    required this.ownerId,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.challenges,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json["activity_name"] as String,
      scheduledDateTime: DateTime.parse(json["scheduled_date"] as String),
      difficulty: json["difficulty_code"] as int,
      id: json["id"] as int,
      isCompleted: json["is_completed"] as bool,
      groupId: json["group_id"] as int,
      ownerId: json["owner_id"] as String,
      latitude: json["latitude"] as double,
      longitude: json["longitude"] as double,
      address: json["address"] as String,
      challenges: (json["challenges"] as List).map((e) => Challenge.fromJson(e)).toList(),
    );
  }
}
