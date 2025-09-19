import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_content.dart';
import 'category_content.dart';

class MainContent extends ConsumerWidget {
  final TabController tabController;
  final List<String> categories;

  const MainContent({
    super.key,
    required this.tabController,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      controller: tabController,
      children: categories.map((category) {
        if (category == '🏠 Home') {
          return const HomeContent();
        }
        return CategoryContent(category: category);
      }).toList(),
    );
  }
}