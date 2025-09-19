import 'package:flutter/material.dart';

class VideoPlayerArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            // Handle play button tap
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Playing video...')),
            );
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: Color(0xFF2196F3),
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}