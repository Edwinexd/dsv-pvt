import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_application/models/challenges.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/activity.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/group_invite.dart';
import 'package:flutter_application/models/profile.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/models/achievement.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  late Dio _dio;
  String? token;
  User? _me;

  factory BackendService() {
    return _singleton;
  }

  BackendService._internal() {
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

  void setDio(Dio dio) {
    _dio = dio;
  }

  // --------- USERS ---------

  Future<User> getMe() async {
    _me ??= await getMyUser();
    return _me!;
  }

  Future<bool> isLoggedIn() async {
    try {
      await getMe();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    final response = await _dio.post(
      '/users/login',
      data: {
        "email": email,
        "password": password,
      },
    );
    token = response.data['bearer'];
  }

  Future<void> loginOauthGoogle(String? accessToken, String? idToken) async {
    if (accessToken == null && idToken == null) {
      throw const FormatException('loginOauthGoogle called without tokens');
    }
    final response = await _dio.post(
      '/users/login/oauth/google',
      data: {"access_token": accessToken, "id_token": idToken},
    );
    token = response.data['bearer'];
  }

  Future<void> logout() async {
    await _dio.post('/users/logout');
    token = null;
  }

  Future<User> createUser(
      String userName, String email, String fullName, String password) async {
    final response = await _dio.post(
      '/users',
      data: {
        "username": userName,
        "email": email,
        "full_name": fullName,
        "password": password,
      },
    );
    await login(email, password);
    return User.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<User>> getUsers(int skip, int limit) async {
    final response = await _dio.get('/users', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var userList = response.data['data'] as List;
    return userList.map((e) => User.fromJson(e)).toList();
  }

  Future<User> getMyUser() async {
    final response = await _dio.get('/users/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> getUser(String userId) async {
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
    if (updateFields.isEmpty) {
      throw const FormatException(
          'updateUser called without updated arguments');
    }

    final response = await _dio.patch(
      '/users/$userId',
      data: updateFields,
    );
    return User.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<void> deleteUser(String userId) async {
    await _dio.delete('/users/$userId');
  }

  // --------- PROFILE ---------

  Future<Profile> createProfile(
      String userId,
      String description,
      int age,
      String interests,
      int skillLevel,
      bool isPrivate,
      String location,
      String? runnerId) async {
    final response = await _dio.put('/users/$userId/profile', data: {
      "description": description,
      "age": age,
      "interests": interests,
      "skill_level": skillLevel,
      "is_private": isPrivate,
      "location": location,
      "runner_id": runnerId,
    });

    return Profile.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<Profile> getProfile(String userId) async {
    final response = await _dio.get('/users/$userId/profile');
    return Profile.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<Profile> updateProfile(String userId,
      {String? description,
      int? age,
      String? interests,
      int? skillLevel,
      bool? isPrivate,
      String? location,
      String? runnerId}) async {
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
    if (location != null) {
      updateFields['location'] = location;
    }
    if (runnerId != null) {
      updateFields['runner_id'] = runnerId;
    }
    if (updateFields.isEmpty) {
      throw const FormatException(
          'updateProfile called without updated arguments');
    }

    final response = await _dio.patch(
      '/users/$userId/profile',
      data: updateFields,
    );

    return Profile.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<void> deleteProfile(String userId) async {
    await _dio.delete('users/$userId/profile');
  }

  // --------- GROUPS ---------

  Future<Group> createGroup(
      String name,
      String description,
      bool isPrivate,
      String ownerId,
      int skillLevel,
      double? latitude,
      double? longitude,
      String? address) async {
    final response = await _dio.post(
      '/groups',
      data: {
        "group_name": name,
        "description": description,
        "is_private": isPrivate,
        "owner_id": ownerId,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "skill_level": skillLevel,
      },
    );
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  // TODO: Backend should have an order by parameter
  Future<List<Group>> getGroups(
      int skip, int limit, GroupOrderType orderBy, bool descending) async {
    final response = await _dio.get('/groups', queryParameters: {
      'skip': skip,
      'limit': limit,
      'order_by': orderBy.serialize(),
      'descending': descending,
    });
    var groupList = response.data['data'] as List;
    return groupList.map((e) => Group.fromJson(e)).toList();
  }

  Future<Group> getGroup(int groupId) async {
    final response = await _dio.get('/groups/$groupId');
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<Group> updateGroup(int groupId,
      {String? newName,
      String? description,
      int? skillLevel,
      bool? isPrivate}) async {
    // Create a map to hold the update fields
    Map<String, dynamic> updateFields = {};
    if (newName != null) {
      updateFields['group_name'] = newName;
    }
    if (description != null) {
      updateFields['description'] = description;
    }
    if (skillLevel != null) {
      updateFields['skill_level'] = skillLevel;
    }
    if (isPrivate != null) {
      updateFields['is_private'] = isPrivate;
    }
    if (skillLevel != null) {
      updateFields['skill_level'] = skillLevel;
    }
    if (updateFields.isEmpty) {
      throw const FormatException(
          'updateGroup called without updated arguments');
    }

    final response = await _dio.patch(
      '/groups/$groupId',
      data: updateFields,
    );
    return Group.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<void> deleteGroup(int groupdId) async {
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

  Future<List<User>> getGroupMembers(int groupId) async {
    final response = await _dio.get('/groups/$groupId/members');
    var memberList = response.data['data'] as List;
    return memberList.map((e) => User.fromJson(e)).toList();
  }

  Future<List<Group>> getMyGroups() async {
    final response = await _dio.get('/users/me/groups');
    var groupList = response.data['data'] as List;
    return groupList.map((e) => Group.fromJson(e)).toList();
  }

  Future<List<Group>> getUserGroups(String userId) async {
    final response = await _dio.get('/users/$userId/groups');
    var groupList = response.data['data'] as List;
    return groupList.map((e) => Group.fromJson(e)).toList();
  }

  // --------- GROUP INVITES ---------

  Future<GroupInvite> inviteUserToGroup(String userId, int groupId) async {
    final response = await _dio.put('/groups/$groupId/invites/$userId');
    return GroupInvite.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<void> deleteGroupInvite(String userId, int groupId) async {
    await _dio.delete('/groups/$groupId/invites/$userId');
  }

  Future<List<User>> getInvitedUsersInGroup(int groupId) async {
    final response = await _dio.get('/groups/$groupId/invites');
    var userList = response.data['data'] as List;
    return userList.map((e) => User.fromJson(e)).toList();
  }

  Future<List<Group>> getGroupsInvitedTo() async {
    final response = await _dio.get('/users/me/invites');
    var groupList = response.data['data'] as List;
    return groupList.map((e) => Group.fromJson(e)).toList();
  }

  Future<void> declineGroupInvite(int groupId) async {
    _dio.delete('/groups/$groupId/invites/me');
  }

  // --------- ACTIVITIES ---------
  Future<Activity> createActivity(
      int groupId,
      String name,
      DateTime scheduled,
      int difficulty,
      double latitude,
      double longitude,
      String address,
      List<Challenge> challenges) async {
    final response = await _dio.post('/groups/$groupId/activities', data: {
      "activity_name": name,
      "scheduled_date": scheduled.toIso8601String(),
      "difficulty_code": difficulty,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "challenges": challenges.map((e) => {"id": e.id}).toList(),
    });
    return Activity.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<Activity>> getActivities(int groupId, int skip, int limit) async {
    final response =
        await _dio.get('/groups/$groupId/activities', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var activityList = response.data['data'] as List;
    return activityList.map((e) => Activity.fromJson(e)).toList();
  }

  Future<Activity> getActivity(int groupId, int activityId) async {
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
    if (updateFields.isEmpty) {
      throw const FormatException(
          'updateActivity called without updated arguments');
    }

    final response = await _dio.patch(
      '/groups/$groupId/activities/$activityId',
      data: updateFields,
    );
    return Activity.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<void> deleteActivity(int groupId, int activityId) async {
    await _dio.delete('/groups/$groupId/activities/$activityId');
  }

  Future<void> joinActivity(
      int groupId, int activityId, String participantId) async {
    await _dio.put(
        '/group/$groupId/activities/$activityId/participants/$participantId');
  }

  Future<List<User>> getActivityParticipants(
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

  Future<List<Activity>> getUserActivities(
      String userId, int skip, int limit) async {
    final response =
        await _dio.get('/users/$userId/activities', queryParameters: {
      'skip': skip,
      'limit': limit,
    });

    var activityList = response.data['data'] as List;
    return activityList.map((e) => Activity.fromJson(e)).toList();
  }

  Future<void> leaveActivity(
      int groupId, int acitivityId, String participantId) async {
    await _dio.delete(
        '/groups/$groupId/activities/$acitivityId/participants/$participantId');
  }

  // --------- CHALLENGES ---------
  Future<List<Challenge>> getChallenges(int skip, int limit) async {
    final response = await _dio.get('/challenges', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var challengeList = response.data['data'] as List;
    return challengeList.map((e) => Challenge.fromJson(e)).toList();
  }

  // --------- IMAGE RETRIEVAL ---------
  Future<ImageProvider> getImage(String imageId) async {
    try {
      final response = await _dio.get(
        "https://images-pvt.edt.cx/images/$imageId",
        options: Options(
            responseType: ResponseType.bytes), // Set response type as bytes
      );
      return MemoryImage(response.data);
    } on DioException catch (e) {
      if (e.response == null) {
        rethrow;
      }
      if (e.response!.statusCode == 404) {
        // Check if data exists and is in byte form, otherwise handle the error or throw
        if (e.response!.data is List<int>) {
          return MemoryImage(Uint8List.fromList(e.response!.data));
        } else {
          throw Exception('Error handling response data');
        }
      }
      rethrow;
    }
  }

  // --------- IMAGE UPLOADS/DELETIONS ---------
  Future<FormData> _getFormDataFromImage(XFile file) async {
    return FormData.fromMap({
      "image": await MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: file.name,
        contentType: MediaType.parse(file.mimeType ?? 'image/jpeg'),
      ),
    });
  }

  Future<void> uploadProfilePicture(XFile file) async {
    final userId = await getMe().then((value) => value.id);
    await _dio.put(
      '/users/$userId/profile/picture',
      data: await _getFormDataFromImage(file),
    );
    // Clear "me" cache
    _me = null;
  }

  Future<void> deleteProfilePicture() async {
    final userId = await getMe().then((value) => value.id);
    await _dio.delete('/users/$userId/profile/picture');
    // Clear "me" cache
    _me = null;
  }

  Future<void> uploadGroupPicture(int groupId, XFile file) async {
    await _dio.put(
      '/groups/$groupId/picture',
      data: await _getFormDataFromImage(file),
    );
  }

  Future<void> deleteGroupPicture(int groupId) async {
    await _dio.delete('/groups/$groupId/picture');
  }

  Future<void> uploadActivityPicture(
      int groupId, int activityId, XFile file) async {
    await _dio.put(
      '/groups/$groupId/activities/$activityId/picture',
      data: await _getFormDataFromImage(file),
    );
  }

  Future<void> deleteActivityPicture(int groupId, int activityId) async {
    await _dio.delete('/groups/$groupId/activities/$activityId/picture');
  }

  // --------- HEALTH DATA UPLOAD ---------
  Future<List<Achievement>> uploadHealthData(
      List<Map<String, dynamic>> data) async {
    final userId = await getMe().then((value) => value.id);
    final response =
        await _dio.post('/users/$userId/health', data: {'data': data});
    var achievementList = response.data['data'] as List;
    return achievementList.map((e) => Achievement.fromJson(e)).toList();
  }

  // --------- ACHIEVEMENTS ---------
  Future<List<Achievement>> getAchievements(int skip, int limit) async {
    final response = await _dio.get('/achievements', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    var achievementList = response.data['data'] as List;
    return achievementList.map((e) => Achievement.fromJson(e)).toList();
  }

  Future<Achievement> getAchievement(int achievementId) async {
    final response = await _dio.get('/achievements/$achievementId');
    return Achievement.fromJson((response.data) as Map<String, dynamic>);
  }

  Future<List<Achievement>> getUserAchievements(String userId) async {
    final response = await _dio.get('/users/$userId/achievements');
    var achievementList = response.data['data'] as List;
    return achievementList.map((e) => Achievement.fromJson(e)).toList();
  }

  // --------- SHARING ---------
  Future<XFile> getAchievementShareImage(
      String userId, int achievementId) async {
    final response = await _dio.get(
      '/users/$userId/achievements/$achievementId/share',
      options: Options(
          responseType: ResponseType.bytes), // Set response type as bytes
    );
    String mimeType =
        response.headers.map['content-type']?.first ?? 'image/jpeg';
    String fileExtension = mimeType.split('/').last;
    return XFile.fromData(Uint8List.fromList(response.data),
        mimeType: mimeType, name: 'achievement_share.$fileExtension');
  }

  Future<XFile> getActivityShareImage(
      String userId, int activityId, int groupId) async {
    final response = await _dio.get(
        '/users/$userId/activities/$activityId/share',
        options: Options(
            responseType: ResponseType.bytes), // Set response type as bytes
        queryParameters: {
          'group_id': groupId,
        });
    String mimeType =
        response.headers.map['content-type']?.first ?? 'image/jpeg';
    String fileExtension = mimeType.split('/').last;
    return XFile.fromData(Uint8List.fromList(response.data),
        mimeType: mimeType, name: 'activity_share.$fileExtension');
  }
}
