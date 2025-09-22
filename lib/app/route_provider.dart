import 'package:edu_stream/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/models/course.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/admin/video_upload_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/admin/admin_upload_page.dart'; // FIXED IMPORT
import '../presentation/widgets/common/access_denied_screen.dart';
import '../presentation/screens/splash_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      // Loading state: stay
      if (authState.isLoading) return null;

      // Not logged in, trying to access protected routes
      if (!authState.isLoggedIn && !_isAuthRoute(state.uri.toString())) {
        return AppRoutes.login;
      }

      // Logged in, trying to access auth routes
      if (authState.isLoggedIn && _isAuthRoute(state.uri.toString())) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // Home
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),

      // Admin Upload Page
      GoRoute(
        path: AppRoutes.adminUpload,
        name: 'admin-upload',
        builder: (context, state) {
          final authState = ref.read(authProvider);
          if (!authState.isLoggedIn || authState.role != UserRole.admin) {
            return const AccessDeniedScreen();
          }
          return const AdminUploadPage();
        },
      ),

      // Regular User Video Upload
      GoRoute(
        path: AppRoutes.videoUpload,
        name: 'video-upload',
        builder: (context, state) {
          final authState = ref.read(authProvider);
          if (!authState.isLoggedIn) {
            return const AccessDeniedScreen();
          }
          return const VideoUploadScreen();
        },
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

bool _isAuthRoute(String location) {
  const authRoutes = [
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.splash,
  ];
  return authRoutes.contains(location);
}