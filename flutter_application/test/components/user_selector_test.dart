import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/backend_service_interface.dart';
import 'package:flutter_application/models/role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/components/user_selector.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<BackendServiceInterface>(as: #MockBackendService)])
import 'user_selector_test.mocks.dart';

void main() {
  final int SKIP = 0;
  final int LIMIT = 500;

  late List<User> testUsers;
  late MockBackendService backendService;

  setUp(() async {
    backendService = MockBackendService();
    testUsers = [
      User(id: '1', fullName: 'John Doe', userName: 'john_doe', dateCreated: DateTime.now(), role: Role.NORMAL, imageId: null),
      User(id: '2', fullName: 'Jane Smith', userName: 'jane_smith', dateCreated: DateTime.now(), role: Role.NORMAL, imageId: null),
    ];
    when(backendService.getUsers(SKIP, LIMIT)).thenAnswer((_) async => testUsers);
  });

  UserSelector createUserSelector({
    required Function(User) onUserSelected,
    required Function(List<User>) onCompleted,
  }) {
    return UserSelector(
      onUserSelected: onUserSelected,
      onCompleted: onCompleted,
      backendService: backendService,
    );
  }

  Future<void> pumpUserSelector(WidgetTester tester, UserSelector userSelector) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: userSelector,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('displays search bar', (WidgetTester tester) async {
    final userSelector = createUserSelector(
      onUserSelected: (User user) {},
      onCompleted: (List<User> users) {},
    );
    await pumpUserSelector(tester, userSelector);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('displays list of users when search query is empty', (WidgetTester tester) async {
    final userSelector = createUserSelector(
      onUserSelected: (User user) {},
      onCompleted: (List<User> users) {},
    );
    await pumpUserSelector(tester, userSelector);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);
  });

  testWidgets('filters users based on search query and places Jane above John', (WidgetTester tester) async {
    final userSelector = createUserSelector(
      onUserSelected: (User user) {},
      onCompleted: (List<User> users) {},
    );
    await pumpUserSelector(tester, userSelector);

    await tester.enterText(find.byType(TextField), 'Jane');
    await tester.pumpAndSettle();

    final janeFinder = find.text('Jane Smith');
    final johnFinder = find.text('John Doe');

    expect(janeFinder, findsOneWidget);
    expect(johnFinder, findsOneWidget);

    final janePosition = tester.getTopLeft(janeFinder);
    final johnPosition = tester.getTopLeft(johnFinder);

    expect(janePosition.dy, lessThan(johnPosition.dy));
  });

  testWidgets('selects and deselects a user', (WidgetTester tester) async {
    final userSelector = createUserSelector(
      onUserSelected: (User user) {},
      onCompleted: (List<User> users) {},
    );
    await pumpUserSelector(tester, userSelector);

    await tester.tap(find.text('John Doe'));
    await tester.pumpAndSettle();
    // one checkmark for the selected user and one for the finish button
    expect(find.byIcon(Icons.check), findsExactly(2));

    await tester.tap(find.text('John Doe'));
    await tester.pumpAndSettle();
    // finish button should also have disappeared
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('calls onUserSelected when a user is selected', (WidgetTester tester) async {
    bool userSelectedCalled = false;
    final userSelector = createUserSelector(
      onUserSelected: (User user) {
        userSelectedCalled = true;
      },
      onCompleted: (List<User> users) {},
    );

    await pumpUserSelector(tester, userSelector);

    await tester.tap(find.text('John Doe'));
    await tester.pumpAndSettle();

    expect(userSelectedCalled, isTrue);
  });

  testWidgets('calls onCompleted when finish button is pressed', (WidgetTester tester) async {
    bool onCompletedCalled = false;
    final userSelector = createUserSelector(
      onUserSelected: (User user) {},
      onCompleted: (List<User> users) {
        onCompletedCalled = true;
      },
    );

    await pumpUserSelector(tester, userSelector);

    await tester.tap(find.text('John Doe'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finish Selection'));
    await tester.pumpAndSettle();

    expect(onCompletedCalled, isTrue);
  });
}
