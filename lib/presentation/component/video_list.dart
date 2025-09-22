import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class VideoList extends ConsumerWidget {
  final List<Map<String, dynamic>> videos;

  const VideoList({super.key, required this.videos});

  Future<void> _downloadVideo(BuildContext context, String videoUrl, String title) async {
    try {
      final response = await http.get(Uri.parse(videoUrl));

      if (response.statusCode == 200) {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final filename = '${title.replaceAll(' ', '_')}.mp4';
          final file = File('${directory.path}/$filename');
          await file.writeAsBytes(response.bodyBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded: ${file.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot access downloads directory')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${response.statusCode}')),
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
            leading: video['thumbnailUrl'] != null && video['thumbnailUrl'].isNotEmpty
                ? Image.network(video['thumbnailUrl'], width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.video_library, size: 40),
            title: Text(video['title'] ?? 'Untitled'),
            subtitle: Text(video['duration'] ?? 'Unknown duration'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadVideo(
                  context,
                  video['videoUrl'] ?? '',
                  video['title'] ?? 'video'
              ),
            ),
          ),
        );
      },
    );
  }
}