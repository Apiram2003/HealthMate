import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/health_record.dart';

void main() {
  group('HealthRecord Model Tests', () {
    // Test 1: Create a health record
    test('HealthRecord stores correct values', () {
      const record = HealthRecord(
        id: 1,
        date: '2026-11-01',
        steps: 5000,
        calories: 250,
        water: 1500,
      );

      expect(record.id, 1);
      expect(record.date, '2026-11-01');
      expect(record.steps, 5000);
      expect(record.calories, 250);
      expect(record.water, 1500);
    });

    // Test 2: Convert record to SQLite Map
    test('toMap converts HealthRecord into Map', () {
      const record = HealthRecord(
        id: 1,
        date: '2026-11-01',
        steps: 5000,
        calories: 250,
        water: 1500,
      );

      final map = record.toMap();

      expect(map['id'], 1);
      expect(map['date'], '2026-11-01');
      expect(map['steps'], 5000);
      expect(map['calories'], 250);
      expect(map['water'], 1500);
    });

    // Test 3: Convert SQLite Map to record
    test('fromMap converts Map into HealthRecord', () {
      final map = <String, dynamic>{
        'id': 2,
        'date': '2026-11-01',
        'steps': 7000,
        'calories': 350,
        'water': 2000,
      };

      final record = HealthRecord.fromMap(map);

      expect(record.id, 2);
      expect(record.date, '2026-11-01');
      expect(record.steps, 7000);
      expect(record.calories, 350);
      expect(record.water, 2000);
    });

    // Test 4: Update record using copyWith
    test('copyWith changes only selected values', () {
      const original = HealthRecord(
        id: 3,
        date: '2026-11-01',
        steps: 5000,
        calories: 250,
        water: 1500,
      );

      final updated = original.copyWith(steps: 8000, water: 2200);

      expect(updated.id, 3);
      expect(updated.date, '2026-11-01');
      expect(updated.steps, 8000);
      expect(updated.calories, 250);
      expect(updated.water, 2200);
    });

    // Test 5: New record can have a null ID
    test('New HealthRecord can be created without ID', () {
      const record = HealthRecord(
        date: '2026-11-01',
        steps: 3000,
        calories: 150,
        water: 1000,
      );

      expect(record.id, isNull);
      expect(record.steps, 3000);
    });
  });
}
