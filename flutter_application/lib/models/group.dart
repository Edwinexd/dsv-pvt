class Group {
  final int id;
  final String name;
  final String description;
  final bool isPublic;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.isPublic,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'description': String description,
        'isPublic': bool isPublic,
      } =>
        Group(
          id: id,
          name: name,
          description: description,
          isPublic: isPublic,
        ),
        _ => throw const FormatException('Failed to build Group.'),
    };
  }

  static Map<String, dynamic> toJson(Group value) =>
      {'id': value.id, 'name': value.name, 'description': value.description, 'isPublic': value.isPublic};
}

