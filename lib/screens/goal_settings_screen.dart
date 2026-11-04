import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalSettingsScreen extends StatefulWidget {
  const GoalSettingsScreen({super.key});

  @override
  State<GoalSettingsScreen> createState() => _GoalSettingsScreenState();
}

class _GoalSettingsScreenState extends State<GoalSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _stepsController = TextEditingController();
  final _waterController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  // Load previously saved goals
  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedSteps = prefs.getInt('steps_goal') ?? 8000;
      final savedWater = prefs.getInt('water_goal') ?? 2000;

      if (!mounted) return;

      setState(() {
        _stepsController.text = savedSteps.toString();
        _waterController.text = savedWater.toString();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _stepsController.text = '8000';
        _waterController.text = '2000';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load saved goals')),
      );
    }
  }

  // Validate the entered goal
  String? _validateGoal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a goal';
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return 'Goal must be greater than zero';
    }

    return null;
  }

  // Save goals using SharedPreferences
  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final stepsGoal = int.parse(_stepsController.text.trim());
      final waterGoal = int.parse(_waterController.text.trim());

      final prefs = await SharedPreferences.getInstance();

      final stepsSaved = await prefs.setInt('steps_goal', stepsGoal);

      final waterSaved = await prefs.setInt('water_goal', waterGoal);

      if (!stepsSaved || !waterSaved) {
        throw Exception('Unable to save goals');
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save goals. Please try again.'),
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
  void dispose() {
    _stepsController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),

      appBar: AppBar(title: const Text('Goal Settings'), centerTitle: true),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Goal icon
                        const Icon(
                          Icons.flag,
                          size: 65,
                          color: Color(0xFF2196F3),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Set Your Daily Goals',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Customize your daily steps and water targets',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),

                        const SizedBox(height: 35),

                        // Daily steps goal
                        TextFormField(
                          controller: _stepsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Daily Steps Goal',
                            prefixIcon: Icon(Icons.directions_walk),
                            suffixText: 'steps',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateGoal,
                        ),

                        const SizedBox(height: 22),

                        // Daily water goal
                        TextFormField(
                          controller: _waterController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Daily Water Goal',
                            prefixIcon: Icon(Icons.water_drop),
                            suffixText: 'mL',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateGoal,
                        ),

                        const SizedBox(height: 30),

                        // Save button
                        SizedBox(
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveGoals,
                            icon: const Icon(Icons.save),
                            label: Text(
                              _isSaving ? 'Saving...' : 'Save Goals',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Your goals are saved on this device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
