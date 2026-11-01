import 'package:flutter/material.dart';

import '../models/health_record.dart';
import '../database/database_helper.dart';
import '../widgets/summary_card.dart';
import 'add_record_screen.dart';
import 'records_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  int _steps = 0;
  int _calories = 0;
  int _water = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayRecord();
  }

  // Get today's date in YYYY-MM-DD format
  String _getFormattedDate() {
    final now = DateTime.now();

    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // Load today's saved health records from SQLite
  Future<void> _loadTodayRecord() async {
    try {
      final List<HealthRecord> records = await _databaseHelper.getRecords();

      final today = _getFormattedDate();

      int totalSteps = 0;
      int totalCalories = 0;
      int totalWater = 0;

      for (final record in records) {
        if (record.date == today) {
          totalSteps += record.steps;
          totalCalories += record.calories;
          totalWater += record.water;
        }
      }

      if (!mounted) return;

      setState(() {
        _steps = totalSteps;
        _calories = totalCalories;
        _water = totalWater;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load today\'s records')),
      );
    }
  }

  // Open Add Record screen and refresh Dashboard
  Future<void> _openAddRecord() async {
    await Navigator.push<HealthRecord>(
      context,
      MaterialPageRoute(builder: (context) => const AddRecordScreen()),
    );

    if (mounted) {
      await _loadTodayRecord();
    }
  }

  // Open Records screen and refresh after returning
  Future<void> _openRecords() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecordsScreen()),
    );

    if (mounted) {
      await _loadTodayRecord();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayDate = _getFormattedDate();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.teal),
            SizedBox(width: 8),
            Text('HealthMate', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Today's date card
                    Card(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Today's Activity Summary",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(todayDate),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Steps
                    SummaryCard(
                      title: 'Total Steps Walked',
                      value: _steps.toString(),
                      unit: 'steps',
                      icon: Icons.directions_walk,
                      color: Colors.green,
                    ),

                    // Calories
                    SummaryCard(
                      title: 'Total Calories Burned',
                      value: _calories.toString(),
                      unit: 'kcal',
                      icon: Icons.local_fire_department,
                      color: Colors.deepOrange,
                    ),

                    // Water
                    SummaryCard(
                      title: 'Total Water Intake',
                      value: _water.toString(),
                      unit: 'mL',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 20),

                    // Add Record button
                    FilledButton.icon(
                      onPressed: _openAddRecord,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Health Record'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // View Records button
                    OutlinedButton.icon(
                      onPressed: _openRecords,
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View All Health Records'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Simple information message
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.teal),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Today\'s health summary is loaded from saved records.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.teal,
        onTap: (index) {
          if (index == 1) {
            _openAddRecord();
          } else if (index == 2) {
            _openRecords();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Record',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Records'),
        ],
      ),
    );
  }
}
