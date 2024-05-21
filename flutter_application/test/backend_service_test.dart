import 'package:dio/dio.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
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
group('getProfile Tests', () {
  test('getProfile returns a Profile object on success', () async {
        // Arrange
        const userId = '123';
        final mockResponse = {
          "description": "This is a test profile",
          "age": 25,
          "interests": "Running, Hiking",
          "skill_level": 3,
          "is_private": false,
          "location": "Test City",
          "runner_id": "runner123",
          "image_id": null
        };

        dioAdapter.onGet(
          '/users/$userId/profile',
          (server) => server.reply(200, mockResponse),
        );

        // Act
        final profile = await backendService.getProfile(userId);

        // Assert
        expect(profile, isA<Profile>());
        expect(profile.description, equals("This is a test profile"));
        expect(profile.age, equals(25));
        expect(profile.interests, equals("Running, Hiking"));
        expect(profile.skillLevel, equals(3));
        expect(profile.isPrivate, equals(false));
        expect(profile.location, equals("Test City"));
        expect(profile.runnerId, equals("runner123"));
        expect(profile.imageId, isNull);
      });

      test('getProfile throws DioException on profile not found', () async {
        // Arrange
        const userId = 'invalidId';
        final errorResponse = {
          "error": "Profile not found"
        };

        dioAdapter.onGet(
          '/users/$userId/profile',
          (server) => server.reply(404, errorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.getProfile(userId),
          throwsA(isA<DioException>()),
        );
      });

      test('getProfile throws DioException on server error', () async {
        // Arrange
        const userId = '123';
        final errorResponse = {
          "error": "Internal server error"
        };

        dioAdapter.onGet(
          '/users/$userId/profile',
          (server) => server.reply(500, errorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.getProfile(userId),
          throwsA(isA<DioException>()),
        );
      });
    }); // getProfile Tests

    group('updateProfile Tests', () {
      test('updateProfile returns a Profile object on success with all fields', () async {
        // Arrange
        const userId = '123';
        const description = 'Updated profile description';
        const age = 30;
        const interests = 'Swimming, Cycling';
        const skillLevel = 4;
        const isPrivate = true;
        const location = 'Updated City';
        const runnerId = 'updatedRunner123';

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

        dioAdapter.onPatch(
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
        final profile = await backendService.updateProfile(
          userId,
          description: description,
          age: age,
          interests: interests,
          skillLevel: skillLevel,
          isPrivate: isPrivate,
          location: location,
          runnerId: runnerId,
        );

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

      test('updateProfile returns a Profile object on success with some fields', () async {
        // Arrange
        const userId = '123';
        const description = 'Updated profile description';
        const age = 30;

        final mockResponse = {
          "description": description,
          "age": age,
          "interests": "Running, Hiking",
          "skill_level": 3,
          "is_private": false,
          "location": "Test City",
          "runner_id": "runner123",
          "image_id": null,
        };

        dioAdapter.onPatch(
          '/users/$userId/profile',
          (server) => server.reply(200, mockResponse),
          data: {
            "description": description,
            "age": age,
          },
        );

        // Act
        final profile = await backendService.updateProfile(
          userId,
          description: description,
          age: age,
        );

        // Assert
        expect(profile, isA<Profile>());
        expect(profile.description, equals(description));
        expect(profile.age, equals(age));
        expect(profile.interests, equals("Running, Hiking"));
        expect(profile.skillLevel, equals(3));
        expect(profile.isPrivate, equals(false));
        expect(profile.location, equals("Test City"));
        expect(profile.runnerId, equals("runner123"));
        expect(profile.imageId, isNull);
      });

      test('updateProfile throws FormatException when no fields are provided', () async {
        // Arrange
        const userId = '123';

        // Act & Assert
        expect(
          () async => await backendService.updateProfile(userId),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            'updateProfile called without updated arguments',
          )),
        );
      });

      test('updateProfile throws DioException on bad request', () async {
        // Arrange
        const userId = '123';
        const age = -5; // Invalid age
        final errorResponse = {
          "error": "Invalid age value"
        };

        dioAdapter.onPatch(
          '/users/$userId/profile',
          (server) => server.reply(400, errorResponse),
          data: {
            "age": age,
          },
        );

        // Act & Assert
        expect(
          () async => await backendService.updateProfile(userId, age: age),
          throwsA(isA<DioException>()),
        );
      });

      test('updateProfile throws DioException on server error', () async {
        // Arrange
        const userId = '123';
        const description = 'Updated profile description';
        final errorResponse = {
          "error": "Internal server error"
        };

        dioAdapter.onPatch(
          '/users/$userId/profile',
          (server) => server.reply(500, errorResponse),
          data: {
            "description": description,
          },
        );

        // Act & Assert
        expect(
          () async => await backendService.updateProfile(userId, description: description),
          throwsA(isA<DioException>()),
        );
      });
    }); // updateProfile Tests

    group('deleteProfile Tests', () {
      test('deleteProfile completes successfully', () async {
        // Arrange
        const userId = '123';
        
        dioAdapter.onDelete(
          'users/$userId/profile',
          (server) => server.reply(200, {}),
        );

        // Act
        await backendService.deleteProfile(userId);

        // Assert
        // If no exception is thrown, the test passes.
      });

      test('deleteProfile throws DioException on profile not found', () async {
        // Arrange
        const userId = 'invalidId';
        final errorResponse = {
          "error": "Profile not found"
        };

        dioAdapter.onDelete(
          'users/$userId/profile',
          (server) => server.reply(404, errorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.deleteProfile(userId),
          throwsA(isA<DioException>()),
        );
      });

      test('deleteProfile throws DioException on server error', () async {
        // Arrange
        const userId = '123';
        final errorResponse = {
          "error": "Internal server error"
        };

        dioAdapter.onDelete(
          'users/$userId/profile',
          (server) => server.reply(500, errorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.deleteProfile(userId),
          throwsA(isA<DioException>()),
        );
      });
    }); // Group deleteProfile Tests

    group('createGroup Tests', () {
      test('createGroup returns a Group object on success with all fields', () async {
        // Arrange
        const name = 'Test Group';
        const description = 'This is a test group';
        const isPrivate = true;
        const ownedId = 'owner123';
        const latitude = 12.345678;
        const longitude = 98.765432;
        const address = '123 Test Street';

        final mockResponse = {
          "id": 1,
          "group_name": name,
          "description": description,
          "is_private": isPrivate,
          "owner_id": ownedId,
          "points": 0,
          "image_id": null,
          "latitude": latitude,
          "longitude": longitude,
          "address": address
        };

        dioAdapter.onPost(
          '/groups',
          (server) => server.reply(200, mockResponse),
          data: {
            "group_name": name,
            "description": description,
            "is_private": isPrivate,
            "owner_id": ownedId,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
          },
        );

        // Act
        final group = await backendService.createGroup(
          name, description, isPrivate, ownedId, latitude, longitude, address
        );

        // Assert
        expect(group, isA<Group>());
        expect(group.id, equals(1));
        expect(group.name, equals(name));
        expect(group.description, equals(description));
        expect(group.isPrivate, equals(isPrivate));
        expect(group.ownerId, equals(ownedId));
        expect(group.latitude, equals(latitude));
        expect(group.longitude, equals(longitude));
        expect(group.address, equals(address));
        expect(group.points, equals(0));
        expect(group.imageId, isNull);
      });

      test('createGroup returns a Group object on success with optional fields missing', () async {
        // Arrange
        const name = 'Test Group';
        const description = 'This is a test group';
        const isPrivate = true;
        const ownedId = 'owner123';
        const latitude = null;
        const longitude = null;
        const address = null;

        final mockResponse = {
          "id": 1,
          "group_name": name,
          "description": description,
          "is_private": isPrivate,
          "owner_id": ownedId,
          "points": 0,
          "image_id": null,
          "latitude": latitude,
          "longitude": longitude,
          "address": address
        };

        dioAdapter.onPost(
          '/groups',
          (server) => server.reply(200, mockResponse),
          data: {
            "group_name": name,
            "description": description,
            "is_private": isPrivate,
            "owner_id": ownedId,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
          },
        );

        // Act
        final group = await backendService.createGroup(
          name, description, isPrivate, ownedId, latitude, longitude, address
        );

        // Assert
        expect(group, isA<Group>());
        expect(group.id, equals(1));
        expect(group.name, equals(name));
        expect(group.description, equals(description));
        expect(group.isPrivate, equals(isPrivate));
        expect(group.ownerId, equals(ownedId));
        expect(group.latitude, isNull);
        expect(group.longitude, isNull);
        expect(group.address, isNull);
        expect(group.points, equals(0));
        expect(group.imageId, isNull);
      });

      test('createGroup throws DioException on bad request', () async {
        // Arrange
        const name = 'Test Group';
        const description = 'This is a test group';
        const isPrivate = true;
        const ownedId = 'owner123';
        const latitude = null;
        const longitude = null;
        const address = '123 Test Street';
        final errorResponse = {
          "error": "Invalid data"
        };

        dioAdapter.onPost(
          '/groups',
          (server) => server.reply(400, errorResponse),
          data: {
            "group_name": name,
            "description": description,
            "is_private": isPrivate,
            "owner_id": ownedId,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
          },
        );

        // Act & Assert
        expect(
          () async => await backendService.createGroup(
            name, description, isPrivate, ownedId, latitude, longitude, address
          ),
          throwsA(isA<DioException>()),
        );
      });

      test('createGroup throws DioException on server error', () async {
        // Arrange
        const name = 'Test Group';
        const description = 'This is a test group';
        const isPrivate = true;
        const ownedId = 'owner123';
        const latitude = 12.345678;
        const longitude = 98.765432;
        const address = '123 Test Street';
        final errorResponse = {
          "error":"Internal server error"
        };

        dioAdapter.onPost(
          '/groups',
          (server) => server.reply(500, errorResponse),
          data: {
            "group_name": name,
            "description": description,
            "is_private": isPrivate,
            "owner_id": ownedId,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
          },
        );

        // Act & Assert
        expect(
          () async => await backendService.createGroup(
            name, description, isPrivate, ownedId, latitude, longitude, address
          ),
          throwsA(isA<DioException>()),
        );
      });
    }); // Group createGroup Tests
  }); // Group BackendService Tests
}
