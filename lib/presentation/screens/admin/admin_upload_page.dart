import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../video_upload_screen.dart';

class AdminUploadPage extends ConsumerWidget {
  const AdminUploadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const VideoUploadScreen();
  }
}