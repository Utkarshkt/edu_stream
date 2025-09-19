import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminUploadPage extends StatefulWidget {
  @override
  _AdminUploadPageState createState() => _AdminUploadPageState();
}

class _AdminUploadPageState extends State<AdminUploadPage> {
  File? _video;

  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _video = File(picked.path);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_video == null) return;
    // TODO: Send multipart request to backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Video")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _video == null
                ? Text("No video selected")
                : Text("Selected: ${_video!.path}"),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text("Pick Video from Gallery"),
            ),
            ElevatedButton(
              onPressed: _uploadVideo,
              child: Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
