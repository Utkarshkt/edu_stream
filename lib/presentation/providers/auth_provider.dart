import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/course.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthState {
  final bool isLoggedIn;
  final String? userId;
  final UserRole role;
  final String? email;
  final String? displayName;
  final bool isLoading;

  AuthState({
    this.isLoggedIn = false,
    this.userId,
    this.role = UserRole.student,
    this.email,
    this.displayName,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? userId,
    UserRole? role,
    String? email,
    String? displayName,
    bool? isLoading,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    state = state.copyWith(isLoading: true);
    try {
      final userData = await _authService.getUser();
      if (userData != null) {
        state = AuthState(
          isLoggedIn: true,
          userId: userData['id'],
          email: userData['email'],
          displayName: userData['name'],
          role: _parseUserRole(userData['role']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  UserRole _parseUserRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'instructor':
        return UserRole.instructor;
      default:
        return UserRole.student;
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _authService.login(email, password);
      final userData = response['user'];

      state = AuthState(
        isLoggedIn: true,
        userId: userData['id'],
        email: userData['email'],
        displayName: userData['name'],
        role: _parseUserRole(userData['role']),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _authService.register(email, password, name);
      final userData = response['user'];

      state = AuthState(
        isLoggedIn: true,
        userId: userData['id'],
        email: userData['email'],
        //displayName: userData['name'],
        role: _parseUserRole(userData['role']),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      state = AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}