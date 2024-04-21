import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/models/group.dart';
import 'package:http/http.dart' as http;

class GroupController {
  http.Client client = http.Client();

  // void setClient(http.Client newClient) {
  //   client = newClient;
  // }

  Future<Group> fetchGroup(int groupId) async {
    String URL = 'https://jsonplaceholder.typicode.com/albums/$groupId';

    final response = await client
      .get(Uri.parse(URL),

      headers: {
        HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
      },
    );
  
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Group.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load group');
    }
  }


  // void createGroup(http.Client client) async {
  //   final response = await http
  //     .post(Uri.parse('url'),
  //     headers: {
  //       HttpHeaders.authorizationHeader: 'Basic your_api_token_here'
  //     },
  //     body: jsonEncode(Group.toJson(group))
  //   );

  //   if (response.statusCode == 200) {
  //     // TODO: Not sure what to return
  //   } else {
  //     throw Exception('Failed to create group');
  //   }
  // }

  void updateGroupName(String groupId, String newName) async {
    final response = await http
      .put(Uri.parse('url'),
      headers: {
        HttpHeaders.authorizationHeader: 'Basic your_api_token_here'
      },
      body: jsonEncode(<String, String>{
        'name': newName
      }),
    );

    if (response.statusCode == 200) {
      // TODO: Not sure what to return
    } else {
      throw Exception('Failed to update group data');
    }
  }
}