import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/health_record.dart';

class HealthRecordProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<HealthRecord> _records = [];

  List<HealthRecord> get records => _records;

  // Load all records from SQLite
  Future<void> loadRecords() async {
    _records = await _databaseHelper.getRecords();
    notifyListeners();
  }

  // Add a new health record
  Future<void> addRecord(HealthRecord record) async {
    await _databaseHelper.insertRecord(record);
    await loadRecords();
  }

  // Update an existing record
  Future<void> updateRecord(HealthRecord record) async {
    await _databaseHelper.updateRecord(record);
    await loadRecords();
  }

  // Delete a health record
  Future<void> deleteRecord(int id) async {
    await _databaseHelper.deleteRecord(id);
    await loadRecords();
  }

  // Get total values for a selected date
  int getTotalSteps(String date) {
    return _records
        .where((record) => record.date == date)
        .fold(0, (total, record) => total + record.steps);
  }

  int getTotalCalories(String date) {
    return _records
        .where((record) => record.date == date)
        .fold(0, (total, record) => total + record.calories);
  }

  int getTotalWater(String date) {
    return _records
        .where((record) => record.date == date)
        .fold(0, (total, record) => total + record.water);
  }
}
