// import 'package:dio/dio.dart';
// import 'package:flutter_application/controllers/backend_service.dart';
// import 'package:flutter_application/models/dio_client.dart';
// import 'package:flutter_application/models/group.dart';
// import 'package:flutter_application/models/user.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http_mock_adapter/http_mock_adapter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  // Needs to be here
}

// void main() {
//   late Dio dio;
//   late DioAdapter dioAdapter;
//   late BackendService backendService;
//   late DioClient dioClient;
  
//   group('Backend API Test', () {

//     setUpAll(() async {
//       await dotenv.load(fileName: '.env');
//     });

//     setUp(() {
//       dio = Dio(BaseOptions(
//         baseUrl: dotenv.env['BACKEND_API_URL']!,
//         headers: {'Content-Type': 'application/json'},
//       ));
//       dioAdapter = DioAdapter(dio: dio,
//             matcher: const FullHttpRequestMatcher(needsExactBody: true),
//           );
//       backendService = BackendService.withDio(dio);
      
//     });

//     test('fetchGroup() - return a group after successful http request', () async {
//       int groupId = 4;
//       String path = '/groups/$groupId';

//       dioAdapter.onGet(
//         path,
//         (server) => server.reply(
//           200,
//           {"id": 1,
//            "group_name": "mock", 
//            "description": "mock", 
//            "private": true},
//         ),
//       );

//       expect(await backendService.fetchGroup(groupId), isA<Group>());
//     });

//     test('fetchGroup() - throws DioException after unsuccessful http request', () async {
//       int groupId = 4;
//       String path = '/groups/$groupId';

//       dioAdapter.onGet(
//         path, 
//         (server) {server.throws(
//           404, 
//           DioException(
//             requestOptions: RequestOptions(
//               path: path
//             )
//           ));
//         }
//       );

//       expect(
//         () async => await backendService.fetchGroup(groupId), 
//         throwsA(isA<DioException>())
//       );
//     });

//       test('createGroup() - returns a group after successful http request', () async {
//       String path = '/groups';
//       String name = "mock";
//       String description = "mock";
//       bool isPrivate = true;

//       dioAdapter.onPost(
//         path,
//         (server) => server.reply(
//           200,
//           {"id": 4,
//           "group_name": name,
//           "description": description,
//           "private": isPrivate}
//         ),
//         data: {"group_name": name,
//           "description": description,
//           "private": isPrivate}
//       );

//       expect(await backendService.createGroup(name, description, isPrivate), isA<Group>());
//     });

//     test('createGroup() - throws DioException after unsuccessful http request', () async {
//       String path = '/groups';
//       String name = "mock";
//       String description = "mock";
//       bool isPrivate = true;

//       dioAdapter.onPost(
//         path, 
//         (server) {server.throws(
//           404, 
//           DioException(
//             requestOptions: RequestOptions(
//               path: path
//             )
//           ));
//         },

//       );

//       expect(
//         () async => await backendService.createGroup(name, description, isPrivate), 
//         throwsA(isA<DioException>())
//       );
//     });

//     test('fetchGroups() - return a list of groups after successful http request', () async {
//       int skip = 0;
//       int limit = 10;
//       String path = '/groups';

//       dioAdapter.onGet(
//         path,
//         queryParameters: {
//           'skip': skip, 
//           'limit': limit,
//         },
//         (server) => server.reply(
//           200,
//           {"data": [{"group_name": "uppdaterall","description": "hejdå","private": false,"id": 6},{"group_name": "johan","description": "test","private": false,"id": 7}]} 
//         ),
//       );

//       expect(await backendService.fetchGroups(skip, limit), isA<List<Group>>());
//     });

//     test('fetchGroups() - throws DioException after unsuccessful http request', () async {
//       int skip = 0;
//       int limit = 10;
//       String path = '/groups?skip=$skip&limit=$limit';

//       dioAdapter.onGet(
//         path, 
//         (server) => server.throws(
//           400, 
//           DioException(requestOptions: RequestOptions(path: path))
//         ),
//       );

//       expect(() async => await backendService.fetchGroups(skip, limit), throwsA(isA<DioException>()));
//     });

//     test('updateGroup() - returns a group after successful http request', () async {
//       int groupId = 1;
//       String path = '/groups/$groupId';
//       String updatedField = 'newName';

//       dioAdapter.onPatch(
//         path, 
//         (server) => server.reply(
//           200, 
//           {"id": 1,
//            "group_name": updatedField, 
//            "description": "mock", 
//            "private": true},
//         ),
//         data: {'group_name': updatedField},
//       );

//       expect(await backendService.updateGroup(groupId, newName: updatedField), isA<Group>());
//     });

//     test('updateGroup() - returns a DioException after unsuccessful http request', () async {
//       int groupId = 1;
//       String path = '/groups/$groupId';
//       String updatedField = 'newName';

//       dioAdapter.onPatch(
//         path, 
//         (server) => server.throws(
//           400, 
//           DioException(requestOptions: RequestOptions(path: path))
//         ),
//         data: {'group_name': updatedField},
//       );

//       expect(() async => await backendService.updateGroup(groupId, newName: updatedField), throwsA(isA<DioException>()));
//     });

//     test('fetchUser() - successful api call', () async {
//       int userId = 1;
//       String path = '/users/$userId';

//       dioAdapter.onGet(
//         path, 
//         (server) => server.reply(
//           200, 
//           {
//             "username": "string",
//             "full_name": "string",
//             "id": 0,
//             "date_created": "string"
//           }
//         )
//       );
//       expect(await backendService.fetchUser(userId), isA<User>());
//     });

//     test('fetchUsers() - successful api call', () async {

//     });
//     test('test', () async {
//       BackendService bs = BackendService.withDio(DioClient());
//       User user = await bs.fetchUser(1);
//       print(user.fullName);

//     });
//   }); // GROUP



//   /*
//     WARNING! Production tests
//    */

//   // group('Live tests against DB', () {
//   //   test('fetch', () async {
//   //     BackendService bs = BackendService();
//   //     int groupId = 1;
//   //     try {
//   //       Group gr = await bs.fetchGroup(groupId);
//   //       print(gr.description);
//   //     } catch (e) {
//   //       print('Error fetching group: $e');
//   //     }
//   //   });

//   //   test('create', () async {
//   //     BackendService bs = BackendService();
//   //     String name = "createGrup()1";
//   //     String description = "JOHANTESTAR1";
//   //     bool isPrivate = false;
      
//   //     Group gr = await bs.createGroup(name, description, isPrivate);
//   //     print(gr.description);
//   //   });

//   //   test('fetchgroups', () async {
//   //     BackendService bs = BackendService();
//   //     int skip = 0;
//   //     int limit = 20;

//   //     List<Group> groups = await bs.fetchGroups(skip, limit);

//   //     for (final g in groups) {
//   //       print("id: ${g.id}");
        
//   //     }
//   //   });

//   //   test('updategroup', () async {
//   //     BackendService bs = BackendService();
//   //     int groupId = 1;
//   //     String newDescription = "HEHE NY DESC IGEN";

//   //     Group g = await bs.updateGroup(groupId, description: newDescription);
//   //     expect(newDescription, g.description);
//   //   });
//   // });
// }
