import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class CustomerApi {
  static Future<Map<String, dynamic>> sendOtp({required String phone}) {
    return _post('/auth/send-otp', {'phone': phone});
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return _post('/auth/verify-otp', {'phone': phone, 'otp': otp});
  }

  static Future<Map<String, dynamic>> createProfile({
    required String phone,
    required String name,
    required String email,
    required String birthDate,
    required String address,
    required String? profileImage,
  }) {
    return _post('/customers/profile', {
      'phone': phone,
      'name': name,
      'email': email,
      'birthDate': birthDate,
      'address': address,
      'profileImage': profileImage,
    });
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final decoded = _safeDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw ApiException(
      decoded['message']?.toString() ?? 'Request failed',
      statusCode: response.statusCode,
    );
  }

  static Map<String, dynamic> _safeDecode(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{'data': decoded};
  }
}
