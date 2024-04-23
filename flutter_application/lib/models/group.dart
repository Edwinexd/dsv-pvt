class Group {
  final int id;
  final String name;
  final String description;
  final bool isPrivate;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.isPrivate,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'group_name': String name,
        'description': String description,
        'private': bool isPrivate,
      } =>
        Group(
          id: id,
          name: name,
          description: description,
          isPrivate: isPrivate,
        ),
        _ => throw const FormatException('Failed to build Group.'),
    };
  }

  static Map<String, dynamic> toJson(Group value) =>
      {'id': value.id, 'group_name': value.name, 'description': value.description, 'private': value.isPrivate};
}

