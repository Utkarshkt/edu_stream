import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';
import '../widgets/common/app_drawer.dart';
import '../widgets/header/app_header.dart';
import '../widgets/home/main_content.dart';
import '../widgets/home/navigation_tab_bar.dart';
import '../../data/models/course.dart';
import '../providers/app_providers.dart';
import '../providers/auth_provider.dart';
import '../../../app/routes.dart'; // ADD THIS IMPORT

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  String _authSource = '';
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
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _loadUserData();
    _initializeCourses();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getUser();
    final token = await _authService.getToken();

    setState(() {
      _userData = user;
      _authSource = token?.contains('local') == true ? 'Local Storage' : 'API Server';
    });
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
        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        adminId: '',
      ),
      Course(
        id: '2',
        title: 'React Hooks Deep Dive',
        instructor: 'Emily Rodriguez',
        views: '5.7K views',
        duration: '32:15',
        progress: 0.30,
        emoji: '⚛️',
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        adminId: '',
      ),
      Course(
        id: '3',
        title: 'UI/UX Design Principles',
        instructor: 'Alex Thompson',
        views: '3.2K views',
        duration: '28:45',
        progress: 0.85,
        emoji: '🎨',
        colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
        adminId: '',
      ),
      Course(
        id: '4',
        title: 'Machine Learning Basics',
        instructor: 'Dr. Lisa Wang',
        views: '4.8K views',
        duration: '52:30',
        progress: 0.40,
        emoji: '🤖',
        colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
        adminId: '',
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
    final authState = ref.watch(authProvider);
    final isAdmin = authState.role == UserRole.admin;

    return Scaffold(
      drawer: AppDrawer(
        onAdminDashboard: isAdmin ? () => context.pushNamed('admin-dashboard') : null,
      ),
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
              AppHeader(
                onAdminPressed: isAdmin ? () => context.pushNamed('admin-dashboard') : null,
              ),
              if (isAdmin) _buildAdminQuickAccess(context),
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
                    isAdmin: isAdmin,
                    onAdminUpload: () => context.pushNamed('admin-upload'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminQuickAccess(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Admin Access',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => context.pushNamed('admin-dashboard'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: const Text('Dashboard →'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.pushNamed('admin-upload'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: const Text('Upload →'),
          ),
        ],
      ),
    );
  }
}