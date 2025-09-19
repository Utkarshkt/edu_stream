import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class NavigationTabBar extends ConsumerWidget {
  final TabController tabController;
  final List<String> categories;

  const NavigationTabBar({
    Key? key,
    required this.tabController,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        indicatorColor: Color(0xFF2196F3),
        indicatorWeight: 4,
        indicatorPadding: EdgeInsets.symmetric(horizontal: 8),
        labelColor: Color(0xFF2196F3),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        onTap: (index) {
          ref.read(selectedCategoryProvider.notifier).state = index;
        },
        tabs: categories
            .map((category) => Tab(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(category),
          ),
        ))
            .toList(),
      ),
    );
  }
}