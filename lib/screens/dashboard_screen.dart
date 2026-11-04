import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_record.dart';
import '../providers/health_record_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/goal_progress_card.dart';

import 'add_record_screen.dart';
import 'records_screen.dart';
import 'goal_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  // Default daily goals
  int dailyStepsGoal = 8000;
  int dailyWaterGoal = 2000;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
      _loadGoals();
    });
  }

  // Get today's date
  String _getFormattedDate() {
    final now = DateTime.now();

    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // Load health records using Provider
  Future<void> _loadRecords() async {
    if (!mounted) return;

    try {
      await context.read<HealthRecordProvider>().loadRecords();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load health records')),
      );
    }
  }

  // Load saved goals from SharedPreferences
  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        dailyStepsGoal = prefs.getInt('stepsGoal') ?? 8000;
        dailyWaterGoal = prefs.getInt('waterGoal') ?? 2000;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load goal settings')),
      );
    }
  }

  // Open Goal Settings screen
  Future<void> _openGoalSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoalSettingsScreen()),
    );

    if (mounted) {
      await _loadGoals();
    }
  }

  // Open Add Record screen
  Future<void> _openAddRecord() async {
    await Navigator.push<HealthRecord>(
      context,
      MaterialPageRoute(builder: (context) => const AddRecordScreen()),
    );

    if (mounted) {
      await _loadRecords();
    }
  }

  // Open Records History screen
  Future<void> _openRecords() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecordsScreen()),
    );

    if (mounted) {
      await _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayDate = _getFormattedDate();

    // Get today's health totals from Provider
    final healthProvider = context.watch<HealthRecordProvider>();

    final steps = healthProvider.getTotalSteps(todayDate);
    final calories = healthProvider.getTotalCalories(todayDate);
    final water = healthProvider.getTotalWater(todayDate);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // App Bar
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'HealthMate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,

        // Goal Settings button
        actions: [
          IconButton(
            onPressed: _openGoalSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Goal Settings',
          ),
        ],
      ),

      // Dashboard Body
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Today's Date Card
                    Card(
                      color: colorScheme.primaryContainer,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Today's Activity Summary",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    todayDate,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Health Overview Heading
                    const Text(
                      'Health Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Steps Summary
                    SummaryCard(
                      title: 'Total Steps Walked',
                      value: steps.toString(),
                      unit: 'steps',
                      icon: Icons.directions_walk,
                      color: Colors.blue,
                    ),

                    // Calories Summary
                    SummaryCard(
                      title: 'Total Calories Burned',
                      value: calories.toString(),
                      unit: 'kcal',
                      icon: Icons.local_fire_department,
                      color: Colors.deepOrange,
                    ),

                    // Water Summary
                    SummaryCard(
                      title: 'Total Water Intake',
                      value: water.toString(),
                      unit: 'mL',
                      icon: Icons.water_drop,
                      color: Colors.lightBlue,
                    ),

                    const SizedBox(height: 24),

                    // Daily Goals Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Daily Health Goals',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _openGoalSettings,
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Daily Goals',
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Steps Goal Progress
                    GoalProgressCard(
                      title: 'Daily Steps Goal',
                      currentValue: steps,
                      goalValue: dailyStepsGoal,
                      unit: 'steps',
                      icon: Icons.directions_walk,
                    ),

                    const SizedBox(height: 12),

                    // Water Goal Progress
                    GoalProgressCard(
                      title: 'Daily Water Goal',
                      currentValue: water,
                      goalValue: dailyWaterGoal,
                      unit: 'mL',
                      icon: Icons.water_drop,
                    ),

                    const SizedBox(height: 24),

                    // Add Health Record Button
                    FilledButton.icon(
                      onPressed: _openAddRecord,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Health Record'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // View Records Button
                    OutlinedButton.icon(
                      onPressed: _openRecords,
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View All Health Records'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Information Card
                    Card(
                      color: colorScheme.primaryContainer,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Your daily health summary and goals '
                                'are calculated using saved health records.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
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
