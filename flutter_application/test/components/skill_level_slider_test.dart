import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/components/skill_level_slider.dart';

void main() {
  Future<void> pumpSkillLevelSlider(
    WidgetTester tester, {
    int initialSkillLevel = 0,
    Function(int)? onSkillLevelChanged,
    bool isSliderLocked = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SkillLevelSlider(
            initialSkillLevel: initialSkillLevel,
            onSkillLevelChanged: onSkillLevelChanged,
            isSliderLocked: isSliderLocked,
          ),
        ),
      ),
    );
  }

  testWidgets('SkillLevelSlider initializes with the correct skill level', (WidgetTester tester) async {
    await pumpSkillLevelSlider(tester, initialSkillLevel: 2);

    final skillLevelTextFinder = find.text('Advanced');
    expect(skillLevelTextFinder, findsOneWidget);
  });

  testWidgets('SkillLevelSlider updates skill level on slide', (WidgetTester tester) async {
    int? updatedSkillLevel;
    await pumpSkillLevelSlider(
      tester,
      initialSkillLevel: 1,
      onSkillLevelChanged: (int level) {
        updatedSkillLevel = level;
      },
    );

    final sliderFinder = find.byType(Slider);
    await tester.drag(sliderFinder, const Offset(300.0, 0.0));
    await tester.pumpAndSettle();

    final skillLevelTextFinder = find.text('Master');
    expect(skillLevelTextFinder, findsOneWidget);
    expect(updatedSkillLevel, 4);
  });

  testWidgets('SkillLevelSlider is locked when isSliderLocked is true', (WidgetTester tester) async {
    await pumpSkillLevelSlider(
      tester,
      initialSkillLevel: 1,
      isSliderLocked: true,
    );

    final sliderFinder = find.byType(Slider);
    await tester.drag(sliderFinder, const Offset(300.0, 0.0));
    await tester.pumpAndSettle();

    final skillLevelTextFinder = find.text('Intermediate');
    expect(skillLevelTextFinder, findsOneWidget);
  });
}
