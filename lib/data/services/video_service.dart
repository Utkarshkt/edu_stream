import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VideoService {
  static const String baseUrl = 'http://192.168.29.174:5001/api';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> uploadVideoWithProgress({
    required File videoFile,
    required String title,
    required String description,
    required int durationInSeconds,
    required String courseId,
    File? thumbnailFile,
    required Function(double progress) onProgress,
  }) async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('User not authenticated. Please login again.');
    }

    print('🚀 Starting video upload to backend...');
    print('📁 Video file: ${videoFile.path}');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/videos/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields.addAll({
        'title': title,
        'description': description,
        'duration': durationInSeconds.toString(),
        'courseId': courseId,
        'isPreview': 'false',
        'order': '0',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'video',
        videoFile.path,
      ));

      if (thumbnailFile != null && await thumbnailFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'thumbnail',
          thumbnailFile.path,
        ));
      }

      // Simulate progress
      onProgress(0.3);
      await Future.delayed(Duration(milliseconds: 200));

      print('📤 Sending request to backend...');
      var response = await request.send();
      onProgress(0.7);

      final responseBody = await response.stream.bytesToString();
      onProgress(1.0);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: $responseBody');

      // **PROPER RESPONSE HANDLING FOR YOUR BACKEND**
      if (response.statusCode == 201) {
        try {
          final result = json.decode(responseBody);

          // Your backend returns: { success: true, data: {...}, message: "..." }
          if (result['success'] == true) {
            print('✅ Upload successful!');
            return {
              'success': true,
              'data': result['data'],
              'message': result['message'] ?? 'Video uploaded successfully'
            };
          } else {
            // If success is false or missing
            throw Exception(result['message'] ?? 'Upload failed');
          }
        } catch (e) {
          print('❌ JSON parse error: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        // Handle non-201 status codes
        try {
          final errorData = json.decode(responseBody);
          throw Exception(errorData['message'] ?? 'Upload failed with status ${response.statusCode}');
        } catch (e) {
          throw Exception('HTTP ${response.statusCode}: $responseBody');
        }
      }
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }

  // Simple version without progress
  Future<Map<String, dynamic>> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    required int durationInSeconds,
    required String courseId,
    File? thumbnailFile,
  }) async {
    return await uploadVideoWithProgress(
      videoFile: videoFile,
      title: title,
      description: description,
      durationInSeconds: durationInSeconds,
      courseId: courseId,
      thumbnailFile: thumbnailFile,
      onProgress: (progress) {
        // Empty progress callback for simple version
      },
    );
  }
}