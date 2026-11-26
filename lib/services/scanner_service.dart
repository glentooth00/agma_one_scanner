import 'package:dio/dio.dart';

import 'scanner_auth_service.dart';
import 'server_config_service.dart';

class ScannerServiceException implements Exception {
  final String message;

  const ScannerServiceException(this.message);

  @override
  String toString() => message;
}

class ScannerService {
  ScannerService._();

  static Future<Map<String, dynamic>> getMember(
    String membershipId,
  ) async {
    final cleanedId = membershipId.trim();

    if (cleanedId.isEmpty) {
      throw const ScannerServiceException(
        'The QR code does not contain a membership ID.',
      );
    }

    final apiUrl = await ServerConfigService.getServerUrl();

    if (apiUrl == null || apiUrl.trim().isEmpty) {
      throw const ScannerServiceException(
        'Server is not configured. Please contact the administrator.',
      );
    }

    final token = await ScannerAuthService.getToken();

    if (token == null || token.isEmpty) {
      throw const ScannerServiceException(
        'Your session has expired. Please sign in again.',
      );
    }

    try {
      final dio = ServerConfigService.createApiClient(apiUrl);

      final response = await dio.get(
        'scanner/member/${Uri.encodeComponent(cleanedId)}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final responseData = Map<String, dynamic>.from(response.data);

      if (responseData['success'] != true ||
          responseData['data'] == null) {
        throw ScannerServiceException(
          responseData['message']?.toString() ??
              'Unable to retrieve member information.',
        );
      }

      return Map<String, dynamic>.from(responseData['data']);
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map && responseData['message'] != null) {
        throw ScannerServiceException(
          responseData['message'].toString(),
        );
      }

      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        throw const ScannerServiceException(
          'Your session is no longer valid. Please sign in again.',
        );
      }

      if (e.response?.statusCode == 404) {
        throw const ScannerServiceException(
          'No AGMA registration was found for this membership ID.',
        );
      }

      if (e.response == null) {
        throw const ScannerServiceException(
          'Cannot connect to the AGMA ONE server. Check your connection.',
        );
      }

      throw const ScannerServiceException(
        'Unable to retrieve member information. Please try again.',
      );
    } on ScannerServiceException {
      rethrow;
    } catch (_) {
      throw const ScannerServiceException(
        'Something went wrong while retrieving member information.',
      );
    }
  }
}