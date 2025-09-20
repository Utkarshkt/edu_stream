import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../screens/downloals_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/my_courses_screen.dart';

class AppDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF21CBF3),
              Color(0xFF4ECDC4),
            ],
          ),
        ),
        child: Column(
          children: [
            _DrawerHeader(),
            Expanded(
              child: _DrawerMenuItems(selectedIndex: selectedCategory),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Alex Johnson',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'alex.johnson@email.com',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItems extends ConsumerWidget {
  final int selectedIndex;

  const _DrawerMenuItems({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 20),
        children: [
          _DrawerMenuItem(
            icon: Icons.home_rounded,
            title: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = 0;
              Navigator.pop(context);
            },
          ),
          _DrawerMenuItem(
            icon: Icons.book_rounded,
            title: 'My Courses',
            isSelected: selectedIndex == 1,
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = 1;
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyCoursesScreen()));
            },
          ),
          _DrawerMenuItem(
            icon: Icons.trending_up_rounded,
            title: 'Trending',
            isSelected: selectedIndex == 2,
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = 2;
              Navigator.pop(context);
            },
          ),
          _DrawerMenuItem(
            icon: Icons.bookmark_rounded,
            title: 'Bookmarks',
            onTap: () => Navigator.pop(context),
          ),
          _DrawerMenuItem(
            icon: Icons.download_rounded,
            title: 'Downloads',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DownloadsScreen()));
            },
          ),
          _DrawerMenuItem(
            icon: Icons.analytics_rounded,
            title: 'Progress',
            onTap: () => Navigator.pop(context),
          ),
          Divider(height: 30, thickness: 1, color: Colors.grey[300]),
          _DrawerMenuItem(
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () => Navigator.pop(context),
          ),
          _DrawerMenuItem(
            icon: Icons.help_rounded,
            title: 'Help & Support',
            onTap: () => Navigator.pop(context),
          ),
          _DrawerMenuItem(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            isLogout: true,
            onTap: () async {
              Navigator.pop(context); // Close the drawer first

              try {
                // Perform logout
                final authNotifier = ref.read(authProvider.notifier);
                await authNotifier.logout();

                // FORCE navigation to login screen - clear everything
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false, // This removes ALL previous routes
                );
              } catch (e) {
                // If logout fails, still go to login page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool isLogout;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.isSelected = false,
    this.isLogout = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Color(0xFF2196F3).withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(0xFF2196F3)
                : isLogout
                ? Color(0xFFFF6B6B).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : isLogout
                ? Color(0xFFFF6B6B)
                : Colors.grey[600],
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Color(0xFF2196F3)
                : isLogout
                ? Color(0xFFFF6B6B)
                : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}