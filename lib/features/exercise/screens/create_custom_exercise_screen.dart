import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen for creating custom exercises
class CreateCustomExerciseScreen extends ConsumerStatefulWidget {
  const CreateCustomExerciseScreen({super.key});

  @override
  ConsumerState<CreateCustomExerciseScreen> createState() =>
      _CreateCustomExerciseScreenState();
}

class _CreateCustomExerciseScreenState
    extends ConsumerState<CreateCustomExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedCategory = 'Other';
  final List<String> _categories = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Exercise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'e.g., Bulgarian Split Squat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Instructions field
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions (Optional)',
                  hintText: 'Enter instructions for this exercise',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExercise,
                  child: const Text('Create Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save custom exercise to database
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom exercise created successfully!')),
      );
      Navigator.of(context).pop();
    }
  }
}
