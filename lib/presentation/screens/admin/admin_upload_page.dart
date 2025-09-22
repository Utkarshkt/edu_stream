import 'dart:io';
import 'dart:math' as math; // FIXED: Added 'as math' to avoid conflict
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../data/services/video_service.dart';

class AdminUploadPage extends ConsumerStatefulWidget {
  const AdminUploadPage({super.key});

  @override
  ConsumerState<AdminUploadPage> createState() => _AdminUploadPageState();
}

class _AdminUploadPageState extends ConsumerState<AdminUploadPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedVideo;
  File? _selectedThumbnail;
  VideoPlayerController? _videoController;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final List<String> _categories = [
    'Mathematics',
    'Science',
    'History',
    'Literature',
    'Programming',
    'Arts',
    'Languages',
    'Business'
  ];

  @override
  void initState() {
    super.initState();
    _categoryController.text = _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 30),
      );

      if (video != null) {
        setState(() {
          _selectedVideo = File(video.path);
        });
        _initializeVideoPlayer();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedThumbnail = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking thumbnail: $e')),
      );
    }
  }

  void _initializeVideoPlayer() {
    if (_selectedVideo != null) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(_selectedVideo!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first')),
      );
      return;
    }

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // **USE BACKEND API DIRECTLY** - Simple fix
      final videoService = VideoService();

      final result = await videoService.uploadVideoWithProgress(
        videoFile: _selectedVideo!,
        title: _titleController.text,
        description: _descriptionController.text,
        durationInSeconds: 0, // You can calculate this later
        courseId: _categoryController.text, // Using category as courseId
        thumbnailFile: _selectedThumbnail,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
      );

      if (!mounted) return;

      // Check if upload was successful
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${result['message']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedVideo = null;
      _selectedThumbnail = null;
      _titleController.clear();
      _descriptionController.clear();
      _categoryController.text = _categories.first;
      _videoController?.dispose();
      _videoController = null;
      _uploadProgress = 0.0; // ADDED: Reset progress
    });
  }

  // FIXED: Corrected _formatFileSize function
  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (math.log(bytes) / math.log(1024)).floor();

    return '${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Alternative simpler version (if you prefer):
  /*
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Upload Video'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  '${(_uploadProgress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Selection
            _buildVideoSelectionSection(),
            const SizedBox(height: 24),

            // Thumbnail Selection
            _buildThumbnailSection(),
            const SizedBox(height: 24),

            // Video Details Form
            _buildVideoDetailsForm(),
            const SizedBox(height: 32),

            // Upload Button
            _buildUploadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_selectedVideo != null) ...[
              if (_videoController != null && _videoController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              const SizedBox(height: 12),
              Text(
                'Selected: ${_selectedVideo!.path.split('/').last}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Size: ${_formatFileSize(_selectedVideo!.lengthSync())}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _isUploading ? null : _pickVideo, // ADDED: Disable when uploading
                    child: const Text('Change Video'),
                  ),
                  const SizedBox(width: 12),
                  if (_videoController != null && _videoController!.value.isInitialized)
                    IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: _isUploading ? null : () { // ADDED: Disable when uploading
                        setState(() {
                          _videoController!.value.isPlaying
                              ? _videoController!.pause()
                              : _videoController!.play();
                        });
                      },
                    ),
                ],
              ),
            ] else
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickVideo, // ADDED: Disable when uploading
                icon: const Icon(Icons.video_library),
                label: const Text('Select Video'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thumbnail (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_selectedThumbnail != null) ...[
              Image.file(
                _selectedThumbnail!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _isUploading ? null : _pickThumbnail, // ADDED: Disable when uploading
                    child: const Text('Change Thumbnail'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _isUploading ? null : () { // ADDED: Disable when uploading
                      setState(() {
                        _selectedThumbnail = null;
                      });
                    },
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ] else
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickThumbnail, // ADDED: Disable when uploading
                icon: const Icon(Icons.image),
                label: const Text('Select Thumbnail'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoDetailsForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
                filled: true,
              ),
              maxLength: 100,
              enabled: !_isUploading, // ADDED: Disable when uploading
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoryController.text,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
                filled: true,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: _isUploading ? null : (value) { // ADDED: Disable when uploading
                if (value != null) {
                  setState(() {
                    _categoryController.text = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                filled: true,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
              enabled: !_isUploading, // ADDED: Disable when uploading
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: _isUploading ? null : _uploadVideo,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isUploading
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: _uploadProgress, // ADDED: Show progress value
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Text(
            'Uploading... ${(_uploadProgress * 100).toStringAsFixed(1)}%', // IMPROVED: Show percentage
            style: const TextStyle(fontSize: 16),
          ),
        ],
      )
          : const Text(
        'Upload Video',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}