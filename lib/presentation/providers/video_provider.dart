// lib/providers/video_provider.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadResponse {
  final bool success;
  final String message;
  final String? videoId;

  UploadResponse({
    required this.success,
    required this.message,
    this.videoId,
  });
}

class VideoProvider {
  // Single method that handles both cases with optional parameters
  Future<UploadResponse> uploadVideo({
    required String title,
    required String description,
    required String category,
    File? videoFile, // Make videoFile optional
    File? thumbnailFile, // Make thumbnailFile optional
    required Function(double) onProgress,
  }) async {
    try {
      // Simulate upload process
      for (int i = 0; i <= 100; i += 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        onProgress(i / 100);
      }

      // Different success message based on whether a file was uploaded
      final successMessage = videoFile != null
          ? 'Video file uploaded successfully'
          : 'Video uploaded successfully';

      return UploadResponse(
        success: true,
        message: successMessage,
        videoId: 'vid_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      return UploadResponse(
        success: false,
        message: 'Upload failed: $e',
      );
    }
  }
}

final videoProviderProvider = Provider<VideoProvider>((ref) {
  return VideoProvider();
});