import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../data/services/video_service.dart';

class VideoList extends ConsumerWidget {
  final List<Map<String, dynamic>> videos;

  const VideoList({super.key, required this.videos});

  Future<void> _downloadVideo(BuildContext context, String filename) async {
    try {
      final videoService = VideoService();
      final signedUrl = await videoService.getSignedUrl(filename);

      final response = await http.get(Uri.parse('http://localhost:5000$signedUrl'));

      if (response.statusCode == 200) {
        final directory = await getDownloadsDirectory();
        final file = File('${directory?.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded: ${file.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Card(
          child: ListTile(
            leading: video['thumbnailUrl'] != null
                ? Image.network(video['thumbnailUrl'])
                : const Icon(Icons.video_library),
            title: Text(video['title']),
            subtitle: Text(video['duration']),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadVideo(context, video['filename']),
            ),
          ),
        );
      },
    );
  }
}