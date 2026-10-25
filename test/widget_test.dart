import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthmate/main.dart';

void main() {
  testWidgets('HealthMate welcome screen smoke test', (WidgetTester tester) async {
    // Build the HealthMate app and trigger a frame.
    await tester.pumpWidget(const HealthMateApp());

    // Verify that the title, heart icon, and welcome text are displayed.
    expect(find.text('HealthMate'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('Welcome to HealthMate!'), findsOneWidget);
    expect(find.text('Your Personal Health Tracker'), findsOneWidget);
  });
}
