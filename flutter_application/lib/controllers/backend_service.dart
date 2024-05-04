import 'package:dio/dio.dart';
import 'package:flutter_application/models/activity.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/group_invite.dart';
import 'package:flutter_application/models/profile.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackendService {
  late Dio _dio;
  String? token;

  BackendService() {
    _dio = Dio();
    _dio.options.baseUrl = dotenv.env['BACKEND_API_URL']!;
    _dio.options.headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      print("Sending request to ${options.path}");
      if (token != null) {
        options.headers['Authorization'] = token;
      }
      return handler.next(options);
    }, onResponse: (response, handler) {
      // Handle responses
      print("Received response: ${response.statusCode}");
      return handler.next(response);
    }, onError: (DioException error, handler) {
      // Handle errors
      print("API error occurred: ${error.message}");
      return handler.next(error);
    }));
  }

  BackendService.withDio(Dio dio) {
    _dio = dio;
  }

  // --------- USERS ---------

  Future<void> login(String userName, String password) async {
    final response = await _dio.post(
      '/users/login',
      data: {
        "username": userName,
        "password": password,
      },
    );
    token = response.data['bearer'];
  }

  Future<User> createUser(
      String userName, String fullName, String password) async {
    final response = await _dio.post(
      '/users',
      data: {
        "username": userName,
        "full_name": fullName,
        "password": password,
      },
    );
    return User.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<User>> fetchUsers(int skip, int limit) async {
    final response = await _dio.get('/users', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var userList = response.data['data'] as List;
    return userList.map((e) => User.fromJson(e)).toList();
  }

  Future<User> fetchMe() async {
    final response = await _dio.get('/users/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> fetchUser(String userId) async {
    final response = await _dio.get('/users/$userId');
    return User.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<User> updateUser(String userId,
      {String? userName, String? fullName}) async {
    Map<String, dynamic> updateFields = {};
    if (userName != null) {
      updateFields['username'] = userName;
    }
    if (fullName != null) {
      updateFields['full_name'] = fullName;
    }

    final response = await _dio.patch(
      '/users/$userId',
      data: updateFields,
    );
    return User.fromJson((response.data) as Map<String, dynamic>);
  }

  void deleteUser(String userId) async {
    await _dio.delete('/users/$userId');
  }

  // --------- PROFILE ---------

  Future<Profile> createProfile(String userId, String description, int age,
      String interests, int skillLevel, bool isPrivate) async {
    final response = await _dio.post('/users/$userId/profile', data: {
      "description": description,
      "age": age,
      "interests": interests,
      "skill_level": skillLevel,
      "is_private": isPrivate,
    });

    return Profile.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<Profile> fetchProfile(String userId) async {
    final response = await _dio.get('/users/$userId');
    return Profile.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<Profile> updateProfile(String userId,
      {String? description,
      int? age,
      String? interests,
      int? skillLevel,
      bool? isPrivate}) async {
    Map<String, dynamic> updateFields = {};
    if (description != null) {
      updateFields['description'] = description;
    }
    if (age != null) {
      updateFields['age'] = age;
    }
    if (interests != null) {
      updateFields['interests'] = interests;
    }
    if (skillLevel != null) {
      updateFields['skill_level'] = skillLevel;
    }
    if (isPrivate != null) {
      updateFields['is_private'] = isPrivate;
    }

    final response = await _dio.patch(
      '/users/$userId/profile',
      data: updateFields,
    );

    return Profile.fromJson((response.data) as Map<String, dynamic>);
  }

  void deleteProfile(String userId) async {
    await _dio.delete('users/$userId/profile');
  }

  // --------- GROUPS ---------

  Future<Group> createGroup(
      String name, String description, bool isPrivate, String ownedId) async {
    final response = await _dio.post(
      '/groups',
      data: {
        "group_name": name,
        "description": description,
        "is_private": isPrivate,
        "owner_id": ownedId,
      },
    );
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<Group>> fetchGroups(int skip, int limit) async {
    final response = await _dio.get('/groups', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var groupList = response.data['data'] as List;
    return groupList.map((e) => Group.fromJson(e)).toList();
  }

  Future<Group> fetchGroup(int groupId) async {
    final response = await _dio.get('/groups/$groupId');
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
      updateFields['is_private'] = isPrivate;
    }

    final response = await _dio.patch(
      '/groups/$groupId',
      data: updateFields,
    );
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  void deleteGroup(int groupdId) async {
    await _dio.delete('groups/$groupdId');
  }

  Future<Group> joinGroup(String userId, int groupId) async {
    final response = await _dio.put('/groups/$groupId/members/$userId');

    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<Group> leaveGroup(String userId, int groupId) async {
    final response = await _dio.delete('/groups/$groupId/members/$userId');
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<User>> fetchGroupMembers(int groupId) async {
    final response = await _dio.get('/groups/$groupId/members');
    var memberList = response.data['data'] as List;
    return memberList.map((e) => User.fromJson(e)).toList();
  }

  Future<List<Group>> fetchMyGroups() async {
    final response = await _dio.get('/users/me/groups');
    var groupList = response.data['data'] as List;
    return groupList.map((e) => Group.fromJson(e)).toList();
  }

  Future<List<Group>> fetchUserGroups(String userId) async {
    final response = await _dio.get('/users/$userId/groups');
    var groupList = response.data['data'] as List;
    return groupList.map((e) => Group.fromJson(e)).toList();
  }

  // --------- GROUP INVITES ---------

  Future<GroupInvite> inviteUserToGroup(String userId, int groupId) async {
    final response = await _dio.put('/groups/$groupId/invites/$userId');
    return GroupInvite.fromJson((response.data) as Map<String, dynamic>);
  }

  void deleteGroupInvite(String userId, int groupId) async {
    await _dio.delete('/groups/$groupId/invites/$userId');
  }

  Future<List<User>> fetchInvitedUsersInGroup(int groupId) async {
    final response = await _dio.get('/groups/$groupId/invites');
    var userList = response.data['data'] as List;
    return userList.map((e) => User.fromJson(e)).toList();
  }

  Future<List<Group>> fetchGroupsInvitedTo() async {
    final response = await _dio.get('users/me/invites');
    var groupList = response.data['data'] as List;
    return groupList.map((e) => Group.fromJson(e)).toList();
  }

  void declineGroupInvite(int groupId) async {
    _dio.delete('/groups/$groupId/invites/me');
  }

  // --------- ACTIVITIES ---------
  Future<Activity> createActivity(
      int groupId, String name, DateTime scheduled, int difficulty) async {
    final response = await _dio.post('/groups/$groupId/activities', data: {
      "activity_name": name,
      "scheduled_date": scheduled, // toString()? - INTE TESTAT ÄN
      "difficulty_code": difficulty,
    });
    return Activity.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<Activity>> fetchActivities(
      int groupId, int skip, int limit) async {
    final response =
        await _dio.get('/groups/$groupId/activities', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var activityList = response.data['data'] as List;
    return activityList.map((e) => Activity.fromJson(e)).toList();
  }

  Future<Activity> fetchActivity(int groupId, int activityId) async {
    final response = await _dio.get('/groups/$groupId/activities/$activityId');
    return Activity.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<Activity> updateActivity(int groupId, int activityId,
      {String? name,
      DateTime? scheduled,
      int? difficulty,
      bool? isCompleted}) async {
    Map<String, dynamic> updateFields = {};
    if (name != null) {
      updateFields['activity_name'] = name;
    }
    if (scheduled != null) {
      updateFields['scheduled_date'] = scheduled.toString();
    }
    if (difficulty != null) {
      updateFields['difficulty_code'] = difficulty;
    }
    if (isCompleted != null) {
      updateFields['is_completed'] = isCompleted;
    }

    final response = await _dio.patch(
      '/groups/$groupId/activities/$activityId',
      data: updateFields,
    );
    return Activity.fromJson((response.data) as Map<String, dynamic>);
  }

  void deleteActivity(int groupId, int activityId) async {
    await _dio.delete('/groups/$groupId/activities/$activityId');
  }

  void joinActivity(int groupId, int activityId, int participantId) async {
    await _dio.put(
        '/group/$groupId/activities/$activityId/participants/$participantId');
  }

  Future<List<User>> fetchActivityParticipants(
      int groupId, int activityId, int skip, int limit) async {
    final response = await _dio.get(
        '/group/$groupId/activities/$activityId/participants',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        });

    var participantList = response.data['data'] as List;
    return participantList.map((e) => User.fromJson(e)).toList();
  }

  Future<List<Activity>> fetchUserActivities(
      String userId, int skip, int limit) async {
    final response =
        await _dio.get('/users/$userId/activities', queryParameters: {
      'skip': skip,
      'limit': limit,
    });

    var activityList = response.data['data'] as List;
    return activityList.map((e) => Activity.fromJson(e)).toList();
  }

  void leaveActivity(int groupId, int acitivityId, String participantId) async {
    await _dio.delete(
        '/groups/$groupId/activities/$acitivityId/participants/$participantId');
  }
  


}

// class AuthInterceptor extends Interceptor {

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     String? token = await getToken();
//     if (token != null) {
//       // options.headers['Authorization'] = 'Bearer $token'; // TODO affects backend_service.dart
//       options.headers['Authorization'] = token;
//     }
//     handler.next(options);
//   }
// }
