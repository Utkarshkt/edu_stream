import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/course.dart';
import '../providers/auth_provider.dart';
import '../../app/routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {

      print("Email entered: '${_emailController.text}'");
      print("Password entered: '${_passwordController.text}'");
      // simulate API login
      final response = await _simulateApiLogin(
        _emailController.text,
        _passwordController.text,
      );
      print("Login response: $response");

      if (response['success']) {
        final role = UserRole.values.firstWhere(
              (e) => e.toString() == 'UserRole.${response['user']['role']}',
          orElse: () => UserRole.student,
        );

        await ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
          role,
        );

        // ✅ Navigate to correct page after login
        if (role == UserRole.admin) {
          context.go(AppRoutes.adminUpload); // e.g. "/admin/upload"
        } else {
          context.go(AppRoutes.home); // e.g. "/home"
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<Map<String, dynamic>> _simulateApiLogin(
      String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail == 'admin@edustream.com' && trimmedPassword == 'admin123') {
      return {
        'success': true,
        'token': 'mock_jwt_admin',
        'user': {
          'id': 'user_001',
          'email': trimmedEmail,
          'name': 'Admin User',
          'role': 'admin',
        }
      };
    } else if (trimmedEmail == 'instructor@edustream.com' &&
        trimmedPassword == 'instructor123') {
      return {
        'success': true,
        'token': 'mock_jwt_instructor',
        'user': {
          'id': 'user_002',
          'email': trimmedEmail,
          'name': 'Instructor User',
          'role': 'instructor',
        }
      };
    } else if (trimmedEmail.isNotEmpty && trimmedPassword.isNotEmpty) {
      return {
        'success': true,
        'token': 'mock_jwt_student',
        'user': {
          'id': 'user_003',
          'email': trimmedEmail,
          'name': 'Student User',
          'role': 'student',
        }
      };
    } else {
      return {'success': false, 'message': 'Invalid email or password'};
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 80),
                const SizedBox(height: 20),
                const Text(
                  'EduStream',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to continue learning',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password too short';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation(Colors.white),
                          )
                              : const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Demo credentials
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Demo Credentials:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 10),
                        Text('Admin: admin@edustream.com / admin123'),
                        Text('Instructor: instructor@edustream.com / instructor123'),
                        Text('Student: any email / any password (min 6 chars)'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
