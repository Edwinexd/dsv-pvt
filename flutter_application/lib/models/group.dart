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
class Group {
  final int id;
  final String name;
  final String description;
  final bool isPrivate;
  final String ownerId;
  final int skillLevel;
  final int points;
  final String? imageId;
  final String? address;
  final double? latitude;
  final double? longitude;

  const Group(
      {required this.id,
      required this.name,
      required this.description,
      required this.isPrivate,
      required this.ownerId,
      required this.skillLevel,
      this.points = 0,
      this.imageId,
      this.address,
      this.latitude,
      this.longitude});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["id"] as int,
      name: json["group_name"] as String,
      description: json["description"] as String,
      isPrivate: json['is_private'] as bool,
      ownerId: json['owner_id'] as String,
      skillLevel: json['skill_level'] as int,
      points: json['points'] as int,
      imageId: json['image_id'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
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
