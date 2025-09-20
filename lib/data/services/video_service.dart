import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VideoService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<http.StreamedResponse> uploadVideo(
      File videoFile, {
        required String title,
        required String description,
        required String duration,
        required String courseId,
        File? thumbnailFile,
        required void Function(double) onProgress,
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

    // Create a stream controller to track progress
    final streamController = StreamController<List<int>>();
    int totalBytes = 0;
    int sentBytes = 0;

    // Listen to the request stream to track progress
    request.finalize().listen(
          (data) {
        sentBytes += data.length;
        if (totalBytes > 0) {
          final progress = (sentBytes / totalBytes) * 100;
          onProgress(progress);
        }
        streamController.add(data);
      },
      onDone: streamController.close,
      onError: streamController.addError,
    );

    // Get the total content length
    totalBytes = await _getContentLength(request);

    // Send the request
    final response = await http.Response.fromStream(await request.send());

    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      contentLength: response.contentLength,
      headers: response.headers,
      request: response.request,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  Future<int> _getContentLength(http.MultipartRequest request) async {
    // Calculate the total content length
    int length = 0;

    // Add fields length
    for (final field in request.fields.entries) {
      length += '${field.key}=${field.value}'.length;
    }

    // Add files length
    for (final file in request.files) {
      if (file is http.MultipartFile) {
        if (file.filename != null) {
          length += file.length;
        }
      }
    }

    return length;
  }

  Future<String> getSignedUrl(String filename) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse('$baseUrl/videos/generate-signed-url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{"filename": "$filename"}',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['signedUrl'];
    } else {
      throw Exception('Failed to get signed URL');
    }
  }
}