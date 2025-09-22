// lib/presentation/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your educational platform',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.upload,
                    title: 'Upload Content',
                    subtitle: 'Upload videos and courses',
                    color: Colors.blue,
                    onTap: () => context.pushNamed('admin-upload'),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Analytics',
                    subtitle: 'View platform statistics',
                    color: Colors.green,
                    onTap: () {},
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.people,
                    title: 'User Management',
                    subtitle: 'Manage users and roles',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.library_books,
                    title: 'Course Management',
                    subtitle: 'Manage courses and content',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'Platform configuration',
                    color: Colors.red,
                    onTap: () {},
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.report,
                    title: 'Reports',
                    subtitle: 'Generate reports',
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}