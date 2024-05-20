import 'package:dio/dio.dart';
import 'package:flutter_application/controllers/backend_service.dart';
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
      final user =
          await backendService.createUser(userName, email, fullName, password);

      // Assert
      expect(user, isA<User>());
      expect(user.userName, equals(userName));
      expect(user.email, equals(email));
      expect(user.userName, equals(userName));
    });

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

    test('getMe returns a User object on sucess', () async {
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
}
