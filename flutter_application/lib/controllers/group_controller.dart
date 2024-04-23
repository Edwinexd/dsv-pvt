import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/models/group.dart';
import 'package:http/http.dart' as http;
import 'package:http_status/http_status.dart';

class GroupController {
  http.Client client = http.Client();
  String groupURL = "http://10.97.231.1:81/groups";

  Future<Group> createGroup(String name, String description, bool private) async {
    final response = await client
      .post(Uri.parse(groupURL),
      headers: <String, String> {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(<String, dynamic> {
        "group_name": name,
        "description": description,
        "private": private,
      })
    );

    if (response.statusCode.isSuccessfulHttpStatusCode) {
      return Group.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create group');
    }
  }

  Future<Group> fetchGroup(int groupId) async {
    String URL = '$groupURL/$groupId';

    final response = await client.get(Uri.parse(URL),);
  
    if (response.statusCode.isSuccessfulHttpStatusCode) {
      return Group.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load group');
    }
  }

  Future<List<Group>> fetchGroups(int skip, int limit) async {
    String URL = "$groupURL?skip=$skip&limit=$limit";

    final response = await client.get(Uri.parse(URL));
    if (response.statusCode.isSuccessfulHttpStatusCode) {
       var jsonData = jsonDecode(response.body);
       List<Group> groups = (jsonData['data'] as List)
          .map((jsonGroup) => Group.fromJson(jsonGroup as Map<String, dynamic>))
          .toList();
       return groups;
    } else {
      throw Exception('Failed to load groups');
    }
  }

  Future<Group> updateGroup(int groupId, {String? newName, String? description, bool? isPrivate}) async {
  String URL = '$groupURL/$groupId';

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

  final response = await client.patch(Uri.parse(URL),
    headers: <String, String>{
      'Content-Type': 'application/json'
    },
    body: jsonEncode(updateFields),
  );
  print(jsonEncode(updateFields));
  if (response.statusCode.isSuccessfulHttpStatusCode) {
    return Group.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to update group data with status code: ${response.statusCode}');
  }
}

}