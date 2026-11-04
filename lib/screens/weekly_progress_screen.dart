import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../database/database_helper.dart';
import '../models/health_record.dart';

class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({super.key});

  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  bool _isLoading = true;
  List<HealthRecord> _records = [];

  String _selectedMetric = 'Steps';

  final List<String> _metrics = ['Steps', 'Calories', 'Water'];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final records = await DatabaseHelper().getRecords();

      if (!mounted) return;

      setState(() {
        _records = records;
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

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  int _getMetricValue(HealthRecord record) {
    if (_selectedMetric == 'Steps') {
      return record.steps;
    }

    if (_selectedMetric == 'Calories') {
      return record.calories;
    }

    return record.water;
  }

  List<FlSpot> _getWeeklyData() {
    final today = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 0; i < 7; i++) {
      final date = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 6 - i));

      final dateString = _formatDate(date);

      int total = 0;

      for (final record in _records) {
        if (record.date == dateString) {
          total += _getMetricValue(record);
        }
      }

      spots.add(FlSpot(i.toDouble(), total.toDouble()));
    }

    return spots;
  }

  double _getMaxY(List<FlSpot> spots) {
    double highest = 0;

    for (final spot in spots) {
      if (spot.y > highest) {
        highest = spot.y;
      }
    }

    if (highest == 0) return 100;

    return highest * 1.2;
  }

  String _getDayLabel(int index) {
    final today = DateTime.now();

    final date = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: 6 - index));

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getWeeklyData();

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Progress')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRecords,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Icon(
                    Icons.show_chart,
                    size: 60,
                    color: Color(0xFF1976D2),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Your Weekly Health Progress',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'View your activity over the last 7 days',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedMetric,
                    decoration: const InputDecoration(
                      labelText: 'Select Health Metric',
                      prefixIcon: Icon(Icons.analytics_outlined),
                    ),
                    items: _metrics.map((metric) {
                      return DropdownMenuItem(
                        value: metric,
                        child: Text(metric),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMetric = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 30),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 24, 20, 16),
                      child: SizedBox(
                        height: 260,
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: 6,
                            minY: 0,
                            maxY: _getMaxY(spots),
                            gridData: const FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();

                                    if (index < 0 ||
                                        index > 6 ||
                                        value != index.toDouble()) {
                                      return const SizedBox();
                                    }

                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        _getDayLabel(index),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: false,
                                color: const Color(0xFF1976D2),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFF1976D2)
                                      .withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Total $_selectedMetric This Week',
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            spots
                                .fold<double>(0, (sum, spot) => sum + spot.y)
                                .toInt()
                                .toString(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _selectedMetric == 'Water'
                                ? 'mL'
                                : _selectedMetric == 'Calories'
                                ? 'kcal'
                                : 'steps',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Data is calculated from your saved health records.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }
}
