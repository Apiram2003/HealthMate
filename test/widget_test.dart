import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/main.dart';

void main() {
  testWidgets('HealthMate welcome screen test', (WidgetTester tester) async {
    // Set a mobile screen size
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    // Open HealthMate application
    await tester.pumpWidget(const HealthMateApp());

    // Check Welcome Screen contents
    expect(find.text('Welcome to HealthMate!'), findsOneWidget);
    expect(find.text('Your Personal Health Tracker'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Check heart icon
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
