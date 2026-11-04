import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/health_record.dart';
import '../providers/health_record_provider.dart';

class AddRecordScreen extends StatefulWidget {
  final HealthRecord? existingRecord;

  const AddRecordScreen({super.key, this.existingRecord});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  static const Color oceanBlue = Color(0xFF0277BD);
  static const Color lightBlue = Color(0xFFE3F2FD);

  late DateTime _selectedDate;
  late TextEditingController _stepsController;
  late TextEditingController _caloriesController;
  late TextEditingController _waterController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final record = widget.existingRecord;

    _selectedDate = record == null
        ? DateTime.now()
        : DateTime.tryParse(record.date) ?? DateTime.now();

    _stepsController = TextEditingController(
      text: record?.steps.toString() ?? '',
    );

    _caloriesController = TextEditingController(
      text: record?.calories.toString() ?? '',
    );

    _waterController = TextEditingController(
      text: record?.water.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  String _formattedDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

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
      final provider = context.read<HealthRecordProvider>();

      if (isEditing) {
        await provider.updateRecord(record);
      } else {
        await provider.addRecord(record);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Health record updated successfully!'
                : 'Health record saved successfully!',
          ),
          backgroundColor: oceanBlue,
        ),
      );

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

  Widget _buildNumberField({
    required String title,
    required String hint,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required String fieldName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        decoration: InputDecoration(
          labelText: title,
          hintText: hint,
          suffixText: unit,
          prefixIcon: Icon(icon, color: iconColor),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: oceanBlue, width: 2),
          ),
        ),
        validator: (value) => _validateNumber(value, fieldName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FD),
      appBar: AppBar(
        backgroundColor: oceanBlue,
        foregroundColor: Colors.white,
        title: Text(
          isEditing ? 'Edit Health Record' : 'Add Health Record',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 25,
                        child: Icon(Icons.favorite, color: oceanBlue, size: 28),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Track Your Health',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: oceanBlue,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Record your daily activity',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Date card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD7E6F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: oceanBlue,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Record Date',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _formattedDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 17,
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

                const SizedBox(height: 28),

                const Text(
                  'Daily Activity Details',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: oceanBlue,
                  ),
                ),

                const SizedBox(height: 18),

                _buildNumberField(
                  title: 'Steps Walked',
                  hint: 'e.g. 6000',
                  unit: 'steps',
                  icon: Icons.directions_walk,
                  iconColor: Colors.green,
                  controller: _stepsController,
                  fieldName: 'steps',
                ),

                _buildNumberField(
                  title: 'Calories Burned',
                  hint: 'e.g. 450',
                  unit: 'kcal',
                  icon: Icons.local_fire_department,
                  iconColor: Colors.deepOrange,
                  controller: _caloriesController,
                  fieldName: 'calories',
                ),

                _buildNumberField(
                  title: 'Water Intake',
                  hint: 'e.g. 2000',
                  unit: 'mL',
                  icon: Icons.water_drop,
                  iconColor: oceanBlue,
                  controller: _waterController,
                  fieldName: 'water intake',
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 55,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveForm,
                    icon: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isSaving
                          ? 'Saving...'
                          : isEditing
                          ? 'Update Health Record'
                          : 'Save Health Record',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: oceanBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Your health records are saved on this device.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
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
