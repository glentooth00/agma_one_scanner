
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalAdminAuth {
  LocalAdminAuth._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _initializedKey = 'local_admin_initialized';
  static const String _usernameKey = 'local_admin_username';
  static const String _passwordKey = 'local_admin_password';
  static const String _sessionKey = 'local_admin_session';

  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'AGMA@One2026';

  /// Creates the default administrator account on first launch.
  static Future<void> initialize() async {
    final initialized = await _storage.read(
      key: _initializedKey,
    );

    if (initialized == 'true') return;

    await _storage.write(
      key: _usernameKey,
      value: defaultUsername,
    );

    await _storage.write(
      key: _passwordKey,
      value: defaultPassword,
    );

    await _storage.write(
      key: _initializedKey,
      value: 'true',
    );
  }

  /// Validates local administrator credentials.
  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    await initialize();

    final savedUsername = await _storage.read(
      key: _usernameKey,
    );

    final savedPassword = await _storage.read(
      key: _passwordKey,
    );

    if (username.trim() != savedUsername ||
        password != savedPassword) {
      return false;
    }

    await _storage.write(
      key: _sessionKey,
      value: 'true',
    );

    return true;
  }

  /// Checks whether an administrator session exists.
  static Future<bool> isLoggedIn() async {
    final session = await _storage.read(
      key: _sessionKey,
    );

    return session == 'true';
  }

  /// Ends the local administrator session.
  static Future<void> logout() async {
    await _storage.delete(key: _sessionKey);
  }
}
