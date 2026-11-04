import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _email = '';
  String _name = 'HealthMate User';
  String _phone = '';

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Load saved profile details
  Future<void> _loadProfile() async {
    try {
      final email = await _authService.getUserEmail();
      final prefs = await SharedPreferences.getInstance();

      final savedName = prefs.getString('profile_name');
      final savedPhone = prefs.getString('profile_phone');

      if (!mounted) return;

      setState(() {
        _email = email ?? 'No email found';
        _name = savedName ?? 'HealthMate User';
        _phone = savedPhone ?? '';

        _nameController.text = _name;
        _phoneController.text = _phone;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load profile details')),
      );
    }
  }

  // Enable edit mode
  void _editProfile() {
    _nameController.text = _name;
    _phoneController.text = _phone;

    setState(() {
      _isEditing = true;
    });
  }

  // Cancel editing
  void _cancelEdit() {
    _nameController.text = _name;
    _phoneController.text = _phone;

    setState(() {
      _isEditing = false;
    });
  }

  // Save profile details locally
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final newName = _nameController.text.trim();
      final newPhone = _phoneController.text.trim();

      await prefs.setString('profile_name', newName);
      await prefs.setString('profile_phone', newPhone);

      if (!mounted) return;

      setState(() {
        _name = newName;
        _phone = newPhone;
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save profile details')),
      );
    }
  }

  // Logout confirmation
  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from HealthMate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1976D2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              tooltip: 'Edit Profile',
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Color(0xFFD8E8FF),
                    child: Icon(Icons.person, size: 54, color: primaryBlue),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),

                  const SizedBox(height: 32),

                  if (!_isEditing) ...[
                    // Account information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Divider(height: 28),

                            ListTile(
                              leading: const Icon(
                                Icons.person_outline,
                                color: primaryBlue,
                              ),
                              title: const Text('Full Name'),
                              subtitle: Text(_name),
                            ),

                            ListTile(
                              leading: const Icon(
                                Icons.email_outlined,
                                color: primaryBlue,
                              ),
                              title: const Text('Email Address'),
                              subtitle: Text(_email),
                            ),

                            ListTile(
                              leading: const Icon(
                                Icons.phone_outlined,
                                color: primaryBlue,
                              ),
                              title: const Text('Phone Number'),
                              subtitle: Text(
                                _phone.isEmpty ? 'Not provided' : _phone,
                              ),
                            ),

                            const ListTile(
                              leading: Icon(
                                Icons.phone_android,
                                color: primaryBlue,
                              ),
                              title: Text('Account Type'),
                              subtitle: Text('Local Device Account'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _editProfile,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Edit profile form
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Edit Profile Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 24),

                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }

                                  if (value.trim().length < 2) {
                                    return 'Name must contain at least 2 characters';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                  hintText: '0771234567',
                                ),
                                validator: (value) {
                                  final phone = value?.trim() ?? '';

                                  if (phone.isEmpty) {
                                    return null;
                                  }

                                  if (!RegExp(r'^[0-9+ ]+$').hasMatch(phone)) {
                                    return 'Enter a valid phone number';
                                  }

                                  if (phone.length < 9 || phone.length > 16) {
                                    return 'Enter a valid phone number';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: Text(
                                    _isSaving ? 'Saving...' : 'Save Changes',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              OutlinedButton(
                                onPressed: _isSaving ? null : _cancelEdit,
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  const Text(
                    'HealthMate - Personal Health Tracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}
