import 'package:flutter/material.dart';
import 'package:flutter_application/challenges_page.dart';
import 'package:flutter_application/leaderboard_page.dart';
import 'package:flutter_application/midnattsloppet_activity_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application/controllers/backend_service_interface.dart';
import 'package:flutter_application/home_page.dart';
import 'package:flutter_application/models/group.dart';

@GenerateNiceMocks([MockSpec<BackendServiceInterface>(as: #MockBackendService)])
import 'home_page_test.mocks.dart';

void main() {
  late MockBackendService mockBackendService;

  setUp(() async {
    // init dotenv, for some reason a normal backend service is being created in the background and breaking tests
    await dotenv.load();
    mockBackendService = MockBackendService();
  });

  testWidgets('HomePage displays leaderboard groups',
      (WidgetTester tester) async {
    when(mockBackendService.getGroups(any, any, any, any))
        .thenAnswer((_) async => [
              Group(
                  id: 1,
                  name: "Group1",
                  description: "description",
                  isPrivate: false,
                  ownerId: "ownerId",
                  skillLevel: 0,
                  points: 100),
              Group(
                  id: 2,
                  name: "Group2",
                  description: "description",
                  isPrivate: false,
                  ownerId: "ownerId",
                  skillLevel: 0,
                  points: 200),
              Group(
                  id: 3,
                  name: "Group3",
                  description: "description",
                  isPrivate: false,
                  ownerId: "ownerId",
                  skillLevel: 0,
                  points: 150),
            ]);

    await tester.pumpWidget(MaterialApp(
      home: HomePage(backendService: mockBackendService),
    ));
    await tester.pump();

    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Group1'), findsOneWidget);
    expect(find.text('100 points'), findsOneWidget);
    expect(find.text('Group2'), findsOneWidget);
    expect(find.text('200 points'), findsOneWidget);
    expect(find.text('Group3'), findsOneWidget);
    expect(find.text('150 points'), findsOneWidget);
  });

  testWidgets('CountdownWidget displays correct days to race',
      (WidgetTester tester) async {
    // TODO This will fail after 2024-08-17
    DateTime testDate = DateTime.now();
    DateTime raceDate = DateTime(2024, 8, 17);
    final difference = raceDate.difference(testDate).inDays;

    await tester.pumpWidget(MaterialApp(
      home: CountdownWidget(),
    ));

    expect(find.text('$difference DAYS TO\nMIDNATTSLOPPET'), findsOneWidget);
  });

  testWidgets('ActivityButton navigates to MidnatsloppetActivity',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ActivityButton(),
      ),
    ));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(MidnatsloppetActivity), findsOneWidget);
  });

  testWidgets('ChallengesButton navigates to ChallengesPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChallengesButton(),
      ),
    ));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(ChallengesPage), findsOneWidget);
  });

  testWidgets('MoreButton navigates to LeaderboardPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MoreButton(),
      ),
    ));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(LeaderboardPage), findsOneWidget);
  });
}
