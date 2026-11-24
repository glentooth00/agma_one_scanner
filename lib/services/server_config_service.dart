
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServerConfigService {
  ServerConfigService._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _serverUrlKey = 'agma_server_url';
  static const String _scannerTokenKey = 'scanner_auth_token';

  static const Duration _connectionTimeout =
      Duration(seconds: 5);

  static const Duration _receiveTimeout =
      Duration(seconds: 5);

  /// Returns the currently saved API base URL.
  static Future<String?> getServerUrl() async {
    return await _storage.read(key: _serverUrlKey);
  }

  /// Normalizes the API URL for Dio.
  /// Always ends with a slash so relative paths retain /api.
  static String _normalizeApiUrl(String apiBaseUrl) {
    final cleanUrl = apiBaseUrl.trim();

    if (cleanUrl.isEmpty) {
      throw ArgumentError('API base URL is required.');
    }

    return '${cleanUrl.replaceFirst(RegExp(r'/+$'), '')}/';
  }

  /// Builds the API base URL from the server address and port.
  static String buildApiUrl({
    required String host,
    required String port,
    String scheme = 'http',
  }) {
    final cleanHost = host.trim();
    final cleanPort = port.trim();

    if (cleanHost.isEmpty) {
      throw ArgumentError('Server IP or hostname is required.');
    }

    if (cleanHost.contains('://') ||
        cleanHost.contains('/') ||
        cleanHost.contains(' ')) {
      throw ArgumentError('Enter only an IP address or hostname.');
    }

    if (cleanPort.isEmpty) {
      throw ArgumentError('Server port is required.');
    }

    final portNumber = int.tryParse(cleanPort);

    if (portNumber == null ||
        portNumber < 1 ||
        portNumber > 65535) {
      throw ArgumentError('Enter a valid port between 1 and 65535.');
    }

    if (scheme != 'http' && scheme != 'https') {
      throw ArgumentError('Invalid server protocol.');
    }

    return '$scheme://$cleanHost:$portNumber/api';
  }

  /// Creates a Dio client using the configured API URL.
  static Dio createApiClient(String apiBaseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: _normalizeApiUrl(apiBaseUrl),
        connectTimeout: _connectionTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  /// Tests whether the configured AGMA ONE API is reachable.
  static Future<bool> testConnection(String apiBaseUrl) async {
    try {
      final dio = createApiClient(apiBaseUrl);

      // Relative path preserves the /api base path.
      final response = await dio.get('health');

      final data = response.data;

      return response.statusCode == 200 &&
          data is Map &&
          data['success'] == true &&
          data['application'] == 'AGMA ONE';
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Saves the server URL.
  ///
  /// If the server changes, the previous scanner token is cleared.
  static Future<void> saveServerUrl(String apiBaseUrl) async {
    final normalizedUrl =
        _normalizeApiUrl(apiBaseUrl).replaceFirst(RegExp(r'/$'), '');

    final currentUrl = await getServerUrl();

    if (currentUrl != normalizedUrl) {
      await _storage.delete(key: _scannerTokenKey);
    }

    await _storage.write(
      key: _serverUrlKey,
      value: normalizedUrl,
    );
  }

  /// Removes the saved server configuration and scanner token.
  static Future<void> clearServerConfig() async {
    await _storage.delete(key: _serverUrlKey);
    await _storage.delete(key: _scannerTokenKey);
  }
}
