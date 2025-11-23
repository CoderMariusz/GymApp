import 'package:flutter/material.dart';

class CreateCustomExerciseScreen extends StatelessWidget {
  const CreateCustomExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Exercise')),
      body: const Center(child: Text('Create Custom Exercise')),
    );
  }
}
