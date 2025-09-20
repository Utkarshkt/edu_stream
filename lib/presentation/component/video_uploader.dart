import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/services/video_service.dart';

class VideoUploader extends ConsumerStatefulWidget {
  final String courseId;

  const VideoUploader({super.key, required this.courseId});

  @override
  ConsumerState<VideoUploader> createState() => _VideoUploaderState();
}

class _VideoUploaderState extends ConsumerState<VideoUploader> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  String? _videoPath;
  String? _thumbnailPath;
  double _uploadProgress = 0;
  bool _isUploading = false;

  Future<void> _pickFile(bool isVideo) async {
    final result = await FilePicker.platform.pickFiles(
      type: isVideo ? FileType.video : FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        if (isVideo) {
          _videoPath = result.files.single.path;
        } else {
          _thumbnailPath = result.files.single.path;
        }
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoPath == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final videoService = VideoService();
      final response = await videoService.uploadVideo(
        File(_videoPath!),
        title: _titleController.text,
        description: _descriptionController.text,
        duration: _durationController.text,
        courseId: widget.courseId,
        thumbnailFile: _thumbnailPath != null ? File(_thumbnailPath!) : null,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (mm:ss)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickFile(true),
              child: const Text('Select Video'),
            ),
            ElevatedButton(
              onPressed: () => _pickFile(false),
              child: const Text('Select Thumbnail'),
            ),
            if (_isUploading) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(value: _uploadProgress / 100),
              Text('Uploading: ${_uploadProgress.toStringAsFixed(1)}%'),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadVideo,
              child: const Text('Upload Video'),
            ),
          ],
        ),
      ),
    );
  }
}