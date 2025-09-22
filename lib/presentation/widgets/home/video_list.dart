import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoListItem extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String? thumbnailUrl;

  const VideoListItem({
    super.key,
    required this.title,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  State<VideoListItem> createState() => _VideoListItemState();
}

class _VideoListItemState extends State<VideoListItem> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: widget.thumbnailUrl != null
            ? Image.network(widget.thumbnailUrl!, width: 60, height: 60, fit: BoxFit.cover)
            : const Icon(Icons.video_library, size: 40),
        title: Text(widget.title),
        subtitle: _controller != null && _controller!.value.isInitialized
            ? VideoPlayer(_controller!)
            : null,
        trailing: IconButton(
          icon: Icon(_controller != null && _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            setState(() {
              if (_controller!.value.isPlaying) {
                _controller!.pause();
              } else {
                _controller!.play();
              }
            });
          },
        ),
      ),
    );
  }
}
