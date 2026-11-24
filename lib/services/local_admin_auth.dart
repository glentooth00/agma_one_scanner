
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalAdminAuth {
  LocalAdminAuth._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  // Initial local device administrator credentials.
  static const String _adminUsername = 'admin';
  static const String _adminPassword = 'AGMA@One2026';

  static const String _loginKey = 'local_admin_logged_in';

  static Future<void> initialize() async {
    // Initialize secure storage.
    await _storage.read(key: _loginKey);
  }

  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    final isValid = username.trim() == _adminUsername &&
        password == _adminPassword;

    if (!isValid) {
      return false;
    }

    await _storage.write(
      key: _loginKey,
      value: 'true',
    );

    return true;
  }

  static Future<bool> isLoggedIn() async {
    final loggedIn = await _storage.read(key: _loginKey);
    return loggedIn == 'true';
  }

  static Future<void> logout() async {
    await _storage.delete(key: _loginKey);
  }
}
