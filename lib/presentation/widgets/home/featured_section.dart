import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/section_title.dart';
import 'video_player_area.dart';

class FeaturedSection extends ConsumerWidget {
  const FeaturedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Featured Course', icon: '⭐'),
        SizedBox(height: 12),
        _FeaturedVideoCard(),
      ],
    );
  }
}

class _FeaturedVideoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          VideoPlayerArea(),
          _VideoInfo(),
        ],
      ),
    );
  }
}

class _VideoInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete JavaScript Masterclass 2024',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          _VideoMetaInfo(),
          SizedBox(height: 12),
          Text(
            'Master modern JavaScript from fundamentals to advanced concepts. Learn ES6+, async programming, DOM manipulation, and build real-world projects.',
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoMetaInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _VideoMetaItem(icon: '👨‍🏫', text: 'Dr. Sarah Johnson'),
        _VideoMetaItem(icon: '⏱️', text: '12 hours'),
        _VideoMetaItem(icon: '👥', text: '25,430 students'),
        _VideoMetaItem(icon: '⭐', text: '4.8 rating'),
      ],
    );
  }
}

class _VideoMetaItem extends StatelessWidget {
  final String icon;
  final String text;

  const _VideoMetaItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: 14)),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}