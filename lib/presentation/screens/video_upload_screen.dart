import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course.dart';
import '../providers/video_provider.dart';


class VideoUploadScreen extends ConsumerStatefulWidget {
  final Course? course;

  const VideoUploadScreen({super.key, this.course});

  @override
  ConsumerState<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends ConsumerState<VideoUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  String? _videoFilePath;
  String? _thumbnailFilePath;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      ref.read(selectedCourseForUploadProvider.notifier).state = widget.course;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    // Simulate video picking (since we don't have actual image_picker)
    setState(() {
      _videoFilePath = '/storage/emulated/0/DCIM/Camera/video_001.mp4';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video selected (simulated)')),
    );
  }

  Future<void> _pickThumbnail() async {
    // Simulate thumbnail picking
    setState(() {
      _thumbnailFilePath = '/storage/emulated/0/DCIM/Camera/thumbnail_001.jpg';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thumbnail selected (simulated)')),
    );
  }

  Future<void> _simulateUpload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_videoFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video file')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Simulate upload progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      ref.read(uploadProgressProvider.notifier).state = i.toDouble();

      if (i == 100) {
        _completeUpload();
      }
    }
  }

  void _completeUpload() {
    final course = ref.read(selectedCourseForUploadProvider);
    if (course == null) return;

    final newVideo = CourseVideo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      duration: _durationController.text,
      videoUrl: 'uploaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      thumbnailUrl: _thumbnailFilePath ?? '',
      isUploaded: true,
      uploadDate: DateTime.now(),
      fileSize: 250.0,
      order: 0,
      isPreview: false,
      uploadedBy: 'admin_user_id',
      status: VideoStatus.ready,
    );

    ref.read(videoUploadProvider.notifier).addVideo(newVideo);

    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video uploaded successfully!')),
    );

    Navigator.pop(context);
  }

  void _cancelUpload() {
    setState(() {
      _isUploading = false;
    });
    ref.read(uploadProgressProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context) {
    final uploadProgress = ref.watch(uploadProgressProvider);
    final selectedCourse = ref.watch(selectedCourseForUploadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          if (_isUploading)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancelUpload,
              tooltip: 'Cancel Upload',
            ),
        ],
      ),
      body: _isUploading
          ? _buildUploadProgress(uploadProgress)
          : _buildUploadForm(selectedCourse, context),
    );
  }

  Widget _buildUploadProgress(double progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Uploading: ${progress.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadForm(Course? selectedCourse, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedCourse != null) ...[
              _buildCourseInfo(selectedCourse),
              const SizedBox(height: 20),
            ],
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Video Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a video title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (e.g., 15:30)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter video duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildFilePicker(
              'Select Video File',
              _videoFilePath ?? 'No video selected',
              _pickVideo,
              Icons.video_library,
            ),
            const SizedBox(height: 16),
            _buildFilePicker(
              'Select Thumbnail (Optional)',
              _thumbnailFilePath ?? 'No thumbnail selected',
              _pickThumbnail,
              Icons.image,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _simulateUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upload Video',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseInfo(Course course) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: course.colors),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                course.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uploading to:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(String title, String filePath, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filePath,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}