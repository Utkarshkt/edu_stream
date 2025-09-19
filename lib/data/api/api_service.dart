import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://your-backend.com/api';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    final token = await _storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
      case 401:
        throw Exception('Unauthorized - please login again');
      case 403:
        throw Exception('Permission denied');
      case 500:
        throw Exception('Server error');
      default:
        throw Exception('Request failed with status: ${response.statusCode}');
    }
  }
}