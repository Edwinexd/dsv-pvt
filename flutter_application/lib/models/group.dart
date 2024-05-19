class Group {
  final int id;
  final String name;
  final String description;
  final bool isPrivate;
  final String ownerId;
  final int points;
  final String? imageId;

  const Group(
      {required this.id,
      required this.name,
      required this.description,
      required this.isPrivate,
      required this.ownerId,
      this.points = 0,
      this.imageId});


  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["id"] as int,
      name: json["group_name"] as String,
      description: json["description"] as String,
      isPrivate: json['is_private'] as bool,
      ownerId: json['owner_id'] as String,
      points: json['points'] as int,
      imageId: json['image_id'] as String?,
    );
  }
}

enum GroupOrderType { 
  NAME,
  POINTS;

  static GroupOrderType parse(String orderValue) {
    switch (orderValue) {
      case 'name':
        return GroupOrderType.NAME;
      case 'points':
        return GroupOrderType.POINTS;
      default:
        throw ArgumentError('Invalid order value: $orderValue');
    }
  }

  String serialize() {
    switch (this) {
      case GroupOrderType.NAME:
        return 'name';
      case GroupOrderType.POINTS:
        return 'points';
    }
  }
}
