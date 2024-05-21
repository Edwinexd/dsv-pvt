import 'package:dio/dio.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/profile.dart';
import 'package:flutter_application/models/role.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late BackendService backendService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
  });

  setUp(() async {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);

    dio.options.baseUrl = dotenv.env['BACKEND_API_URL']!;
    dio.options.headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    backendService = BackendService();
    backendService.setDio(dio);
  });

  group('BackendService Tests', () {
    group('createUser Tests', () {
      test('createUser returns a User object on success', () async {
        // Arrange
        const userName = 'testUser';
        const email = 'test@example.com';
        const fullName = 'Test User';
        const password = 'password123';

        final mockResponse = {
          "email": email,
          "username": userName,
          "full_name": fullName,
          "id": "testId",
          "role": 2,
          "date_created": "2024-05-20T12:59:21.461Z",
        };

        dioAdapter.onPost(
          '/users',
          (server) => server.reply(200, mockResponse),
          data: {
            "email": email,
            "username": userName,
            "full_name": fullName,
            "password": password,
          },
        );

        dioAdapter
            .onPost('/users/login', (server) => server.reply(200, {}), data: {
          "email": email,
          "password": password,
        });

        // Act
        final user = await backendService.createUser(
            userName, email, fullName, password);

        // Assert
        expect(user, isA<User>());
        expect(user.userName, equals(userName));
        expect(user.email, equals(email));
        expect(user.userName, equals(userName));
      });
    });
    group('getUsers Tests', () {
      test('getUsers returns a list of User objects on success', () async {
        // Arrange
        const path = '/users';
        const skip = 0;
        const limit = 10;
        const fullName = 'Test User';

        final mockResponse = {
          "data": [
            {
              "email": "string",
              "username": "string",
              "full_name": fullName,
              "id": "string",
              "role": 2,
              "date_created": "2024-05-20T13:51:49.615Z"
            },
            {
              "email": "string",
              "username": "string",
              "full_name": "string",
              "id": "string",
              "role": 2,
              "date_created": "2024-05-20T13:51:49.615Z"
            }
          ]
        };

        dioAdapter.onGet(
          path,
          queryParameters: {
            'skip': skip,
            'limit': limit,
          },
          (server) => server.reply(
            200,
            mockResponse,
          ),
        );

        // Act
        final List<User> users = await backendService.getUsers(skip, limit);

        // Assert
        expect(users, isA<List<User>>());
        expect(users[0].fullName, equals(fullName));
      });

      test('getUsers throws DioException on bad request', () async {
        // Arrange
        const path = '/users';
        const skip = 0;
        const limit = 10;

        dioAdapter.onGet(
          path,
          queryParameters: {
            'skip': skip,
            'limit': limit,
          },
          (server) => server.throws(
              400, DioException(requestOptions: RequestOptions(path: path))),
        );

        // Assert
        expect(() async => await backendService.getUsers(skip, limit),
            throwsA(isA<DioException>()));
      });
    });

    group('getMyUser Tests', () {
      test('getMyUser returns a User object on sucess', () async {
        // Arrange
        const path = '/users/me';
        final mockResponse = {
          "email": 'test@example.com',
          "username": 'testUser',
          "full_name": 'Test User',
          "id": "string",
          "role": 2,
          "date_created": "2024-05-20T12:59:21.461Z",
        };

        dioAdapter.onGet(
          path,
          (server) => server.reply(
            200,
            mockResponse,
          ),
        );

        // Act
        final User user = await backendService.getMe();

        // Assert
        expect(user, isA<User>());
      });
    });

    group('getUser Tests', () {
      test('getUser returns a User object on success', () async {
        // Arrange
        const userId = '123';
        final mockResponse = {
          "id": userId,
          "email": "test@example.com",
          "username": "testUser",
          "full_name": "Test User",
          "role": 2,
          "date_created": "2024-05-20T14:53:01.955Z",
        };

        dioAdapter.onGet(
          '/users/$userId',
          (server) => server.reply(200, mockResponse),
        );

        // Act
        final user = await backendService.getUser(userId);

        // Assert
        expect(user, isA<User>());
        expect(user.id, equals(userId));
        expect(user.email, equals("test@example.com"));
        expect(user.userName, equals("testUser"));
        expect(user.fullName, equals("Test User"));
        expect(user.role, equals(Role.parse(2)));
        expect(user.dateCreated,
            equals(DateTime.parse("2024-05-20T14:53:01.955Z")));
      });

      test('getUser throws a DioException on bad request', () async {
        // Arrange
        const userId = 'invalidId';
        final errorResponse = {"error": "User not found"};

        dioAdapter.onGet(
          '/users/$userId',
          (server) => server.reply(400, errorResponse),
        );

        // Act & Assert
        try {
          await backendService.getUser(userId);
          fail("Expected a DioException to be thrown");
        } catch (e) {
          expect(e, isA<DioException>());
          if (e is DioException) {
            expect(e.response?.statusCode, 400);
            expect(e.response?.data, errorResponse);
          }
        }
      });
    });

    group('updateUser Tests', () {
      test('updateUser returns a User object on success with userName',
          () async {
        // Arrange
        const userId = '123';
        const userName = 'newUsername';
        final mockResponse = {
          "id": userId,
          "email": "test@example.com",
          "username": userName,
          "full_name": "Test User",
          "role": 2,
          "date_created": "2024-05-20T14:53:01.955Z",
        };

        dioAdapter.onPatch(
          '/users/$userId',
          (server) => server.reply(200, mockResponse),
          data: {
            "username": userName,
          },
        );

        // Act
        final user =
            await backendService.updateUser(userId, userName: userName);

        // Assert
        expect(user, isA<User>());
        expect(user.id, equals(userId));
        expect(user.email, equals("test@example.com"));
        expect(user.userName, equals(userName));
        expect(user.fullName, equals("Test User"));
      });

      test('updateUser returns a User object on success with fullName',
          () async {
        // Arrange
        const userId = '123';
        const fullName = 'New Full Name';
        final mockResponse = {
          "id": userId,
          "email": "test@example.com",
          "username": "testUser",
          "full_name": fullName,
          "role": 2,
          "date_created": "2024-05-20T14:53:01.955Z",
        };

        dioAdapter.onPatch(
          '/users/$userId',
          (server) => server.reply(200, mockResponse),
          data: {
            "full_name": fullName,
          },
        );

        // Act
        final user =
            await backendService.updateUser(userId, fullName: fullName);

        // Assert
        expect(user, isA<User>());
        expect(user.id, equals(userId));
        expect(user.email, equals("test@example.com"));
        expect(user.userName, equals("testUser"));
        expect(user.fullName, equals(fullName));
      });

      test(
          'updateUser returns a User object on success with userName and fullName',
          () async {
        // Arrange
        const userId = '123';
        const userName = 'newUsername';
        const fullName = 'New Full Name';
        final mockResponse = {
          "id": userId,
          "email": "test@example.com",
          "username": userName,
          "full_name": fullName,
          "role": 2,
          "date_created": "2024-05-20T14:53:01.955Z",
        };

        dioAdapter.onPatch(
          '/users/$userId',
          (server) => server.reply(200, mockResponse),
          data: {
            "username": userName,
            "full_name": fullName,
          },
        );

        // Act
        final user = await backendService.updateUser(userId,
            userName: userName, fullName: fullName);

        // Assert
        expect(user, isA<User>());
        expect(user.id, equals(userId));
        expect(user.email, equals("test@example.com"));
        expect(user.userName, equals(userName));
        expect(user.fullName, equals(fullName));
      });
      test(
          'updateUser throws a FormatException when no update fields are provided',
          () async {
        // Arrange
        const userId = '123';

        // Act & Assert
        expect(
          () async => await backendService.updateUser(userId),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            'updateUser called without updated arguments',
          )),
        );
      });

      test('updateUser throws a DioException on bad request', () async {
        // Arrange
        const userId = 'invalidId';
        const userName = 'newUsername';
        const fullName = 'New Full Name';
        final errorResponse = {"error": "User not found"};

        dioAdapter.onPatch(
          '/users/$userId',
          (server) => server.reply(400, errorResponse),
          data: {
            "username": userName,
            "full_name": fullName,
          },
        );

        // Act & Assert
        try {
          await backendService.updateUser(userId,
              userName: userName, fullName: fullName);
          fail("Expected a DioException to be thrown");
        } catch (e) {
          expect(e, isA<DioException>());
          if (e is DioException) {
            expect(e.response?.statusCode, 400);
            expect(e.response?.data, errorResponse);
          }
        }
      });
    });
    group('deleteUser Tests', () {
      test('deleteUser completes successfully', () async {
        // Arrange
        const userId = '123';

        dioAdapter.onDelete(
          '/users/$userId',
          (server) => server.reply(200, {}),
        );

        // Act
        await backendService.deleteUser(userId);

        // Assert
        // If no exception is thrown, the test passes.
      });

      test('deleteUser throws DioException on user not found', () async {
        // Arrange
        const userId = 'nonExistentUser';
        final errorResponse = {"error": "User not found"};

        dioAdapter.onDelete(
          '/users/$userId',
          (server) => server.reply(404, errorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.deleteUser(userId),
          throwsA(isA<DioException>()),
        );
      });

      test('deleteUser throws DioException on server error', () async {
        // Arrange
        const userId = '123';
        final errorResponse = {"error": "Internal server error"};

        dioAdapter.onDelete(
          '/users/$userId',
          (server) => server.reply(500, errorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.deleteUser(userId),
          throwsA(isA<DioException>()),
        );
      });
    }); // BackendService deleUser Tests
    group('createProfile Tests', () {
      test('createProfile returns a Profile object on success', () async {
        // Arrange
        const userId = '123';
        const description = 'This is a test profile';
        const age = 25;
        const interests = 'Running, Hiking';
        const skillLevel = 3;
        const isPrivate = false;
        const location = 'Test City';
        const runnerId = 'runner123';

        final mockResponse = {
          "description": description,
          "age": age,
          "interests": interests,
          "skill_level": skillLevel,
          "is_private": isPrivate,
          "location": location,
          "runner_id": runnerId,
          "image_id": null,
        };

        dioAdapter.onPut(
          '/users/$userId/profile',
          (server) => server.reply(200, mockResponse),
          data: {
            "description": description,
            "age": age,
            "interests": interests,
            "skill_level": skillLevel,
            "is_private": isPrivate,
            "location": location,
            "runner_id": runnerId,
          },
        );

        // Act
        final profile = await backendService.createProfile(userId, description,
            age, interests, skillLevel, isPrivate, location, runnerId);

        // Assert
        expect(profile, isA<Profile>());
        expect(profile.description, equals(description));
        expect(profile.age, equals(age));
        expect(profile.interests, equals(interests));
        expect(profile.skillLevel, equals(skillLevel));
        expect(profile.isPrivate, equals(isPrivate));
        expect(profile.location, equals(location));
        expect(profile.runnerId, equals(runnerId));
        expect(profile.imageId, isNull);
      });

      test('createProfile handles missing optional runnerId', () async {
        // Arrange
        const userId = '123';
        const description = 'This is a test profile';
        const age = 25;
        const interests = 'Running, Hiking';
        const skillLevel = 3;
        const isPrivate = false;
        const location = 'Test City';
        const runnerId = null;

        final mockResponse = {
          "description": description,
          "age": age,
          "interests": interests,
          "skill_level": skillLevel,
          "is_private": isPrivate,
          "location": location,
          "runner_id": runnerId,
          "image_id": null,
        };

        dioAdapter.onPut(
          '/users/$userId/profile',
          (server) => server.reply(200, mockResponse),
          data: {
            "description": description,
            "age": age,
            "interests": interests,
            "skill_level": skillLevel,
            "is_private": isPrivate,
            "location": location,
            "runner_id": runnerId,
          },
        );

        // Act
        final profile = await backendService.createProfile(userId, description,
            age, interests, skillLevel, isPrivate, location, runnerId);

        // Assert
        expect(profile, isA<Profile>());
        expect(profile.description, equals(description));
        expect(profile.age, equals(age));
        expect(profile.interests, equals(interests));
        expect(profile.skillLevel, equals(skillLevel));
        expect(profile.isPrivate, equals(isPrivate));
        expect(profile.location, equals(location));
        expect(profile.runnerId, isNull);
        expect(profile.imageId, isNull);
      });

      test('createProfile throws DioException on bad request', () async {
        // Arrange
        const userId = '123';
        const description = 'This is a test profile';
        const age = -1; // Invalid age
        const interests = 'Running, Hiking';
        const skillLevel = 3;
        const isPrivate = false;
        const location = 'Test City';
        const runnerId = 'runner123';
        final errorResponse = {"error": "Invalid age value"};

        dioAdapter.onPut(
          '/users/$userId/profile',
          (server) => server.reply(400, errorResponse),
          data: {
            "description": description,
            "age": age,
            "interests": interests,
            "skill_level": skillLevel,
            "is_private": isPrivate,
            "location": location,
            "runner_id": runnerId,
          },
        );

        // Act & Assert
        expect(
          () async => await backendService.createProfile(userId, description,
              age, interests, skillLevel, isPrivate, location, runnerId),
          throwsA(isA<DioException>()),
        );
      });

      test('createProfile throws DioException on server error', () async {
        // Arrange
        const userId = '123';
        const description = 'This is a test profile';
        const age = 25;
        const interests = 'Running, Hiking';
        const skillLevel = 3;
        const isPrivate = false;
        const location = 'Test City';
        const runnerId = 'runner123';
        final errorResponse = {"error": "Internal server error"};

        dioAdapter.onPut(
          '/users/$userId/profile',
          (server) => server.reply(500, errorResponse),
          data: {
            "description": description,
            "age": age,
            "interests": interests,
            "skill_level": skillLevel,
            "is_private": isPrivate,
            "location": location,
            "runner_id": runnerId,
          },
        );

        // Act & Assert
        expect(
          () async => await backendService.createProfile(userId, description,
              age, interests, skillLevel, isPrivate, location, runnerId),
          throwsA(isA<DioException>()),
        );
      });
    });
  }); // Group BackendService Tests
}
