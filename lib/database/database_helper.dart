import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/health_record.dart';

class DatabaseHelper {
  static Database? _database;

  // Open or create the database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'healthmate.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE health_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            steps INTEGER NOT NULL,
            calories INTEGER NOT NULL,
            water INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Add a new health record
  Future<int> insertRecord(HealthRecord record) async {
    final db = await database;

    return await db.insert('health_records', record.toMap());
  }

  // Get all saved health records
  Future<List<HealthRecord>> getRecords() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'health_records',
      orderBy: 'date DESC',
    );

    return maps.map((map) => HealthRecord.fromMap(map)).toList();
  }

  // Update an existing health record
  Future<int> updateRecord(HealthRecord record) async {
    final db = await database;

    return await db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Delete a health record
  Future<int> deleteRecord(int id) async {
    final db = await database;

    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }
}
