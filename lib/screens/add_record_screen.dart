import 'package:flutter/material.dart';
import '../models/health_record.dart';

/// Screen 2 – Add / Edit Health Record
///
/// Features:
/// - Date picker for selecting the record date
/// - Steps input field (Green theme)
/// - Calories burned input field (Orange theme)
/// - Water intake input field (Blue theme)
/// - Basic validation (no empty fields, no negative numbers, valid integers)
/// - Can be reused for editing when an [existingRecord] is passed
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

  @override
  void initState() {
    super.initState();

    if (widget.existingRecord != null) {
      // Editing an existing record
      _selectedDate = DateTime.tryParse(widget.existingRecord!.date) ?? DateTime.now();
      _stepsController = TextEditingController(text: widget.existingRecord!.steps.toString());
      _caloriesController = TextEditingController(text: widget.existingRecord!.calories.toString());
      _waterController = TextEditingController(text: widget.existingRecord!.water.toString());
    } else {
      // Creating a new record
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

  /// Opens the Flutter date picker dialog
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Formats date to YYYY-MM-DD string
  String _formattedDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Validates integer inputs (must be positive number, not empty)
  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Please enter a valid whole number';
    }
    if (parsed < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Handles form submission
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.existingRecord != null;
      final record = HealthRecord(
        id: widget.existingRecord?.id,
        date: _formattedDate(_selectedDate),
        steps: int.parse(_stepsController.text.trim()),
        calories: int.parse(_caloriesController.text.trim()),
        water: int.parse(_waterController.text.trim()),
      );

      // In Stage 2, demonstrate UI success with a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Record updated (Stage 2 Demo): ${record.date}'
                : 'Record added (Stage 2 Demo): ${record.date}',
          ),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 2),
        ),
      );

      // Return to the previous screen
      Navigator.pop(context, record);
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
              padding: const EdgeInsets.all(20.0),
              children: [
                // Date Picker Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.teal),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Record Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _formattedDate(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.edit_calendar, size: 18),
                          label: const Text('Change'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            side: const BorderSide(color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Steps Input Field (Green)
                TextFormField(
                  controller: _stepsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Steps Walked',
                    hintText: 'e.g. 6000',
                    prefixIcon: const Icon(Icons.directions_walk, color: Colors.green),
                    suffixText: 'steps',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  validator: (val) => _validateNumber(val, 'steps'),
                ),

                const SizedBox(height: 16),

                // Calories Input Field (Deep Orange / Red)
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Calories Burned',
                    hintText: 'e.g. 450',
                    prefixIcon: const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                    suffixText: 'kcal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                    ),
                  ),
                  validator: (val) => _validateNumber(val, 'calories'),
                ),

                const SizedBox(height: 16),

                // Water Intake Input Field (Blue)
                TextFormField(
                  controller: _waterController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Water Intake',
                    hintText: 'e.g. 2000',
                    prefixIcon: const Icon(Icons.water_drop, color: Colors.blue),
                    suffixText: 'mL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  validator: (val) => _validateNumber(val, 'water intake'),
                ),

                const SizedBox(height: 28),

                // Save Record Button
                FilledButton.icon(
                  onPressed: _saveForm,
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEditing ? 'Update Health Record' : 'Save Health Record',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
