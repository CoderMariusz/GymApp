import 'package:flutter/material.dart';
import 'package:lifeos/features/mind_emotion/presentation/screens/meditation_library_screen.dart';

/// Main application widget
class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeOS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MeditationLibraryScreen(),
    );
  }
}
