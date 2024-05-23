import 'package:dio/dio.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/profile.dart';
import 'package:flutter_application/models/role.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

// MISC CONSTANTS
const skip = 0;
const limit = 25;
final serverErrorResponse = {"error": "Internal server error"};

// USER CONSTANTS
const userId = '123';
const userName = 'testUser';
const userEmail = 'test@example.com';
const userFullName = 'Test User';
const userPassword = 'password123';
const userRole = 2;
const userDateCreated = "2024-05-20T13:51:49.615Z";
final userNotFoundErrorResponse = {"error": "User not found"};

Map<String, dynamic> mockUserResponse({
  String email = userEmail,
  String name = userName,
  String fullName = userFullName,
  String id = userId,
  int role = userRole,
  String dateCreated = userDateCreated,
}) {
  return {
    "email": email,
    "username": name,
    "full_name": fullName,
    "id": id,
    "role": role,
    "date_created": dateCreated,
  };
}

// PROFILE CONSTANTS
const profileDescription = 'This is a test profile';
const profileAge = 25;
const profileInterests = 'Test profile interests';
const profileSkillLevel = 3;
const profileIsPrivate = true;
const profileRunnerId = userId;
const profileLocation = 'Test Location';
const profileNotFoundErrorResponse = {"error": "Profile not found"};

Map<String, dynamic> mockProfileResponse({
  String description = profileDescription,
  int age = profileAge,
  String interests = profileInterests,
  int skillLevel = profileSkillLevel,
  bool isPrivate = profileIsPrivate,
  String location = profileLocation,
  String? runnerId = profileRunnerId,
  String? imageId,
}) {
  return {
    "description": description,
    "age": age,
    "interests": interests,
    "skill_level": skillLevel,
    "is_private": isPrivate,
    "runner_id": runnerId,
    "location": location,
    "image_id": imageId,
  };
}

// GROUP CONSTANTS
const groupId = 123;
const groupName = 'Test Group';
const groupDescription = 'This is a test group';
const groupIsPrivate = true;
const groupOwnerId = userId;
const groupPoints = 123;
const groupLatitude = 12.345678;
const groupLongitude = 98.765432;
const groupAddress = '123 Test Street';
const groupSkillLevel = 3;

Map<String, dynamic> mockGroupResponse({
  String name = groupName,
  String description = groupDescription,
  bool isPrivate = groupIsPrivate,
  String ownerId = groupOwnerId,
  double? latitude = groupLatitude,
  double? longitude = groupLongitude,
  String? address = groupAddress,
  int id = groupId,
  int points = groupPoints,
  String? imageId,
  int skillLevel = groupSkillLevel,
}) {
  return {
    "group_name": name,
    "description": description,
    "is_private": isPrivate,
    "owner_id": ownerId,
    "latitude": latitude,
    "longitude": longitude,
    "address": address,
    "id": id,
    "points": points,
    "image_id": imageId,
    "skill_level": skillLevel,
  };
}

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
        dioAdapter.onPost(
          '/users',
          (server) => server.reply(200, mockUserResponse()),
          data: {
            "email": userEmail,
            "username": userName,
            "full_name": userFullName,
            "password": userPassword,
          },
        );

        dioAdapter
            .onPost('/users/login', (server) => server.reply(200, {}), data: {
          "email": userEmail,
          "password": userPassword,
        });

        // Act
        final user = await backendService.createUser(
            userName, userEmail, userFullName, userPassword);

        // Assert
        expect(user, isA<User>());
        expect(user.userName, equals(userName));
        expect(user.email, equals(userEmail));
      });
    });
    group('getUsers Tests', () {
      test('getUsers returns a list of User objects on success', () async {
        // Arrange
        final mockResponse = {
          "data": [
            mockUserResponse(),
            mockUserResponse(),
            mockUserResponse(),
          ]
        };

        dioAdapter.onGet(
          '/users',
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
        expect(users[0].fullName, equals(userFullName));
      });

      test('getUsers throws DioException on bad request', () async {
        // Arrange
        const path = '/users';

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
        dioAdapter.onGet(
          '/users/me',
          (server) => server.reply(
            200,
            mockUserResponse(),
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
        dioAdapter.onGet(
          '/users/$userId',
          (server) => server.reply(200, mockUserResponse()),
        );

        // Act
        final user = await backendService.getUser(userId);

        // Assert
        expect(user, isA<User>());
        expect(user.id, equals(userId));
        expect(user.email, equals(userEmail));
        expect(user.userName, equals(userName));
        expect(user.fullName, equals(userFullName));
        expect(user.role, equals(Role.parse(userRole)));
        expect(user.dateCreated, equals(DateTime.parse(userDateCreated)));
      });

      test('getUser throws a DioException on bad request', () async {
        // Arrange
        const userId = 'invalidId';

        dioAdapter.onGet(
          '/users/$userId',
          (server) => server.reply(400, userNotFoundErrorResponse),
        );

        // Act & Assert
        try {
          await backendService.getUser(userId);
          fail("Expected a DioException to be thrown");
        } catch (e) {
          expect(e, isA<DioException>());
          if (e is DioException) {
            expect(e.response?.statusCode, 400);
            expect(e.response?.data, userNotFoundErrorResponse);
          }
        }
      });
    });

    group('updateUser Tests', () {
      test('updateUser returns a User object on success with userName',
          () async {
        // Arrange
        const newUserName = 'newUsername';
        dioAdapter.onPatch(
          '/users/$userId',
          (server) => server.reply(200, mockUserResponse(name: newUserName)),
          data: {
            "username": newUserName,
          },
        );

        // Act
        final user =
            await backendService.updateUser(userId, userName: newUserName);

        // Assert
        expect(user, isA<User>());
        expect(user.id, equals(userId));
        expect(user.email, equals(userEmail));
        expect(user.userName, equals(newUserName));
        expect(user.fullName, equals(userFullName));
      });

      test('updateUser returns a User object on success with fullName',
          () async {
        // Arrange
        const newFullName = 'New Full Name';
        dioAdapter.onPatch(
          '/users/$userId',
          (server) =>
              server.reply(200, mockUserResponse(fullName: newFullName)),
          data: {
            "full_name": newFullName,
          },
        );

        // Act
        final user =
            await backendService.updateUser(userId, fullName: newFullName);

        // Assert
        expect(user, isA<User>());
        expect(user.id, equals(userId));
        expect(user.email, equals(userEmail));
        expect(user.userName, equals(userName));
        expect(user.fullName, equals(newFullName));
      });

      test(
          'updateUser returns a User object on success with userName and fullName',
          () async {
        // Arrange
        const newUserName = 'newUsername';
        const newFullName = 'New Full Name';
        dioAdapter.onPatch(
          '/users/$userId',
          (server) => server.reply(
              200, mockUserResponse(name: newUserName, fullName: newFullName)),
          data: {
            "username": newUserName,
            "full_name": newFullName,
          },
        );

        // Act
        final user = await backendService.updateUser(userId,
            userName: newUserName, fullName: newFullName);

        // Assert
        expect(user, isA<User>());
        expect(user.id, equals(userId));
        expect(user.email, equals(userEmail));
        expect(user.userName, equals(newUserName));
        expect(user.fullName, equals(newFullName));
      });

      test(
          'updateUser throws a FormatException when no update fields are provided',
          () async {
        // Arrange, Act & Assert
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
        const newUserName = 'newUsername';
        const newFullName = 'New Full Name';

        dioAdapter.onPatch(
          '/users/$userId',
          (server) => server.reply(400, userNotFoundErrorResponse),
          data: {
            "username": newUserName,
            "full_name": newFullName,
          },
        );

        // Act & Assert
        try {
          await backendService.updateUser(userId,
              userName: newUserName, fullName: newFullName);
          fail("Expected a DioException to be thrown");
        } catch (e) {
          expect(e, isA<DioException>());
          if (e is DioException) {
            expect(e.response?.statusCode, 400);
            expect(e.response?.data, userNotFoundErrorResponse);
          }
        }
      });
    });

    group('deleteUser Tests', () {
      test('deleteUser completes successfully', () async {
        // Arrange
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

        dioAdapter.onDelete(
          '/users/$userId',
          (server) => server.reply(404, userNotFoundErrorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.deleteUser(userId),
          throwsA(isA<DioException>()),
        );
      });

      test('deleteUser throws DioException on server error', () async {
        // Arrange
        dioAdapter.onDelete(
          '/users/$userId',
          (server) => server.reply(500, serverErrorResponse),
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

        dioAdapter.onPut(
          '/users/$userId/profile',
          (server) => server.reply(500, serverErrorResponse),
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
        dioAdapter.onGet(
          '/users/$userId/profile',
          (server) => server.reply(200, mockProfileResponse()),
        );

        // Act
        final profile = await backendService.getProfile(userId);

        // Assert
        expect(profile, isA<Profile>());
        expect(profile.description, equals(profileDescription));
        expect(profile.age, equals(profileAge));
        expect(profile.interests, equals(profileInterests));
        expect(profile.skillLevel, equals(profileSkillLevel));
        expect(profile.isPrivate, equals(profileIsPrivate));
        expect(profile.location, equals(profileLocation));
        expect(profile.runnerId, equals(profileRunnerId));
        expect(profile.imageId, isNull);
      });

      test('getProfile throws DioException on profile not found', () async {
        // Arrange
        const userId = 'invalidId';

        dioAdapter.onGet(
          '/users/$userId/profile',
          (server) => server.reply(404, profileNotFoundErrorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.getProfile(userId),
          throwsA(isA<DioException>()),
        );
      });

      test('getProfile throws DioException on server error', () async {
        // Arrange
        dioAdapter.onGet(
          '/users/$userId/profile',
          (server) => server.reply(500, serverErrorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.getProfile(userId),
          throwsA(isA<DioException>()),
        );
      });
    }); // getProfile Tests

    group('updateProfile Tests', () {
      test('updateProfile returns a Profile object on success with all fields',
          () async {
        // Arrange
        const newDescription = 'Updated profile description';
        const newAge = 30;
        const newInterests = 'Swimming, Cycling';
        const newSkillLevel = 4;
        const newIsPrivate = true;
        const newLocation = 'Updated City';
        const newRunnerId = 'updatedRunner123';

        final mockReponse = mockProfileResponse(
            description: newDescription,
            age: newAge,
            interests: newInterests,
            skillLevel: newSkillLevel,
            isPrivate: newIsPrivate,
            location: newLocation,
            runnerId: newRunnerId);

        dioAdapter.onPatch(
          '/users/$userId/profile',
          (server) => server.reply(200, mockReponse),
          data: {
            "description": newDescription,
            "age": newAge,
            "interests": newInterests,
            "skill_level": newSkillLevel,
            "is_private": newIsPrivate,
            "location": newLocation,
            "runner_id": newRunnerId,
          },
        );

        // Act
        final profile = await backendService.updateProfile(
          userId,
          description: newDescription,
          age: newAge,
          interests: newInterests,
          skillLevel: newSkillLevel,
          isPrivate: newIsPrivate,
          location: newLocation,
          runnerId: newRunnerId,
        );

        // Assert
        expect(profile, isA<Profile>());
        expect(profile.description, equals(newDescription));
        expect(profile.age, equals(newAge));
        expect(profile.interests, equals(newInterests));
        expect(profile.skillLevel, equals(newSkillLevel));
        expect(profile.isPrivate, equals(newIsPrivate));
        expect(profile.location, equals(newLocation));
        expect(profile.runnerId, equals(newRunnerId));
        expect(profile.imageId, isNull);
      });

      test('updateProfile returns a Profile object on success with some fields',
          () async {
        // Arrange
        const newDescription = 'Updated profile description';
        const newAge = 30;

        dioAdapter.onPatch(
          '/users/$userId/profile',
          (server) => server.reply(200,
              mockProfileResponse(description: newDescription, age: newAge)),
          data: {
            "description": newDescription,
            "age": newAge,
          },
        );

        // Act
        final profile = await backendService.updateProfile(
          userId,
          description: newDescription,
          age: newAge,
        );

        // Assert
        expect(profile, isA<Profile>());
        expect(profile.description, equals(newDescription));
        expect(profile.age, equals(newAge));
        expect(profile.interests, equals(profileInterests));
        expect(profile.skillLevel, equals(profileSkillLevel));
        expect(profile.isPrivate, equals(profileIsPrivate));
        expect(profile.location, equals(profileLocation));
        expect(profile.runnerId, equals(profileRunnerId));
        expect(profile.imageId, isNull);
      });

      test('updateProfile throws FormatException when no fields are provided',
          () async {
        // Arrange, Act & Assert
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
        const age = -5; // Invalid age
        final errorResponse = {"error": "Invalid age value"};

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
        const newDescription = 'Updated profile description';

        dioAdapter.onPatch(
          '/users/$userId/profile',
          (server) => server.reply(500, serverErrorResponse),
          data: {
            "description": newDescription,
          },
        );

        // Act & Assert
        expect(
          () async => await backendService.updateProfile(userId,
              description: newDescription),
          throwsA(isA<DioException>()),
        );
      });
    }); // updateProfile Tests

    group('deleteProfile Tests', () {
      test('deleteProfile completes successfully', () async {
        // Arrange
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

        dioAdapter.onDelete(
          'users/$userId/profile',
          (server) => server.reply(404, profileNotFoundErrorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.deleteProfile(userId),
          throwsA(isA<DioException>()),
        );
      });

      test('deleteProfile throws DioException on server error', () async {
        // Arrange
        dioAdapter.onDelete(
          'users/$userId/profile',
          (server) => server.reply(500, serverErrorResponse),
        );

        // Act & Assert
        expect(
          () async => await backendService.deleteProfile(userId),
          throwsA(isA<DioException>()),
        );
      });
    }); // Group deleteProfile Tests

    group('createGroup Tests', () {
      test('createGroup returns a Group object on success with all fields',
          () async {
        // Arrange
        dioAdapter.onPost(
          '/groups',
          (server) => server.reply(
              200,
              mockGroupResponse()),
          data: {
            "group_name": groupName,
            "description": groupDescription,
            "is_private": groupIsPrivate,
            "owner_id": groupOwnerId,
            "latitude": groupLatitude,
            "longitude": groupLongitude,
            "address": groupAddress,
            "skill_level": groupSkillLevel,
          },
        );

        // Act
        final group = await backendService.createGroup(
            groupName,
            groupDescription,
            groupIsPrivate,
            groupOwnerId,
            groupSkillLevel,
            groupLatitude,
            groupLongitude,
            groupAddress);

        // Assert
        expect(group, isA<Group>());
        expect(group.id, equals(groupId));
        expect(group.name, equals(groupName));
        expect(group.description, equals(groupDescription));
        expect(group.isPrivate, equals(groupIsPrivate));
        expect(group.ownerId, equals(groupOwnerId));
        expect(group.latitude, equals(groupLatitude));
        expect(group.longitude, equals(groupLongitude));
        expect(group.address, equals(groupAddress));
        expect(group.points, equals(groupPoints));
        expect(group.imageId, isNull);
        expect(group.skillLevel, groupSkillLevel);
      });

      test(
          'createGroup returns a Group object on success with optional fields missing',
          () async {
        // Arrange
        const latitude = null;
        const longitude = null;
        const address = null;

        dioAdapter.onPost(
          '/groups',
          (server) => server.reply(
              200,
              mockGroupResponse(
                  latitude: latitude, longitude: longitude, address: address)),
          data: {
            "group_name": groupName,
            "description": groupDescription,
            "is_private": groupIsPrivate,
            "owner_id": groupOwnerId,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
            "skill_level": groupSkillLevel,
          },
        );

        // Act
        final group = await backendService.createGroup(
            groupName,
            groupDescription,
            groupIsPrivate,
            groupOwnerId,
            groupSkillLevel,
            latitude,
            longitude,
            address,);

        // Assert
        expect(group, isA<Group>());
        expect(group.id, equals(groupId));
        expect(group.name, equals(groupName));
        expect(group.description, equals(groupDescription));
        expect(group.isPrivate, equals(groupIsPrivate));
        expect(group.ownerId, equals(groupOwnerId));
        expect(group.latitude, isNull);
        expect(group.longitude, isNull);
        expect(group.address, isNull);
        expect(group.points, equals(groupPoints));
        expect(group.imageId, isNull);
      });

      test('createGroup throws DioException on bad request', () async {
        // Arrange
        final errorResponse = {"error": "Invalid data"};

        dioAdapter.onPost(
          '/groups',
          (server) => server.reply(400, errorResponse),
          data: {
            "group_name": groupName,
            "description": groupDescription,
            "is_private": groupIsPrivate,
            "owner_id": groupOwnerId,
            "skill_level": groupSkillLevel,
            "latitude": groupLatitude,
            "longitude": groupLongitude,
            "address": groupAddress,
          },
        );

        // Act & Assert
        expect(
          () async => await backendService.createGroup(
              groupName,
              groupDescription,
              groupIsPrivate,
              groupOwnerId,
              groupSkillLevel,
              groupLatitude,
              groupLongitude,
              groupAddress),
          throwsA(isA<DioException>()),
        );
      });

      test('createGroup throws DioException on server error', () async {
        // Arrange
        dioAdapter.onPost(
          '/groups',
          (server) => server.reply(500, serverErrorResponse),
          data: {
            "group_name": groupName,
            "description": groupDescription,
            "is_private": groupIsPrivate,
            "owner_id": groupOwnerId,
            "skill_level": groupSkillLevel,
            "latitude": groupLatitude,
            "longitude": groupLongitude,
            "address": groupAddress,
          },
        );

        // Act & Assert
        expect(
          () async => await backendService.createGroup(
              groupName,
              groupDescription,
              groupIsPrivate,
              groupOwnerId,
              groupSkillLevel,
              groupLatitude,
              groupLongitude,
              groupAddress),
          throwsA(isA<DioException>()),
        );
      });
    }); // Group createGroup Tests
  }); // Group BackendService Tests
}
