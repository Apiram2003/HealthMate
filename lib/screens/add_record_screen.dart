import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/health_record.dart';
import '../providers/health_record_provider.dart';

// Screen to add or edit a health record
class AddRecordScreen extends StatefulWidget {
  final HealthRecord? existingRecord;

  const AddRecordScreen({super.key, this.existingRecord});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late TextEditingController _stepsController;
  late TextEditingController _caloriesController;
  late TextEditingController _waterController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final record = widget.existingRecord;

    if (record != null) {
      // Fill the form when editing
      _selectedDate = DateTime.tryParse(record.date) ?? DateTime.now();

      _stepsController = TextEditingController(text: record.steps.toString());

      _caloriesController = TextEditingController(
        text: record.calories.toString(),
      );

      _waterController = TextEditingController(text: record.water.toString());
    } else {
      // Empty form for new record
      _selectedDate = DateTime.now();
      _stepsController = TextEditingController();
      _caloriesController = TextEditingController();
      _waterController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  // Select record date
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Convert date to YYYY-MM-DD
  String _formattedDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // Validate numeric fields
  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Please enter a valid whole number';
    }

    if (number < 0) {
      return '$fieldName cannot be negative';
    }

    return null;
  }

  // Save or update record using Provider
  Future<void> _saveForm() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final isEditing = widget.existingRecord != null;

    final record = HealthRecord(
      id: widget.existingRecord?.id,
      date: _formattedDate(_selectedDate),
      steps: int.parse(_stepsController.text.trim()),
      calories: int.parse(_caloriesController.text.trim()),
      water: int.parse(_waterController.text.trim()),
    );

    try {
      final healthProvider = context.read<HealthRecordProvider>();

      if (isEditing) {
        await healthProvider.updateRecord(record);
      } else {
        await healthProvider.addRecord(record);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Health record updated successfully!'
                : 'Health record saved successfully!',
          ),
          backgroundColor: Colors.teal,
        ),
      );

      // Return saved record to previous screen
      Navigator.pop(context, record);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save health record'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Health Record' : 'Add Health Record'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Date selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.teal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Record Date'),
                              const SizedBox(height: 4),
                              Text(
                                _formattedDate(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _pickDate,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Steps input
                TextFormField(
                  controller: _stepsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Steps Walked',
                    hintText: 'e.g. 6000',
                    prefixIcon: Icon(
                      Icons.directions_walk,
                      color: Colors.green,
                    ),
                    suffixText: 'steps',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validateNumber(value, 'steps'),
                ),

                const SizedBox(height: 16),

                // Calories input
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories Burned',
                    hintText: 'e.g. 450',
                    prefixIcon: Icon(
                      Icons.local_fire_department,
                      color: Colors.deepOrange,
                    ),
                    suffixText: 'kcal',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validateNumber(value, 'calories'),
                ),

                const SizedBox(height: 16),

                // Water input
                TextFormField(
                  controller: _waterController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Water Intake',
                    hintText: 'e.g. 2000',
                    prefixIcon: Icon(Icons.water_drop, color: Colors.blue),
                    suffixText: 'mL',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validateNumber(value, 'water intake'),
                ),

                const SizedBox(height: 28),

                // Save button
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveForm,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : isEditing
                        ? 'Update Health Record'
                        : 'Save Health Record',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
