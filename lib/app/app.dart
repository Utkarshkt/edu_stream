import 'package:edu_stream/app/route_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class EduStreamApp extends ConsumerWidget {
  const EduStreamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'EduStream',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}