import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:healthmate/providers/health_record_provider.dart';
import 'package:healthmate/screens/add_record_screen.dart';

void main() {
  // Create Add Record screen with Provider
  Widget createTestApp() {
    return ChangeNotifierProvider(
      create: (context) => HealthRecordProvider(),
      child: const MaterialApp(home: AddRecordScreen()),
    );
  }

  // Scroll down until Save button is visible
  Future<void> findSaveButton(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Save Health Record'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();
  }

  group('Add Health Record Form Tests', () {
    // Test 1: Check form fields
    testWidgets('Add Record screen displays required fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      expect(find.text('Add Health Record'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));

      await findSaveButton(tester);

      expect(find.text('Save Health Record'), findsOneWidget);
    });

    // Test 2: Empty fields should show validation errors
    testWidgets('Empty form shows required field errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      await findSaveButton(tester);

      await tester.tap(find.text('Save Health Record'));
      await tester.pump();

      expect(find.text('Please enter steps'), findsOneWidget);
      expect(find.text('Please enter calories'), findsOneWidget);
      expect(find.text('Please enter water intake'), findsOneWidget);
    });

    // Test 3: Negative numbers should be rejected
    testWidgets('Negative values show validation errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), '-100');
      await tester.enterText(fields.at(1), '-50');
      await tester.enterText(fields.at(2), '-500');

      await findSaveButton(tester);

      await tester.tap(find.text('Save Health Record'));
      await tester.pump();

      expect(find.text('steps cannot be negative'), findsOneWidget);
      expect(find.text('calories cannot be negative'), findsOneWidget);
      expect(find.text('water intake cannot be negative'), findsOneWidget);
    });

    // Test 4: Letters should not be accepted
    testWidgets('Invalid text shows number validation errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'abc');
      await tester.enterText(fields.at(1), 'hello');
      await tester.enterText(fields.at(2), 'water');

      await findSaveButton(tester);

      await tester.tap(find.text('Save Health Record'));
      await tester.pump();

      expect(find.text('Please enter a valid whole number'), findsNWidgets(3));
    });

    // Test 5: Check Ocean Blue header
    testWidgets('Ocean Blue header displays correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      expect(find.text('Track Your Health'), findsOneWidget);
      expect(find.text('Record your daily activity'), findsOneWidget);
    });

    // Test 6: Check date selection
    testWidgets('Record date and Change button are displayed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());

      expect(find.text('Record Date'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
    });
  });
}
