import 'package:flutter_application/models/dio_client.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/user.dart';


class BackendService {
  // late Dio _dio;
  late DioClient _dioClient;

  BackendService(DioClient dioClient) {
    _dioClient = dioClient;
  }

  // TODO: TA BORT?
  // BackendService.withDio(Dio dio) {
  //   _dio = dio;
  // }

  Future<Group> fetchGroup(int groupId) async {
    final response = await _dioClient.dio.get('/groups/$groupId');
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<Group>> fetchGroups(int skip, int limit) async {
    final response = await _dioClient.dio.get('/groups', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var groupList = response.data['data'] as List;
    return groupList.map((x) => Group.fromJson(x)).toList();
  }

  Future<Group> createGroup(
      String name, String description, bool private) async {
    final response = await _dioClient.dio.post(
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

    final response = await _dioClient.dio.patch(
      '/groups/$groupId',
      data: updateFields,
    );
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  void deleteGroup(int groupdId) async {
    final response = await _dioClient.dio.delete('groups/$groupdId');
    // TODO: Successful api call returns message in body: "message": "Group deleted successfully"
  }

  Future<User> fetchUser(int userId) async {
    final response = await _dioClient.dio.get('/users/$userId');
    return User.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<User>> fetchUsers(int skip, int limit) async {
    final response = await _dioClient.dio.get('/users', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var userList = response.data['data'] as List;
    return userList.map((x) => User.fromJson(x)).toList();
  }
}