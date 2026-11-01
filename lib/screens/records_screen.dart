import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/health_record.dart';
import '../providers/health_record_provider.dart';
import 'add_record_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final TextEditingController _filterController = TextEditingController();

  String _filterQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  // Load records using Provider
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

  // Select date for filtering
  Future<void> _pickFilterDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final date =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';

      setState(() {
        _filterController.text = date;
        _filterQuery = date;
      });
    }
  }

  // Clear date filter
  void _clearFilter() {
    setState(() {
      _filterController.clear();
      _filterQuery = '';
    });
  }

  // Open Add Record screen
  Future<void> _addNewRecord() async {
    await Navigator.push<HealthRecord>(
      context,
      MaterialPageRoute(builder: (context) => const AddRecordScreen()),
    );

    // Provider updates records after saving
    if (mounted) {
      setState(() {});
    }
  }

  // Open Edit Record screen
  Future<void> _editRecord(HealthRecord record) async {
    await Navigator.push<HealthRecord>(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecordScreen(existingRecord: record),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // Delete record using Provider
  Future<void> _confirmDelete(HealthRecord record) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete the record for ${record.date}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true && record.id != null) {
      if (!mounted) return;

      try {
        await context.read<HealthRecordProvider>().deleteRecord(record.id!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health record deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete health record')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get records from Provider
    final healthProvider = context.watch<HealthRecordProvider>();
    final records = healthProvider.records;

    final filteredRecords = _filterQuery.isEmpty
        ? records
        : records
              .where((record) => record.date.contains(_filterQuery))
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewRecord,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),

      body: Column(
        children: [
          // Date filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _filterController,
              decoration: InputDecoration(
                labelText: 'Filter by Date (YYYY-MM-DD)',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_filterQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilter,
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: _pickFilterDate,
                    ),
                  ],
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _filterQuery = value.trim();
                });
              },
            ),
          ),

          // Records list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRecords.isEmpty
                ? const Center(child: Text('No health records found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 80,
                    ),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.teal,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      record.date,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.teal,
                                    ),
                                    onPressed: () => _editRecord(record),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDelete(record),
                                  ),
                                ],
                              ),

                              const Divider(),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _MetricItem(
                                    icon: Icons.directions_walk,
                                    label: 'Steps',
                                    value: '${record.steps}',
                                    color: Colors.green,
                                  ),
                                  _MetricItem(
                                    icon: Icons.local_fire_department,
                                    label: 'Calories',
                                    value: '${record.calories}',
                                    color: Colors.deepOrange,
                                  ),
                                  _MetricItem(
                                    icon: Icons.water_drop,
                                    label: 'Water (mL)',
                                    value: '${record.water}',
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Small widget for displaying health values
class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
