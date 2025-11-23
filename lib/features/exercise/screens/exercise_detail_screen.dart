import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../providers/exercise_providers.dart';

/// Screen displaying detailed information about a specific exercise
class ExerciseDetailScreen extends ConsumerWidget {
  final String exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(allExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              // TODO: Toggle favorite
            },
          ),
        ],
      ),
      body: exercisesAsync.when(
        data: (exercises) {
          final exercise = exercises.firstWhere(
            (e) => e.id == exerciseId,
            orElse: () => Exercise(
              id: exerciseId,
              name: 'Exercise not found',
              category: 'Unknown',
              primaryMuscles: [],
              secondaryMuscles: [],
              instructions: [],
              isCustom: false,
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise name
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),

                // Category
                Chip(label: Text(exercise.category)),
                const SizedBox(height: 16),

                // Primary muscles
                if (exercise.primaryMuscles.isNotEmpty) ...[
                  Text(
                    'Primary Muscles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: exercise.primaryMuscles
                        .map((muscle) => Chip(label: Text(muscle)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Secondary muscles
                if (exercise.secondaryMuscles.isNotEmpty) ...[
                  Text(
                    'Secondary Muscles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: exercise.secondaryMuscles
                        .map((muscle) => Chip(label: Text(muscle)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Instructions
                if (exercise.instructions.isNotEmpty) ...[
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...exercise.instructions.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${entry.key + 1}. '),
                              Expanded(child: Text(entry.value)),
                            ],
                          ),
                        ),
                      ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading exercise: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
