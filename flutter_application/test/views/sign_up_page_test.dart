import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/role.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/views/sign_up_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/components/gradient_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/controllers/backend_service_interface.dart';
import 'package:flutter_application/create_profile_page.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';


@GenerateNiceMocks([MockSpec<BackendServiceInterface>(as: #MockBackendService)])
import 'sign_up_page_test.mocks.dart';

void main() {
  late MockBackendService mockBackendService;

  setUp(() async {
    // init dotenv, for some reason a normal backend service is being created in the background and breaking tests
    await dotenv.load();
    mockBackendService = MockBackendService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: SignUpPage(backendService: mockBackendService),
    );
  }

  testWidgets('SignUpPage has all required fields and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(MyTextField), findsNWidgets(4));
    expect(find.byType(GradientButton), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
  });

  testWidgets('Empty form shows error snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byType(GradientButton));
    await tester.pump();

    expect(find.text('Please fill all the fields'), findsOneWidget);
  });

  testWidgets('Invalid email shows error snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(MyTextField).at(0), 'Name');
    await tester.enterText(find.byType(MyTextField).at(1), 'username');
    await tester.enterText(find.byType(MyTextField).at(2), 'invalid_email');
    await tester.enterText(find.byType(MyTextField).at(3), 'password');
    await tester.tap(find.byType(GradientButton));
    await tester.pump();

    expect(find.text('Invalid email'), findsOneWidget);
  });

  testWidgets('Valid form calls registerUser and navigates on success', (WidgetTester tester) async {
    when(mockBackendService.createUser(any, any, any, any))
        .thenAnswer((_) async => User(id: "id", userName: "userName", fullName: "fullName", dateCreated: DateTime.now(), role: Role.NORMAL, imageId: null));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(MyTextField).at(0), 'Name');
    await tester.enterText(find.byType(MyTextField).at(1), 'username');
    await tester.enterText(find.byType(MyTextField).at(2), 'email@example.com');
    await tester.enterText(find.byType(MyTextField).at(3), 'password');
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    verify(mockBackendService.createUser('username', 'email@example.com', 'Name', 'password')).called(1);
    await tester.pumpAndSettle();
    expect(find.byType(CreateProfilePage), findsOneWidget);
  });

  testWidgets('Unavailable email shows error snackbar', (WidgetTester tester) async {
    when(mockBackendService.createUser(any, any, any, any))
        .thenThrow(DioException(
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: ''),
            data: {'detail': 'Email unavailable'},
          ),
          requestOptions: RequestOptions(path: ''),
        ));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(MyTextField).at(0), 'Name');
    await tester.enterText(find.byType(MyTextField).at(1), 'username');
    await tester.enterText(find.byType(MyTextField).at(2), 'email@example.com');
    await tester.enterText(find.byType(MyTextField).at(3), 'password');
    await tester.tap(find.byType(GradientButton));
    await tester.pump();

    expect(find.text('Email unavailable'), findsOneWidget); 
  });
}
