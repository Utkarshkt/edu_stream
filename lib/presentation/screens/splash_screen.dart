import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../providers/auth_provider.dart';


class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Redirect based on auth state once loading is complete
    if (!authState.isLoading) {
      Future.microtask(() {
        if (authState.isLoggedIn) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.login);
        }
      });
    }

    return const Scaffold(
      backgroundColor: Color(0xFF667eea),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 80),
            SizedBox(height: 20),
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
            SizedBox(height: 20),
            Text('EduStream',
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            Text('Loading your learning journey...',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}