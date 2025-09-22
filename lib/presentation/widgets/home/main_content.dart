// lib/presentation/widgets/home/main_content.dart
import 'package:flutter/material.dart';

class MainContent extends StatelessWidget {
  final TabController tabController;
  final List<String> categories;
  final bool isAdmin;
  final VoidCallback? onAdminUpload;

  const MainContent({
    super.key,
    required this.tabController,
    required this.categories,
    this.isAdmin = false,
    this.onAdminUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isAdmin && onAdminUpload != null)
          _buildAdminQuickActions(context),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: categories.map((category) {
              return _buildCategoryContent(category);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Tools',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Manage your educational content',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onAdminUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Upload Content'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(String category) {
    // Your existing content logic
    return Center(
      child: Text(
        'Content for $category',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}