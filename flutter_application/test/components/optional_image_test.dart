import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application/controllers/backend_service_interface.dart';
import 'package:flutter_application/components/optional_image.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<BackendServiceInterface>(as: #MockBackendService)])
import 'optional_image_test.mocks.dart';

void main() {
  Future<void> pumpOptionalImage(WidgetTester tester, String? imageId, {ImageProvider? imageProvider}) async {
    final mockBackendService = MockBackendService();
    when(mockBackendService.getImage(any))
        .thenAnswer((_) async => imageProvider ?? AssetImage('lib/images/splash.png'));
    await tester.pumpWidget(MaterialApp(
      home: OptionalImage(imageId: imageId, backendService: mockBackendService),
    ));
  }

  testWidgets('shows CircularProgressIndicator while loading', (WidgetTester tester) async {
    await pumpOptionalImage(tester, 'test');

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows default image when imageId is null', (WidgetTester tester) async {
    await pumpOptionalImage(tester, null);

    expect(find.byType(CircleAvatar), findsOneWidget);
    final CircleAvatar circleAvatar = tester.widget(find.byType(CircleAvatar));
    expect((circleAvatar.foregroundImage as AssetImage).assetName, 'lib/images/splash.png');
  });

  testWidgets('shows fetched image when imageId is not null', (WidgetTester tester) async {
    final imageProvider = AssetImage('lib/images/splash.png');
    await pumpOptionalImage(tester, 'test', imageProvider: imageProvider);

    // Let the Future complete
    await tester.pump();

    expect(find.byType(CircleAvatar), findsOneWidget);
    final CircleAvatar circleAvatar = tester.widget(find.byType(CircleAvatar));
    expect(circleAvatar.foregroundImage, imageProvider);
  });
}
