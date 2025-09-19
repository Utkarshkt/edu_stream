import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/course.dart';

final secureStorage = FlutterSecureStorage();

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoggedIn;
  final String? userId;
  final UserRole role;
  final String? email;
  final AppUser? user;
  final String? authToken;
  final DateTime? tokenExpiry;

  AuthState({
    required this.isLoggedIn,
    this.userId,
    this.role = UserRole.student,
    this.email,
    this.user,
    this.authToken,
    this.tokenExpiry,
  });

  bool get isTokenValid => tokenExpiry?.isAfter(DateTime.now()) ?? false;
  bool get isAuthenticated => isLoggedIn && isTokenValid;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoggedIn: false)) {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    final token = await secureStorage.read(key: 'auth_token');
    final expiry = await secureStorage.read(key: 'token_expiry');
    final userData = await secureStorage.read(key: 'user_data');

    if (token != null && expiry != null && userData != null) {
      // TODO: Parse stored data and restore state
    }
  }

  Future<void> login(String email, String password, UserRole role) async {
    try {
      final response = await _authenticateWithBackend(email, password);

      if (response['success']) {
        await secureStorage.write(key: 'auth_token', value: response['token']);
        await secureStorage.write(key: 'token_expiry', value: response['expiry'].toString());

        final user = AppUser(
          id: response['user']['id'],
          email: email,
          displayName: response['user']['name'],
          role: UserRole.values.firstWhere(
                (e) => e.toString() == 'UserRole.${response['user']['role']}',
          ),
          joinDate: DateTime.now(),
        );

        state = AuthState(
          isLoggedIn: true,
          userId: user.id,
          role: user.role,
          email: email,
          user: user,
          authToken: response['token'],
          tokenExpiry: DateTime.parse(response['expiry']),
        );
      }
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'token_expiry');
    await secureStorage.delete(key: 'user_data');

    state = AuthState(isLoggedIn: false);
  }

  /// 🔹 Mock backend authentication (replace with real API later)
  Future<Map<String, dynamic>> _authenticateWithBackend(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    if (email == "test@example.com" && password == "123456") {
      return {
        "success": true,
        "token": "fake_jwt_token_123",
        "expiry": DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        "user": {
          "id": "u123",
          "name": "Test User",
          "role": "student",
        }
      };
    } else {
      throw Exception("Invalid credentials");
    }
  }
}
