import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/video_service.dart';


final videoServiceProvider = Provider<VideoService>((ref) => VideoService());

final videoUploadProvider = StateNotifierProvider<VideoUploadNotifier, VideoUploadState>(
      (ref) => VideoUploadNotifier(ref.read(videoServiceProvider)),
);

class VideoUploadNotifier extends StateNotifier<VideoUploadState> {
  final VideoService _videoService;

  VideoUploadNotifier(this._videoService) : super(VideoUploadInitial());

  Future<void> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    required String category,
    File? thumbnailFile,
    required Function(double progress) onProgress,
  }) async {
    try {
      state = VideoUploadLoading(0.0);

      // **USE BACKEND API APPROACH** - Convert category to courseId if needed
      final result = await _videoService.uploadVideoWithProgress(
        videoFile: videoFile,
        title: title,
        description: description,
        durationInSeconds: 0, // You need to get actual duration
        courseId: category, // Using category as courseId, or map accordingly
        thumbnailFile: thumbnailFile,
        onProgress: (progress) {
          state = VideoUploadLoading(progress);
          onProgress(progress);
        },
      );

      state = VideoUploadSuccess(result);
    } catch (e) {
      state = VideoUploadError(e.toString());
      rethrow;
    }
  }

  void reset() {
    state = VideoUploadInitial();
  }
}

// State classes
abstract class VideoUploadState {}

class VideoUploadInitial extends VideoUploadState {}

class VideoUploadLoading extends VideoUploadState {
  final double progress;
  VideoUploadLoading(this.progress);
}

class VideoUploadSuccess extends VideoUploadState {
  final Map<String, dynamic> result;
  VideoUploadSuccess(this.result);
}

class VideoUploadError extends VideoUploadState {
  final String message;
  VideoUploadError(this.message);
}