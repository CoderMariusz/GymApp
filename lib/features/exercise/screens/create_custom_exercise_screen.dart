// Story 3.2: Create Custom Exercise Screen
// AC5: User can add custom exercises
// AC6: Custom exercises saved to user's library

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../models/exercise_exceptions.dart';
import '../providers/exercise_providers.dart';

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
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();

  EquipmentType _selectedEquipment = EquipmentType.bodyweight;
  ExerciseDifficulty _selectedDifficulty = ExerciseDifficulty.beginner;
  final Set<String> _selectedMuscleGroups = {};

  bool _isLoading = false;
  String? _errorMessage;

  // Available muscle groups
  static const List<String> _availableMuscleGroups = [
    'chest',
    'back',
    'lats',
    'traps',
    'shoulders',
    'front delts',
    'side delts',
    'rear delts',
    'biceps',
    'triceps',
    'forearms',
    'quads',
    'hamstrings',
    'glutes',
    'calves',
    'core',
    'abs',
    'obliques',
    'lower abs',
    'cardio',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Exercise name (required, max 100 chars)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name *',
                hintText: 'e.g., Custom Push-ups',
                border: OutlineInputBorder(),
                helperText: 'Required, max 100 characters',
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter exercise name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description (optional, max 500 chars)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of the exercise',
                border: OutlineInputBorder(),
                helperText: 'Optional, max 500 characters',
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Equipment type
            DropdownButtonFormField<EquipmentType>(
              value: _selectedEquipment,
              decoration: const InputDecoration(
                labelText: 'Equipment *',
                border: OutlineInputBorder(),
              ),
              items: EquipmentType.values.map((equipment) {
                return DropdownMenuItem(
                  value: equipment,
                  child: Text(_getEquipmentName(equipment)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEquipment = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Difficulty
            DropdownButtonFormField<ExerciseDifficulty>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty *',
                border: OutlineInputBorder(),
              ),
              items: ExerciseDifficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(_getDifficultyName(difficulty)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Muscle groups (at least one required)
            Text(
              'Muscle Groups *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select at least one muscle group',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableMuscleGroups.map((muscle) {
                final isSelected = _selectedMuscleGroups.contains(muscle);
                return FilterChip(
                  label: Text(muscle),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMuscleGroups.add(muscle);
                      } else {
                        _selectedMuscleGroups.remove(muscle);
                      }
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                );
              }).toList(),
            ),
            if (_selectedMuscleGroups.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Please select at least one muscle group',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
              ),
            ],
            const SizedBox(height: 16),

            // Instructions (optional, max 2000 chars)
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                hintText: 'Step-by-step instructions for performing this exercise',
                border: OutlineInputBorder(),
                helperText: 'Optional, max 2000 characters',
              ),
              maxLines: 8,
              maxLength: 2000,
            ),
            const SizedBox(height: 24),

            // Create button
            ElevatedButton(
              onPressed: _isLoading ? null : _createExercise,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Create Exercise',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createExercise() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate muscle groups
    if (_selectedMuscleGroups.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one muscle group';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create custom exercise using repository
      await ref.read(customExerciseCreationProvider.notifier).createCustomExercise(
            name: _nameController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            muscleGroups: _selectedMuscleGroups.toList(),
            equipment: _selectedEquipment,
            difficulty: _selectedDifficulty,
            instructions: _instructionsController.text.isEmpty
                ? null
                : _instructionsController.text,
          );

      // Invalidate providers to refresh lists
      ref.invalidate(customExercisesProvider);
      ref.invalidate(allExercisesProvider);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom exercise created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      }
    } on ValidationException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } on AuthenticationException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create exercise: $e';
        _isLoading = false;
      });
    }
  }

  String _getEquipmentName(EquipmentType equipment) {
    switch (equipment) {
      case EquipmentType.barbell:
        return 'Barbell';
      case EquipmentType.dumbbell:
        return 'Dumbbell';
      case EquipmentType.machine:
        return 'Machine';
      case EquipmentType.bodyweight:
        return 'Bodyweight';
      case EquipmentType.cable:
        return 'Cable';
      case EquipmentType.other:
        return 'Other';
    }
  }

  String _getDifficultyName(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 'Beginner';
      case ExerciseDifficulty.intermediate:
        return 'Intermediate';
      case ExerciseDifficulty.advanced:
        return 'Advanced';
    }
  }
}
