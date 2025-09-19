import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course.dart';

// Provider for managing video uploads
final videoUploadProvider = StateNotifierProvider<VideoUploadNotifier, List<CourseVideo>>((ref) {
  return VideoUploadNotifier();
});

class VideoUploadNotifier extends StateNotifier<List<CourseVideo>> {
  VideoUploadNotifier() : super([]);

  void addVideo(CourseVideo video) {
    state = [...state, video];
  }

  void removeVideo(String videoId) {
    state = state.where((video) => video.id != videoId).toList();
  }

  void updateVideoProgress(String videoId, double progress) {
    state = state.map((video) {
      if (video.id == videoId) {
        // For simulation, we'll just mark as uploaded when progress reaches 100%
        return video.copyWith(
          isUploaded: progress >= 100,
        );
      }
      return video;
    }).toList();
  }
}

// Provider for current upload progress
final uploadProgressProvider = StateProvider<double>((ref) => 0.0);

// Provider for selected course for upload
final selectedCourseForUploadProvider = StateProvider<Course?>((ref) => null);