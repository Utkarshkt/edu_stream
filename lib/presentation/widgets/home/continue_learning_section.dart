import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/section_title.dart';
import 'course_grid.dart';
import '../../providers/app_providers.dart';

class ContinueLearningSection extends ConsumerWidget {
  const ContinueLearningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Continue Learning', icon: '🎥'),
        SizedBox(height: 12),
        CourseGrid(courses: courses),
      ],
    );
  }
}