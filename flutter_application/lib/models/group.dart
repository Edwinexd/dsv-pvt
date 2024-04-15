class Group {
  final int groupId;
  final String name;
  final String description;

  const Group({
    required this.groupId,
    required this.name,
    required this.description,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'groupId': int groupId,
        'name': String name,
        'description': String description,
      } =>
        Group(
          groupId: groupId,
          name: name,
          description: description,
        ),
        _ => throw const FormatException('Failed to build Group.'),
    };
  }
}