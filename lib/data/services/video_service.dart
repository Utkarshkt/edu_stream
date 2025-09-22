import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VideoService {
  static const String baseUrl = 'http://localhost:5001/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Simple upload without progress tracking
  Future<Map<String, dynamic>> uploadVideo(File file, {
    required File videoFile,
    required String title,
    required String description,
    required String duration,
    required String courseId,
    File? thumbnailFile,
  }) async {
    final token = await _storage.read(key: 'auth_token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/videos/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'title': title,
      'description': description,
      'duration': duration,
      'courseId': courseId,
    });

    // Add video file
    request.files.add(await http.MultipartFile.fromPath(
      'video',
      videoFile.path,
      contentType: MediaType('video', 'mp4'),
    ));

    // Add thumbnail file if provided
    if (thumbnailFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'thumbnail',
        thumbnailFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return json.decode(responseBody);
    } else {
      throw Exception('Upload failed: ${response.statusCode} - $responseBody');
    }
  }

  // Upload with progress tracking - SIMPLIFIED VERSION
  Future<Map<String, dynamic>> uploadVideoWithProgress({
    required File videoFile,
    required String title,
    required String description,
    required String duration,
    required String courseId,
    required void Function(double progress, int bytesSent, int totalBytes) onProgress,
  }) async {
    final token = await _storage.read(key: 'auth_token');
    final fileLength = await videoFile.length();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/videos/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll({
      'title': title,
      'description': description,
      'duration': duration,
      'courseId': courseId,
    });

    request.files.add(await http.MultipartFile.fromPath(
      'video',
      videoFile.path,
      contentType: MediaType('video', 'mp4'),
    ));

    // Calculate total request length
    final totalBytes = await _calculateTotalLength(request, fileLength);
    int bytesSent = 0;

    // Send initial progress
    onProgress(0.0, 0, totalBytes);

    // Send the request and track progress
    var response = await request.send();

    // Listen to response stream for progress updates
    response.stream.listen(
          (List<int> chunk) {
        bytesSent += chunk.length;
        final progress = totalBytes > 0 ? bytesSent / totalBytes : 0;
        onProgress(progress.toDouble(), bytesSent, totalBytes); // Convert to double
      },
      onDone: () {
        onProgress(1.0, totalBytes, totalBytes); // Complete
      },
    );

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return json.decode(responseBody);
    } else {
      throw Exception('Upload failed: ${response.statusCode} - $responseBody');
    }
  }

  // Alternative: Even simpler progress tracking using timer
  Future<Map<String, dynamic>> uploadVideoWithSimpleProgress({
    required File videoFile,
    required String title,
    required String description,
    required String duration,
    required String courseId,
    required void Function(double progress) onProgress,
  }) async {
    final token = await _storage.read(key: 'auth_token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/videos/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll({
      'title': title,
      'description': description,
      'duration': duration,
      'courseId': courseId,
    });

    request.files.add(await http.MultipartFile.fromPath(
      'video',
      videoFile.path,
      contentType: MediaType('video', 'mp4'),
    ));

    // Simulate progress with timer (for UI feedback)
    double progress = 0.0;
    final timer = Timer.periodic( Duration(milliseconds: 100), (timer) {
      progress += 0.05;
      if (progress >= 0.9) timer.cancel();
      onProgress(progress);
    });

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      timer.cancel();
      onProgress(1.0); // Complete

      if (response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Upload failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      timer.cancel();
      rethrow;
    }
  }

  Future<int> _calculateTotalLength(http.MultipartRequest request, int fileLength) async {
    // Calculate approximate total request length
    int length = 0;

    // Add fields length
    request.fields.forEach((key, value) {
      length += utf8.encode('$key=$value').length;
    });

    // Add file length
    length += fileLength;

    // Add multipart boundary overhead (approximate)
    length += 1000;

    return length;
  }

  Future<List<Map<String, dynamic>>> getVideos() async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$baseUrl/videos'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<void> deleteVideo(String videoId) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/videos/$videoId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete video');
    }
  }

  Future<Map<String, dynamic>> getVideo(String videoId) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$baseUrl/videos/$videoId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load video');
    }
  }
}