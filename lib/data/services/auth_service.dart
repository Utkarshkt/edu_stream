import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String baseUrl = "http://192.168.29.174:5001/api";

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// ----------------- LOGIN -----------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('🔐 Attempting login for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📊 API Status: ${response.statusCode}');
      debugPrint('📄 API Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _storeAuthData(data);
        return _buildSuccessResponse(data, 'API Login successful');
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// ----------------- REGISTER -----------------
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      debugPrint('📝 Attempting registration for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'student',
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📊 Register Status: ${response.statusCode}');
      debugPrint('📄 Register Response: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        await _storeAuthData(data);
        return _buildSuccessResponse(data, 'Registration successful via API');
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// ----------------- STORAGE HELPERS -----------------
  Future<void> _storeAuthData(Map<String, dynamic> data) async {
    try {
      await _storage.write(key: 'auth_token', value: data['token']);
      await _storage.write(key: 'user_data', value: json.encode(data['user']));
    } catch (e) {
      debugPrint('❌ Secure storage error: $e');
    }
  }

  Map<String, dynamic> _buildSuccessResponse(Map<String, dynamic> data, String message) {
    return {
      'success': true,
      'message': message,
      'token': data['token'],
      'user': data['user'],
    };
  }

  /// ----------------- UTILITIES -----------------
  Future<Map<String, dynamic>?> getUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      return userData != null ? json.decode(userData) : null;
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (e) {
      debugPrint('❌ Error getting token: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_data');
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
    }
  }

  /// ----------------- CONNECTION TEST -----------------
  Future<Map<String, dynamic>> testConnection() async {
    try {
      debugPrint('🔗 Testing connection to: $baseUrl');

      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return {
        'success': true,
        'status': response.statusCode,
        'message': 'Server is reachable',
        'response': response.body,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Server timeout',
        'status': 408,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection test failed',
        'error': e.toString(),
        'status': 500,
      };
    }
  }
}
