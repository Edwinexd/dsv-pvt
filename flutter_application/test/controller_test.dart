import 'package:flutter_application/controllers/group_controller.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'controller_test.mocks.dart' as mocks;


// Generate a MockClient using the Mockita package.
// Create new instanes of this class in each test.
@GenerateMocks([http.Client])
void main() {
  group('fetchGroup()', () {
    test('returns a Group if the http call completes successfully', () async {
      final client = mocks.MockClient();
      final groupController = GroupController();

      // Mocking the HTTP request response
      when(client
          .get(Uri.parse('url')))
        .thenAnswer((_) async => 
          http.Response('{"id": 1, "name": "mock", "description": "mock", "isPublic": true}', 200));

      expect(await groupController.fetchGroup(), isA<Group>());
    });

    test('throws an exception if the http call completes with an error', () async {
      final client = mocks.MockClient();
      final groupController = GroupController();

      when(client
        .get(Uri.parse('url'),
          headers: anyNamed('headers'),))
        .thenAnswer((_) async =>
          http.Response('Not Found', 404));
      
      expect(groupController.fetchGroup(), throwsException);
    });
  });
}

