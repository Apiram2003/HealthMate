import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _emailKey = 'user_email';
  static const _passwordHashKey = 'password_hash';
  static const _saltKey = 'password_salt';
  static const _loginKey = 'is_logged_in';

  String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  String _createSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  Future<String?> register(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_emailKey)) {
      return 'An account already exists on this device';
    }

    final salt = _createSalt();
    final hash = _hashPassword(password, salt);

    await prefs.setString(_emailKey, email.trim().toLowerCase());
    await prefs.setString(_saltKey, salt);
    await prefs.setString(_passwordHashKey, hash);
    await prefs.setBool(_loginKey, false);

    return null;
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString(_emailKey);
    final savedHash = prefs.getString(_passwordHashKey);
    final salt = prefs.getString(_saltKey);

    if (savedEmail == null || savedHash == null || salt == null) {
      return false;
    }

    final enteredHash = _hashPassword(password, salt);

    if (email.trim().toLowerCase() == savedEmail && enteredHash == savedHash) {
      await prefs.setBool(_loginKey, true);
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
  }
}
