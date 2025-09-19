import 'package:flutter/material.dart';

enum UserRole { student, admin, instructor }
enum VideoStatus { uploaded, processing, ready, failed }

class CourseVideo {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String videoUrl;
  final String thumbnailUrl;
  final bool isUploaded;
  final DateTime uploadDate;
  final double fileSize;
  final int order; // Display order in course
  final bool isPreview; // Free preview video
  final String uploadedBy; // Admin user ID
  final VideoStatus status;

  CourseVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isUploaded,
    required this.uploadDate,
    required this.fileSize,
    required this.order,
    required this.isPreview,
    required this.uploadedBy,
    required this.status,
  });
}

class Course {
  final String id;
  final String title;
  final String instructor;
  final String duration;
  final String views;
  final double progress;
  final String emoji;
  final List<Color> colors;
  final List<CourseVideo> videos;
  final bool canUploadVideos;
  final String adminId;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.duration,
    required this.views,
    required this.progress,
    required this.emoji,
    required this.colors,
    this.videos = const [],
    this.canUploadVideos = false,
    required this.adminId,
  });
}

extension CourseVideoExtension on CourseVideo {
  CourseVideo copyWith({
    String? id,
    String? title,
    String? description,
    String? duration,
    String? videoUrl,
    String? thumbnailUrl,
    bool? isUploaded,
    DateTime? uploadDate,
    double? fileSize,
    int? order,
    bool? isPreview,
    String? uploadedBy,
    VideoStatus? status,
  }) {
    return CourseVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadDate: uploadDate ?? this.uploadDate,
      fileSize: fileSize ?? this.fileSize,
      order: order ?? this.order,
      isPreview: isPreview ?? this.isPreview,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      status: status ?? this.status,
    );
  }
}

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime joinDate;
  final List<String> enrolledCourses;
  final Map<String, double> courseProgress; // courseId -> progress percentage
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.joinDate,
    this.enrolledCourses = const [],
    this.courseProgress = const {},
    this.isActive = true,
  });
}