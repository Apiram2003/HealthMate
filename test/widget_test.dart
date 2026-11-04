import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthmate/main.dart';

void main() {
  testWidgets('HealthMate welcome screen test', (tester) async {
    // Test the Welcome Screen directly.
    // Automatic login is checked separately when the app starts.
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    // Check welcome title
    expect(find.text('Welcome to HealthMate!'), findsOneWidget);

    // Check subtitle
    expect(find.text('Your Personal Health Tracker'), findsOneWidget);

    // Check Get Started button
    expect(find.text('Get Started'), findsOneWidget);

    // Check app icon
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
