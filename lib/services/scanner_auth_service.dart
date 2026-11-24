
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'server_config_service.dart';

class ScannerAuthException implements Exception {
  final String message;

  ScannerAuthException(this.message);

  @override
  String toString() => message;
}

class ScannerAuthService {
  ScannerAuthService._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'scanner_auth_token';
  static const String _userKey = 'scanner_user_data';

  /// Authenticates scanner personnel through Laravel.
  ///
  /// Laravel checks the scanner account status before issuing a token.
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final apiUrl = await ServerConfigService.getServerUrl();

    if (apiUrl == null || apiUrl.trim().isEmpty) {
      throw ScannerAuthException(
        'Server is not configured. Please contact the administrator.',
      );
    }

    try {
      final dio = ServerConfigService.createApiClient(apiUrl);

      final response = await dio.post(
        'scanner/login',
        data: {
          'username': username.trim(),
          'password': password,
        },
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['success'] != true ||
          data['token'] == null ||
          data['user'] == null) {
        throw ScannerAuthException(
          data['message'] ?? 'Unable to sign in.',
        );
      }

      final token = data['token'].toString();
      final user = Map<String, dynamic>.from(data['user']);

      // Store the authentication token and scanner profile securely.
      await _storage.write(
        key: _tokenKey,
        value: token,
      );

      await _storage.write(
        key: _userKey,
        value: jsonEncode(user),
      );

      return user;
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map &&
          responseData['message'] != null) {
        throw ScannerAuthException(
          responseData['message'].toString(),
        );
      }

      if (e.response?.statusCode == 401) {
        throw ScannerAuthException(
          'Invalid username or password.',
        );
      }

      if (e.response?.statusCode == 403) {
        throw ScannerAuthException(
          'Your scanner account is disabled. Please contact the AGMA ONE Administrator.',
        );
      }

      if (e.response == null) {
        throw ScannerAuthException(
          'Cannot connect to AGMA ONE server. Check your server configuration.',
        );
      }

      throw ScannerAuthException(
        'Login failed. Please try again.',
      );
    }
  }

  /// Returns the currently saved scanner token.
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Returns the cached scanner profile.
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final userData = await _storage.read(key: _userKey);

    if (userData == null) return null;

    try {
      return Map<String, dynamic>.from(
        jsonDecode(userData),
      );
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  /// Validates an existing token with Laravel.
  ///
  /// This also detects accounts disabled after their previous login.
  static Future<Map<String, dynamic>?> restoreSession() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final apiUrl = await ServerConfigService.getServerUrl();

    if (apiUrl == null || apiUrl.trim().isEmpty) {
      await clearSession();
      return null;
    }

    try {
      final dio = ServerConfigService.createApiClient(apiUrl);

      final response = await dio.get(
        'scanner/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['success'] != true || data['user'] == null) {
        await clearSession();
        return null;
      }

      final user = Map<String, dynamic>.from(data['user']);

      if (user['status'] != 'active') {
        await clearSession();
        return null;
      }

      await _storage.write(
        key: _userKey,
        value: jsonEncode(user),
      );

      return user;
    } on DioException catch (e) {
      // Invalid or revoked credentials require a fresh login.
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        await clearSession();
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Logs out scanner personnel and revokes the server token.
  static Future<void> logout() async {
    final token = await getToken();
    final apiUrl = await ServerConfigService.getServerUrl();

    try {
      if (token != null &&
          token.isNotEmpty &&
          apiUrl != null &&
          apiUrl.trim().isNotEmpty) {
        final dio = ServerConfigService.createApiClient(apiUrl);

        await dio.post(
          'scanner/logout',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
    } catch (_) {
      // Clear the local session even if the server is unreachable.
    } finally {
      await clearSession();
    }
  }

  /// Clears the scanner's local authentication data.
  static Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
