// lib/presentation/widgets/header/app_header.dart
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onAdminPressed;

  const AppHeader({super.key, this.onAdminPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Your existing header content
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EduStream',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Learn anything, anywhere',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onAdminPressed != null)
            IconButton(
              icon: Icon(Icons.admin_panel_settings, color: Colors.white),
              onPressed: onAdminPressed,
              tooltip: 'Admin Dashboard',
            ),
        ],
      ),
    );
  }
}