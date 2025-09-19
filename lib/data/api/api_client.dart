import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://your-backend.com/api';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> _authenticatedRequest(
      String endpoint, {
        String method = 'GET',
        Map<String, dynamic>? body,
      }) async {
    final token = await _storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body != null ? json.encode(body) : null,
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized - please login again');
    }

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> uploadVideo(Map<String, dynamic> videoData) async {
    return await _authenticatedRequest(
      'videos/upload',
      method: 'POST',
      body: videoData,
    );
  }
}