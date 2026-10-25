import 'package:flutter/material.dart';
import '../widgets/summary_card.dart';
import 'add_record_screen.dart';
import 'records_screen.dart';

/// Screen 1 – Dashboard
/// Displays:
/// - Application name and today's date
/// - Steps walked today (Green)
/// - Calories burned today (Orange/Red)
/// - Water intake today (Blue)
/// - Quick buttons to Add Record and View Health Records
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Helper to get today's date formatted as YYYY-MM-DD
  String _getFormattedDate() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final todayDate = _getFormattedDate();

    // Sample data for Stage 2 UI demonstration
    const sampleSteps = '6,450';
    const sampleCalories = '420';
    const sampleWater = '2,100';

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.teal),
            SizedBox(width: 8),
            Text(
              'HealthMate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header Card with Today's Date
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.teal,
                        size: 22,
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
                          const SizedBox(height: 2),
                          Text(
                            todayDate,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Reusable Summary Card 1: Steps (Green)
              const SummaryCard(
                title: 'Total Steps Walked',
                value: sampleSteps,
                unit: 'steps',
                icon: Icons.directions_walk,
                color: Colors.green,
              ),

              // Reusable Summary Card 2: Calories (Deep Orange / Red)
              const SummaryCard(
                title: 'Total Calories Burned',
                value: sampleCalories,
                unit: 'kcal',
                icon: Icons.local_fire_department,
                color: Colors.deepOrange,
              ),

              // Reusable Summary Card 3: Water Intake (Blue)
              const SummaryCard(
                title: 'Total Water Intake',
                value: sampleWater,
                unit: 'mL',
                icon: Icons.water_drop,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              // Navigation Action Buttons
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddRecordScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Health Record'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt, color: Colors.teal),
                label: const Text(
                  'View All Health Records',
                  style: TextStyle(color: Colors.teal),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Beginner demo note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.teal.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.teal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stage 2 Demo: Values above are sample data. SQLite database integration will be added in Stage 3.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.teal,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddRecordScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecordsScreen(),
              ),
            );
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
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Records',
          ),
        ],
      ),
    );
  }
}
