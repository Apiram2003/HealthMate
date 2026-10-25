import 'package:flutter/material.dart';
import '../models/health_record.dart';
import 'add_record_screen.dart';

/// Screen 3 – Health Records
///
/// Features:
/// - Displays a list of saved health records (with sample records for Stage 2)
/// - Date filter UI (interactive date picker and search input)
/// - Shows steps (Green), calories (Orange), and water (Blue)
/// - Edit button (opens AddRecordScreen in edit mode)
/// - Delete button with confirmation dialog
/// - Floating Action Button to add a new record
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  // Sample records for Stage 2 UI demonstration
  List<HealthRecord> _records = [
    const HealthRecord(
      id: 1,
      date: '2026-10-25',
      steps: 6450,
      calories: 420,
      water: 2100,
    ),
    const HealthRecord(
      id: 2,
      date: '2026-10-24',
      steps: 8200,
      calories: 530,
      water: 2500,
    ),
    const HealthRecord(
      id: 3,
      date: '2026-10-23',
      steps: 5100,
      calories: 360,
      water: 1800,
    ),
    const HealthRecord(
      id: 4,
      date: '2026-10-22',
      steps: 9400,
      calories: 610,
      water: 2800,
    ),
  ];

  final TextEditingController _filterController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  /// Picks a date to filter the list
  Future<void> _pickFilterDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formatted =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      setState(() {
        _filterController.text = formatted;
        _filterQuery = formatted;
      });
    }
  }

  /// Clears the active date filter
  void _clearFilter() {
    setState(() {
      _filterController.clear();
      _filterQuery = '';
    });
  }

  /// Displays a delete confirmation dialog
  Future<void> _confirmDelete(HealthRecord record) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Record'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the health record for ${record.date}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      setState(() {
        _records = _records.where((r) => r.id != record.id).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record for ${record.date} deleted (UI Demo)'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Navigates to edit record
  Future<void> _editRecord(HealthRecord record) async {
    final updated = await Navigator.push<HealthRecord>(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecordScreen(existingRecord: record),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        final index = _records.indexWhere((r) => r.id == record.id);
        if (index != -1) {
          _records[index] = updated;
        }
      });
    }
  }

  /// Navigates to add a new record
  Future<void> _addNewRecord() async {
    final newRecord = await Navigator.push<HealthRecord>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddRecordScreen(),
      ),
    );

    if (newRecord != null && mounted) {
      setState(() {
        // Create a new record with a new ID
        final created = HealthRecord(
          id: DateTime.now().millisecondsSinceEpoch,
          date: newRecord.date,
          steps: newRecord.steps,
          calories: newRecord.calories,
          water: newRecord.water,
        );
        _records.insert(0, created);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter records by query (date)
    final filteredRecords = _filterQuery.isEmpty
        ? _records
        : _records.where((r) => r.date.contains(_filterQuery)).toList();

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Search / Filter Bar by Date
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _filterController,
                  decoration: InputDecoration(
                    labelText: 'Filter by Date (YYYY-MM-DD)',
                    hintText: 'e.g. 2026-10-25',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_filterQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearFilter,
                            tooltip: 'Clear filter',
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month, color: Colors.teal),
                          onPressed: _pickFilterDate,
                          tooltip: 'Select date',
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filterQuery = value.trim();
                    });
                  },
                ),
              ),

              // Active filter chip if filtering
              if (_filterQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Chip(
                        avatar: const Icon(Icons.filter_alt, size: 16),
                        label: Text('Filtered by: $_filterQuery'),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: _clearFilter,
                      ),
                    ],
                  ),
                ),

              // Health Records List
              Expanded(
                child: filteredRecords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No records found for "$_filterQuery"',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _clearFilter,
                              child: const Text('Clear Filter'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 80, // Space for FloatingActionButton
                        ),
                        itemCount: filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = filteredRecords[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Record Date and Action Buttons Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                            color: Colors.teal,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            record.date,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.teal,
                                            ),
                                            tooltip: 'Edit record',
                                            onPressed: () =>
                                                _editRecord(record),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                            tooltip: 'Delete record',
                                            onPressed: () =>
                                                _confirmDelete(record),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const Divider(height: 16),

                                  // Metrics Row (Steps, Calories, Water)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // Steps metric
                                      _MetricItem(
                                        icon: Icons.directions_walk,
                                        label: 'Steps',
                                        value: '${record.steps}',
                                        color: Colors.green,
                                      ),
                                      // Calories metric
                                      _MetricItem(
                                        icon: Icons.local_fire_department,
                                        label: 'Calories',
                                        value: '${record.calories} kcal',
                                        color: Colors.deepOrange,
                                      ),
                                      // Water metric
                                      _MetricItem(
                                        icon: Icons.water_drop,
                                        label: 'Water',
                                        value: '${record.water} mL',
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
        ),
      ),
    );
  }
}

/// Helper widget to display a single metric inside a record card
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
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
