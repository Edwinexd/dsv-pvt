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
