import 'package:flutter/material.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Details')),
      body: Center(child: Text('Exercise: $exerciseId')),
    );
  }
}
