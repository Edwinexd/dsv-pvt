// Declare the interface for the backend service
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/models/profile.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/group_invite.dart';
import 'package:flutter_application/models/activity.dart';
import 'package:flutter_application/models/challenges.dart';
import 'package:flutter_application/models/achievement.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';

abstract class BackendServiceInterface {
  // Users
  Future<User> getMe();
  Future<bool> isLoggedIn();
  Future<void> login(String email, String password);
  Future<void> loginOauthGoogle(String? accessToken, String? idToken);
  Future<void> logout();
  Future<User> createUser(String userName, String email, String fullName, String password);
  Future<List<User>> getUsers(int skip, int limit);
  Future<User> getMyUser();
  Future<User> getUser(String userId);
  Future<User> updateUser(String userId, {String? userName, String? fullName});
  Future<void> deleteUser(String userId);

  // Profile
  Future<Profile> createProfile(String userId, String description, int age,
      String interests, int skillLevel, bool isPrivate, String location, String? runnerId);
  Future<Profile> getProfile(String userId);
  Future<Profile> updateProfile(String userId,
      {String? description, int? age, String? interests, int? skillLevel, bool? isPrivate, String? location, String? runnerId});
  Future<void> deleteProfile(String userId);

  // Groups
  Future<Group> createGroup(String name, String description, bool isPrivate, String ownedId, int skillLevel, double? latitude, double? longitude, String? address);
  Future<List<Group>> getGroups(int skip, int limit, GroupOrderType orderBy, bool descending);
  Future<Group> getGroup(int groupId);
  Future<Group> updateGroup(int groupId, {String? newName, String? description, int? skillLevel, bool? isPrivate});
  Future<void> deleteGroup(int groupdId);
  Future<Group> joinGroup(String userId, int groupId);
  Future<Group> leaveGroup(String userId, int groupId);
  Future<List<User>> getGroupMembers(int groupId);
  Future<List<Group>> getMyGroups();
  Future<List<Group>> getUserGroups(String userId);

  // Group Invites
  Future<GroupInvite> inviteUserToGroup(String userId, int groupId);
  Future<void> deleteGroupInvite(String userId, int groupId);
  Future<List<User>> getInvitedUsersInGroup(int groupId);
  Future<List<Group>> getGroupsInvitedTo();
  Future<void> declineGroupInvite(int groupId);

  // Activities
  Future<Activity> createActivity(int groupId, String name, DateTime scheduled, int difficulty, double latitude, double longitude, String address, List<Challenge> challenges);
  Future<List<Activity>> getActivities(int groupId, int skip, int limit);
  Future<Activity> getActivity(int groupId, int activityId);
  Future<Activity> updateActivity(int groupId, int activityId, {String? name, DateTime? scheduled, int? difficulty, bool? isCompleted});
  Future<void> deleteActivity(int groupId, int activityId);
  Future<void> joinActivity(int groupId, int activityId, String participantId);
  Future<List<User>> getActivityParticipants(int groupId, int activityId, int skip, int limit);
  Future<List<Activity>> getUserActivities(String userId, int skip, int limit);
  Future<void> leaveActivity(int groupId, int acitivityId, String participantId);

  // Challenges
  Future<List<Challenge>> getChallenges(int skip, int limit);

  // Image Retrieval
  Future<ImageProvider> getImage(String imageId);

  // Image Uploads/Deletions
  Future<void> uploadProfilePicture(XFile file);
  Future<void> deleteProfilePicture();
  Future<void> uploadGroupPicture(int groupId, XFile file);
  Future<void> deleteGroupPicture(int groupId);
  Future<void> uploadActivityPicture(int groupId, int activityId, XFile file);
  Future<void> deleteActivityPicture(int groupId, int activityId);

  // Health Data Upload
  Future<List<Achievement>> uploadHealthData(List<Map<String, dynamic>> data);

  // Achievements
  Future<List<Achievement>> getAchievements(int skip, int limit);
  Future<Achievement> getAchievement(int achievementId);
  Future<List<Achievement>> getUserAchievements(String userId);

  // Sharing
  Future<XFile> getAchievementShareImage(String userId, int achievementId);
  Future<XFile> getActivityShareImage(String userId, int activityId, int groupId);
}
