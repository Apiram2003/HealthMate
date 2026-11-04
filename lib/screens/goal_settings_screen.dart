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

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    _stepsController.text = (prefs.getInt('stepsGoal') ?? 8000).toString();

    _waterController.text = (prefs.getInt('waterGoal') ?? 2000).toString();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;

    final steps = int.parse(_stepsController.text.trim());
    final water = int.parse(_waterController.text.trim());

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('stepsGoal', steps);
    await prefs.setInt('waterGoal', water);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily goals saved successfully')),
    );

    Navigator.pop(context, true);
  }

  String? _validateGoal(String? value) {
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return 'Goal must be greater than zero';
    }

    return null;
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Settings'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Icon(Icons.flag, size: 60, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text(
                        'Set Your Daily Goals',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        onPressed: _saveGoals,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Goals'),
                        style: FilledButton.styleFrom(
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
