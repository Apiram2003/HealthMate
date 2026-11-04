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

  static const Color oceanBlue = Color(0xFF0277BD);
  static const Color darkBlue = Color(0xFF01579B);

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

  Future<void> _pickFilterDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_filterQuery) ?? DateTime.now(),
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

  void _clearFilter() {
    setState(() {
      _filterController.clear();
      _filterQuery = '';
    });
  }

  Future<void> _addNewRecord() async {
    await Navigator.push<HealthRecord>(
      context,
      MaterialPageRoute(builder: (context) => const AddRecordScreen()),
    );

    if (mounted) {
      await _loadRecords();
    }
  }

  Future<void> _editRecord(HealthRecord record) async {
    await Navigator.push<HealthRecord>(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecordScreen(existingRecord: record),
      ),
    );

    if (mounted) {
      await _loadRecords();
    }
  }

  Future<void> _confirmDelete(HealthRecord record) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete the record for ${record.date}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
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
    final healthProvider = context.watch<HealthRecordProvider>();
    final records = healthProvider.records;

    final filteredRecords = _filterQuery.isEmpty
        ? records
        : records
              .where((record) => record.date.contains(_filterQuery))
              .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FD),

      appBar: AppBar(
        title: const Text(
          'Health Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: oceanBlue,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewRecord,
        backgroundColor: oceanBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),

      body: Column(
        children: [
          // Blue summary header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: oceanBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Health Journey',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Track your daily progress and stay healthy.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.folder_open, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      '${records.length} Total Records',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _filterController,
              decoration: InputDecoration(
                labelText: 'Filter by Date (YYYY-MM-DD)',
                prefixIcon: const Icon(Icons.search, color: oceanBlue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_filterQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilter,
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: oceanBlue),
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
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 70,
                            color: oceanBlue,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Health Records Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _filterQuery.isEmpty
                                ? 'Add your first health record to get started.'
                                : 'Try another date or clear the filter.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 100,
                    ),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: oceanBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      record.date,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: darkBlue,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Edit record',
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: oceanBlue,
                                    ),
                                    onPressed: () => _editRecord(record),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete record',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDelete(record),
                                  ),
                                ],
                              ),

                              const Divider(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: _MetricItem(
                                      icon: Icons.directions_walk,
                                      label: 'Steps',
                                      value: '${record.steps}',
                                      color: oceanBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _MetricItem(
                                      icon: Icons.local_fire_department,
                                      label: 'Calories',
                                      value: '${record.calories}',
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _MetricItem(
                                      icon: Icons.water_drop,
                                      label: 'Water (mL)',
                                      value: '${record.water}',
                                      color: Colors.blue,
                                    ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
