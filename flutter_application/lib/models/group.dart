class Group {
  final int id;
  final String name;
  final String description;
  final bool isPrivate;
  final String ownerId;

  const Group(
      {required this.id,
      required this.name,
      required this.description,
      required this.isPrivate,
      required this.ownerId});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["id"] as int,
      name: json["group_name"] as String,
      description: json["description"] as String,
      isPrivate: json['is_private'] as bool,
      ownerId: json['owner_id'] as String,
    );
  }
}
