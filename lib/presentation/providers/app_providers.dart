import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course.dart';

// State Providers
final selectedCategoryProvider = StateProvider<int>((ref) => 0);
final searchQueryProvider = StateProvider<String>((ref) => '');
final featuredCourseProvider = StateProvider<Course?>((ref) => null);
final coursesProvider = StateProvider<List<Course>>((ref) => []);