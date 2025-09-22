// lib/presentation/widgets/common/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/course.dart';
import '../../providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  final VoidCallback? onAdminDashboard;

  const AppDrawer({super.key, this.onAdminDashboard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.role == UserRole.admin;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    authState.name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authState.name ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authState.email ?? '',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    authState.role.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  backgroundColor: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.blue[700]),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('home');
            },
          ),
          ListTile(
            leading: Icon(Icons.library_books, color: Colors.purple),
            title: Text('My Courses'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('my-courses');
            },
          ),
          ListTile(
            leading: Icon(Icons.download, color: Colors.orange),
            title: Text('Downloads'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('downloads');
            },
          ),
          if (isAdmin) ...[
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ADMIN TOOLS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.blue),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                onAdminDashboard?.call();
              },
            ),
            ListTile(
              leading: Icon(Icons.upload, color: Colors.green),
              title: Text('Upload Content'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('admin-upload');
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.orange),
              title: Text('User Management'),
              onTap: () {
                // Navigate to user management
              },
            ),
          ],
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: Colors.grey),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout'),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.goNamed('login');
            },
          ),
        ],
      ),
    );
  }
}