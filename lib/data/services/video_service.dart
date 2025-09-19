import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_service.dart';

class VideoService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> uploadVideo({
    required String title,
    required String description,
    required String duration,
    required String filePath,
    required String courseId,
    int order = 0,
    bool isPreview = false,
  }) async {
    final token = await _storage.read(key: 'auth_token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/videos/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'title': title,
      'description': description,
      'duration': duration,
      'courseId': courseId,
      'order': order.toString(),
      'isPreview': isPreview.toString(),
    });

    request.files.add(await http.MultipartFile.fromPath(
      'video',
      filePath,
    ));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else {
      throw Exception('Upload failed: ${response.statusCode}');
    }
  }
}