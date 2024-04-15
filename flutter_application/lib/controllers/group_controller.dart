import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/models/group.dart';
import 'package:http/http.dart' as http;

class GroupController {
  Future<Group> fetchGroup() async {
  final response = await http
    .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'),

    headers: {
      HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
    },
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Group.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw and exception.
    throw Exception('Failed to load group');
  }
}
}