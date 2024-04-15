class Group {
  final int id;
  final String name;
  final String description;

  const Group({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'description': String description,
      } =>
        Group(
          id: id,
          name: name,
          description: description,
        ),
        _ => throw const FormatException('Failed to build Group.'),
    };
  }
}

