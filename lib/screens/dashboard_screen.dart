import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/health_record_provider.dart';
import '../services/auth_service.dart';
import 'add_record_screen.dart';
import 'goal_settings_screen.dart';
import 'login_screen.dart';
import 'records_screen.dart';
import 'weekly_progress_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _stepsGoal = 8000;
  int _waterGoal = 2000;

  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved daily goals
      final stepsGoal = prefs.getInt('steps_goal') ?? 8000;
      final waterGoal = prefs.getInt('water_goal') ?? 2000;

      if (!mounted) return;

      setState(() {
        _stepsGoal = stepsGoal;
        _waterGoal = waterGoal;
      });

      // Load saved health records from Provider
      await context.read<HealthRecordProvider>().loadRecords();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load dashboard data')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openAddRecord() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRecordScreen()),
    );

    if (!mounted) return;
    await _loadDashboard();
  }

  Future<void> _openRecords() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecordsScreen()),
    );

    if (!mounted) return;
    await _loadDashboard();
  }

  Future<void> _openWeeklyProgress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeeklyProgressScreen()),
    );

    if (!mounted) return;
    await _loadDashboard();
  }

  Future<void> _openGoalSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoalSettingsScreen()),
    );

    if (!mounted) return;
    await _loadDashboard();
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from HealthMate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    try {
      await AuthService().logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalCard({
    required String title,
    required int current,
    required int goal,
    required String unit,
    required IconData icon,
  }) {
    final progress = goal > 0 ? current / goal : 0.0;
    final percentage = progress * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2196F3)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '$current / $goal $unit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: const Color(0xFFE3F2FD),
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 10),
            Text(
              '${percentage.toStringAsFixed(1)}% of daily goal completed',
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer<HealthRecordProvider>(
      builder: (context, provider, child) {
        final today = _formatDate(DateTime.now());

        // Calculate totals for today's records
        final todayRecords = provider.records
            .where((record) => record.date == today)
            .toList();

        int totalSteps = 0;
        int totalCalories = 0;
        int totalWater = 0;

        for (final record in todayRecords) {
          totalSteps += record.steps;
          totalCalories += record.calories;
          totalWater += record.water;
        }

        return RefreshIndicator(
          onRefresh: _loadDashboard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Today's date
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 28,
                      color: Color(0xFF416799),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Activity Summary",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          today,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                'Health Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              _summaryCard(
                title: 'Total Steps Walked',
                value: totalSteps.toString(),
                unit: 'steps',
                icon: Icons.directions_walk,
                color: const Color(0xFF2196F3),
                backgroundColor: const Color(0xFFE3F2FD),
              ),

              _summaryCard(
                title: 'Total Calories Burned',
                value: totalCalories.toString(),
                unit: 'kcal',
                icon: Icons.local_fire_department,
                color: const Color(0xFFFF5722),
                backgroundColor: const Color(0xFFFFE8E0),
              ),

              _summaryCard(
                title: 'Total Water Intake',
                value: totalWater.toString(),
                unit: 'mL',
                icon: Icons.water_drop,
                color: const Color(0xFF03A9F4),
                backgroundColor: const Color(0xFFDDF5FF),
              ),

              const SizedBox(height: 22),

              // Daily goals heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Health Goals',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    tooltip: 'Edit Goals',
                    onPressed: _openGoalSettings,
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _goalCard(
                title: 'Daily Steps Goal',
                current: totalSteps,
                goal: _stepsGoal,
                unit: 'steps',
                icon: Icons.directions_walk,
              ),

              _goalCard(
                title: 'Daily Water Goal',
                current: totalWater,
                goal: _waterGoal,
                unit: 'mL',
                icon: Icons.water_drop,
              ),

              const SizedBox(height: 16),

              // Add Record button
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _openAddRecord,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Health Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF416799),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // View Records button
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _openRecords,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View All Health Records'),
                ),
              ),

              const SizedBox(height: 12),

              // Weekly Progress button
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _openWeeklyProgress,
                  icon: const Icon(Icons.show_chart),
                  label: const Text('View Weekly Progress'),
                ),
              ),

              const SizedBox(height: 24),

              // Information card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF416799)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your daily health summary and goals are '
                        'calculated using saved health records.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Color(0xFF416799)),
            SizedBox(width: 8),
            Text('HealthMate', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Goal Settings',
            onPressed: _openGoalSettings,
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboard(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            setState(() => _selectedIndex = 0);
          } else if (index == 1) {
            _openAddRecord();
          } else if (index == 2) {
            _openRecords();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Record',
          ),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Records'),
        ],
      ),
    );
  }
}
