import 'dart:convert';

import 'package:flutter_application/models/group.dart';
import 'package:dio/dio.dart';

class GroupController {
  late final BaseOptions options;
  late final Dio dio;

  GroupController() {
    options = BaseOptions(
      baseUrl: 'http://10.97.231.1:81',
      headers: {'Content-Type': 'applcation/json'},
    );
    dio = Dio(options);
  }

  Future<Group> fetchGroup(int groupId) async {
    final response = await dio.get('/group/$groupId');
    return Group.fromJson(jsonDecode(response.data) as Map<String, dynamic>);
  }

  Future<List<Group>> fetchGroups(int skip, int limit) async {
    final response = await dio.get('/groups?skip=$skip&limit=$limit');
    var groupList = response.data['data'] as List;
    return groupList.map((x) => Group.fromJson(x)).toList();
  }

  Future<Group> createGroup(String name, String description, bool private) async {
    final response = await dio.post('/groups',
      data: {
        "group_name": name,
        "description": description,
        "private": private,
      });

    return Group.fromJson(jsonDecode(response.data) as Map<String, dynamic>);
  }
  
  Future<Group> updateGroup(int groupId, {String? newName, String? description, bool? isPrivate}) async {
    // Create a map to hold the update fields
    Map<String, dynamic> updateFields = {};
    if (newName != null) {
      updateFields['group_name'] = newName;
    }
    if (description != null) {
      updateFields['description'] = description;
    }
    if (isPrivate != null) {
      updateFields['private'] = isPrivate;
    }

    final response = await dio.patch('/groups/$groupId',
      data: {jsonEncode(updateFields)});
      return Group.fromJson(jsonDecode(response.data) as Map<String, dynamic>);
  }
}

