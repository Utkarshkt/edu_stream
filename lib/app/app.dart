import 'package:edu_stream/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/screens/home_screen.dart';
import 'theme.dart';

class EduStreamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduStream',
      theme: appTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}