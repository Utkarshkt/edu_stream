import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/course.dart';
import '../common/progress_indicator.dart';


class CourseCard extends ConsumerWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Handle course tap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening ${course.title}...')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CourseThumbnail(course: course),
            _CourseCardInfo(course: course),
          ],
        ),
      ),
    );
  }
}

class _CourseThumbnail extends StatelessWidget {
  final Course course;

  const _CourseThumbnail({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: course.colors),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(course.emoji, style: TextStyle(fontSize: 32)),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  course.duration,
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCardInfo extends StatelessWidget {
  final Course course;

  const _CourseCardInfo({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${course.instructor} • ${course.views}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
            CustomProgressIndicator(progress: course.progress),
          ],
        ),
      ),
    );
  }
}