import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName = 'dgr6nkdaq';
  final String uploadPreset = 'edu_stream_preset'; // Create this in Cloudinary dashboard

  Future<String> uploadVideo(File file, {String folder = 'edu_videos'}) async {
    try {
      var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/video/upload');

      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..fields['resource_type'] = 'video'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      throw Exception('Video upload failed: $e');
    }
  }

  Future<String> uploadThumbnail(File file, {String folder = 'edu_thumbnails'}) async {
    try {
      var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..fields['resource_type'] = 'image'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      throw Exception('Thumbnail upload failed: $e');
    }
  }
}