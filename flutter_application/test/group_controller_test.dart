import 'dart:convert';

import 'package:flutter_application/controllers/group_controller.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';


// Generate a MockClient using the Mockita package.
// Create new instanes of this class in each test.
@GenerateMocks([http.Client])
import 'group_controller_test.mocks.dart' as mocks;


void main() {
  final client = mocks.MockClient();
  final groupController = GroupController();
  groupController.client = client;
  String groupUrl = "http://10.97.231.1:81/groups";

  
  group('Group Controller', () {

    setUp(() {
      reset(client);
    });

    test('fetchGroup() - return a group after successful http request', () async {
      int groupId = 4;

      when(client.get(
        any,
        headers: anyNamed('headers')
      )).thenAnswer((_) async => http.Response('{"id": 1, "group_name": "mock", "description": "mock", "private": true}', 200));

      expect(await groupController.fetchGroup(groupId), isA<Group>());
    });

    test('fetchGroup() - throws exception after unsuccessful http request', () async {
      int groupId = 4;

      when(client.get(
        any,
        headers: anyNamed('headers'),))
        .thenAnswer((_) async =>
          http.Response('Not Found', 404));
      
      expect(groupController.fetchGroup(groupId), throwsException);
    });

    test('createGroup() - returns a group after successful http request', () async {
      String name = "test";
      String description = "";
      bool isPrivate = false;

      when(client.post(
        Uri.parse(groupUrl), 
        headers: <String,String> {
          'Content-Type' : 'application/json'
        },
        body: jsonEncode({
          "group_name": name,
          "description": description,
          "private": isPrivate,
        }),
      )).thenAnswer((_) async => http.Response('{"id": 1, "group_name": "mock", "description": "mock", "private": true}', 200));

      expect(await groupController.createGroup(name, description, isPrivate), isA<Group>());
    });

    // TODO: Unfinished - Maybe 
    test('fetchGroups() - return a list of groups after successful http request', () async {
      int skip = 0;
      int limit = 10;
      Uri uri = Uri.parse("$groupUrl?skip=$skip&limit=$limit");

      when(client.get(
        uri,
      )).thenAnswer((_) async => http.Response('{"data": [{"group_name": "uppdaterall","description": "hejdå","private": false,"id": 6},{"group_name": "johan","description": "test","private": false,"id": 7}]}', 200));

      expect(await groupController.fetchGroups(skip, limit), isA<List<Group>>());
    });

  });

  /*
    WARNING! Production tests
   */

  // group('Live tests against DB', () {
  //   test('fetch', () async {
  //     GroupController gc = GroupController();
  //     int groupId = 1;
  //     try {
  //       Group gr = await gc.fetchGroup(groupId);
  //       print(gr.description);
  //     } catch (e) {
  //       print('Error fetching group: $e');
  //     }
  //   });

  //   test('create', () async {
  //     GroupController gc = GroupController();
  //     String name = "createGrup()";
  //     String description = "JOHANTESTAR";
  //     bool isPrivate = false;
      
  //     Group gr = await gc.createGroup(name, description, isPrivate);
  //     print(gr.description);
  //   });

  //   test('fetchgroups', () async {
  //     GroupController gc = GroupController();
  //     int skip = 0;
  //     int limit = 20;

  //     List<Group> groups = await gc.fetchGroups(skip, limit);

  //     for (final g in groups) {
  //       print("id: ${g.id}");
        
  //     }
  //   });

  //   test('updategroup', () async {
  //     GroupController gc = GroupController();
  //     int groupId = 1;
  //     String newDescription = "hehe ny desc";

  //     Group g = await gc.updateGroup(groupId, description: newDescription);
  //     expect(newDescription, g.description);
  //   });
  // });

}