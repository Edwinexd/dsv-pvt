class Activity {
  final String name;
  final DateTime scheduledDateTime;
  final int difficulty;
  final int id;
  final bool isCompleted;
  final int groupId;
  final String ownerId;

  const Activity({
    required this.name,
    required this.scheduledDateTime,
    required this.difficulty,
    required this.id,
    required this.isCompleted,
    required this.groupId,
    required this.ownerId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    try {
      return Activity(
        name: json["activity_name"] as String,
        scheduledDateTime: DateTime.parse(json["scheduled_date"] as String),
        difficulty: json["difficulty_code"] as int,
        id: json["id"] as int,
        isCompleted: json["is_completed"] as bool,
        groupId: json["group_id"] as int,
        ownerId: json["owner_id"],
      );
    } on FormatException {
      throw const FormatException("Failed to build Activity.");
    }
    // return switch (json) {
    //   {
    //     "activity_name": String name,
    //     "scheduled_date": DateTime scheduledDateTime,
    //     "difficulty_code": int difficulty,
    //     "id": int id,
    //     "is_completed": bool isCompleted,
    //     "group_id": int groupId,
    //     "owner_id": String ownerId,
    //   } =>
    //     Activity(
    //       name: name,
    //       scheduledDateTime: scheduledDateTime,
    //       difficulty: difficulty,
    //       id: id,
    //       isCompleted: isCompleted,
    //       groupId: groupId,
    //       ownerId: ownerId,
    //     ),
    //     _ => throw const FormatException('Failed to build Activity.'),
    // };
  }
}

