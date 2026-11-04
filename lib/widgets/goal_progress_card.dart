import 'package:flutter/material.dart';

class GoalProgressCard extends StatelessWidget {
  final String title;
  final int currentValue;
  final int goalValue;
  final String unit;
  final IconData icon;

  const GoalProgressCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.goalValue,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goalValue > 0
        ? (currentValue / goalValue).clamp(0.0, 1.0).toDouble()
        : 0.0;

    final percentage = goalValue > 0
        ? (currentValue / goalValue * 100).toStringAsFixed(1)
        : '0.0';

    final completed = currentValue >= goalValue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              '$currentValue / $goalValue $unit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue,
              backgroundColor: Colors.blue.shade50,
            ),

            const SizedBox(height: 10),

            Text(
              completed
                  ? 'Goal completed! Great job!'
                  : '$percentage% of daily goal completed',
              style: TextStyle(
                color: completed ? Colors.green : Colors.blueGrey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
