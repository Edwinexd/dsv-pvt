import 'package:flutter/material.dart';
import 'package:flutter_application/components/custom_text_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CustomTextField displays labelText', (WidgetTester tester) async {
    const testLabel = 'Test Label';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(labelText: testLabel),
        ),
      ),
    );

    expect(find.text(testLabel), findsOneWidget);
  });

  testWidgets('CustomTextField calls onChanged callback', (WidgetTester tester) async {
    String? changedValue;
    void onChangedCallback(String value) {
      changedValue = value;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(onChanged: onChangedCallback),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'New Value');
    await tester.pump();

    expect(changedValue, 'New Value');
  });

  testWidgets('CustomTextField has filled decoration by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(),
        ),
      ),
    );

    final inputDecoration = tester.widget<InputDecorator>(find.byType(InputDecorator)).decoration;
    expect(inputDecoration.filled, true);
    expect(inputDecoration.fillColor, Colors.white);
  });
}
