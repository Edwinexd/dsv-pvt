import 'dart:io';

import 'package:flutter_application/controllers/group_controller.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'group_controller_test.mocks.dart' as mocks;


// Generate a MockClient using the Mockita package.
// Create new instanes of this class in each test.
@GenerateMocks([http.Client])


void main() {
  final client = mocks.MockClient();
  final groupController = GroupController();
  groupController.client = client;
  
  group('fetchGroup()', () {

    setUp(() {
      reset(client);
    });

    test('returns a Group if the http call completes successfully', () async {
      int groupId = 1;
      String URL = 'https://jsonplaceholder.typicode.com/albums/1';

      // Mocking the HTTP request response
      when(client.get(
        any,
        headers: anyNamed('headers')  // Correctly specifying the parameter name
      )).thenAnswer((_) async => http.Response('{"id": 1, "name": "mock", "description": "mock", "isPublic": true}', 200));

      expect(await groupController.fetchGroup(groupId), isA<Group>());

      // Verify that the client used the specified headers
      verify(client.get(
        Uri.parse(URL),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
        }
      )).called(1);
    });
  });

  
    test('throws an exception if the http call completes with an error', () async {
      int groupId = 1;
      String URL = 'https://jsonplaceholder.typicode.com/albums/1';

      when(client.get(
        any,
        headers: anyNamed('headers'),))
        .thenAnswer((_) async =>
          http.Response('Not Found', 404));
      
      expect(groupController.fetchGroup(groupId), throwsException);
    });
  
  }