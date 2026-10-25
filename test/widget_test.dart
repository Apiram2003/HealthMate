import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/main.dart';

void main() {
  testWidgets('HealthMate Dashboard smoke test', (WidgetTester tester) async {
    // Set a phone-like viewport size
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Build the HealthMate app and trigger a frame.
    await tester.pumpWidget(const HealthMateApp());

    // Verify that the title and dashboard metrics are displayed.
    expect(find.text('HealthMate'), findsOneWidget);
    expect(find.text("Today's Activity Summary"), findsOneWidget);
    expect(find.text('Total Steps Walked'), findsOneWidget);
    expect(find.text('Total Calories Burned'), findsOneWidget);
    expect(find.text('Total Water Intake'), findsOneWidget);
    expect(find.text('Add Health Record'), findsOneWidget);
    expect(find.text('View All Health Records'), findsOneWidget);
  });
}
