class Group {
  final int id;
  final String name;
  final String description;
  final bool isPrivate;
  final String ownerId;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.isPrivate,
    required this.ownerId
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'group_name': String name,
        'description': String description,
        'is_private': bool isPrivate,
        'owner_id': String ownerId,
      } =>
        Group(
          id: id,
          name: name,
          description: description,
          isPrivate: isPrivate,
          ownerId: ownerId,
        ),
        _ => throw const FormatException('Failed to build Group.'),
    };
  }

}

