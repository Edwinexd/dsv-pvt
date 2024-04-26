import 'package:flutter_application/models/group.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackendService {
  late Dio _dio;

  BackendService() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BACKEND_API_URL']!,
      headers: {'Content-Type': 'application/json'},
    ));
  }

  BackendService.withDio(Dio dio) {
    _dio = dio;
  }

  Future<Group> fetchGroup(int groupId) async {
    final response = await _dio.get('/groups/$groupId');
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<Group>> fetchGroups(int skip, int limit) async {
    final response = await _dio.get('/groups', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var groupList = response.data['data'] as List;
    return groupList.map((x) => Group.fromJson(x)).toList();
  }

  Future<Group> createGroup(
      String name, String description, bool private) async {
    final response = await _dio.post(
      '/groups',
      data: {
        "group_name": name,
        "description": description,
        "private": private,
      },
    );
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<Group> updateGroup(int groupId,
      {String? newName, String? description, bool? isPrivate}) async {
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

    final response = await _dio.patch(
      '/groups/$groupId',
      data: updateFields,
    );
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<User> fetchUser(int userId) async {
    final response = await _dio.get('/users/$userId');
    return User.fromJson((response.data) as Map<String, dynamic>);
  }
}