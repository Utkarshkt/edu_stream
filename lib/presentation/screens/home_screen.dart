import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common/app_drawer.dart';
import '../widgets/header/app_header.dart';
import '../widgets/home/main_content.dart';
import '../widgets/home/navigation_tab_bar.dart';
import '../../data/models/course.dart';
import '../providers/app_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> categories = [
    '🏠 Home',
    '📚 My Courses',
    '🔥 Trending',
    '🧮 Mathematics',
    '🔬 Science',
    '💻 Programming',
    '🎨 Art & Design',
    '🌍 Languages',
    '💼 Business',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _initializeCourses();
  }

  void _initializeCourses() {
    // Initialize sample courses
    final sampleCourses = [
      Course(
        id: '1',
        title: 'Python Data Structures & Algorithms',
        instructor: 'Prof. Mike Chen',
        views: '2.1K views',
        duration: '45:30',
        progress: 0.65,
        emoji: '🐍',
        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)], adminId: '',
      ),
      Course(
        id: '2',
        title: 'React Hooks Deep Dive',
        instructor: 'Emily Rodriguez',
        views: '5.7K views',
        duration: '32:15',
        progress: 0.30,
        emoji: '⚛️',
        colors: [Color(0xFF667eea), Color(0xFF764ba2)], adminId: '',
      ),
      Course(
        id: '3',
        title: 'UI/UX Design Principles',
        instructor: 'Alex Thompson',
        views: '3.2K views',
        duration: '28:45',
        progress: 0.85,
        emoji: '🎨',
        colors: [Color(0xFFFA709A), Color(0xFFFEE140)], adminId: '',
      ),
      Course(
        id: '4',
        title: 'Machine Learning Basics',
        instructor: 'Dr. Lisa Wang',
        views: '4.8K views',
        duration: '52:30',
        progress: 0.40,
        emoji: '🤖',
        colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)], adminId: '',
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coursesProvider.notifier).state = sampleCourses;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(),
              NavigationTabBar(
                tabController: _tabController,
                categories: categories,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: MainContent(
                    tabController: _tabController,
                    categories: categories,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}