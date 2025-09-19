import 'package:edu_stream/app/routes.dart';
import 'package:edu_stream/presentation/screens/home_screen.dart';
import 'package:edu_stream/presentation/screens/login_screen.dart';
import 'package:edu_stream/presentation/screens/register_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/models/course.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/admin/video_upload_screen.dart';
import '../presentation/widgets/common/access_denied_screen.dart';
import '../utils/go_router_refresh_stream.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isLoggedIn ? AppRoutes.home : AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(
      // 👇 makes GoRouter listen to AuthNotifier state changes
      ref.watch(authProvider.notifier).stream,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) =>  HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUpload,
        builder: (context, state) {
          final auth = ref.read(authProvider);
          if (!auth.isLoggedIn || auth.role != UserRole.admin) {
            return const AccessDeniedScreen();
          }
          return  AdminUploadPage();
        },
      ),
      GoRoute(
        path: AppRoutes.accessDenied,
        builder: (context, state) => const AccessDeniedScreen(),
      ),
    ],
  );
});
