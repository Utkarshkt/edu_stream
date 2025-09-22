import 'dart:io';
import 'dart:math'; // ADD THIS IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../providers/video_provider.dart'; // MAKE SURE THIS PATH IS CORRECT

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
      // Store context locally to avoid async gap
      final currentContext = context;
      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
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
      // Store context locally to avoid async gap
      final currentContext = context;
      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
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
      // Store context locally to avoid async gap
      final currentContext = context;
      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Please select a video first')),
      );
      return;
    }

    if (_titleController.text.isEmpty) {
      // Store context locally to avoid async gap
      final currentContext = context;
      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final videoProvider = ref.read(videoProviderProvider);

      final response = await videoProvider.uploadVideo(
        videoFile: _selectedVideo!,
        thumbnailFile: _selectedThumbnail,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
      );

      if (!mounted) return;

      // Store context locally to avoid async gap
      final currentContext = context;
      if (response.success) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.message}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Store context locally to avoid async gap
      final currentContext = context;
      ScaffoldMessenger.of(currentContext).showSnackBar(
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
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const List<String> suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Upload Video'),
        backgroundColor: Colors.blue[700], // FIXED: Changed 709 to 700
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
                    onPressed: _pickVideo,
                    child: const Text('Change Video'),
                  ),
                  const SizedBox(width: 12),
                  if (_videoController != null)
                    IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: () {
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
                onPressed: _pickVideo,
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
                    onPressed: _pickThumbnail,
                    child: const Text('Change Thumbnail'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
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
                onPressed: _pickThumbnail,
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
              onChanged: (value) {
                if (value != null) {
                  _categoryController.text = value;
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
          ? const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(width: 12),
          Text('Uploading...', style: TextStyle(fontSize: 16)),
        ],
      )
          : const Text(
        'Upload Video',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}