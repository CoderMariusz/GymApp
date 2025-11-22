// Story 3.2: Exercise Detail Screen
// AC4: Exercise details: Name, category, muscle groups, instructions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../providers/exercise_providers.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseDetailProvider(exerciseId));
    final isFavoritedAsync = ref.watch(isExerciseFavoritedProvider(exerciseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
        actions: [
          // Favorite button
          isFavoritedAsync.when(
            data: (isFavorited) => IconButton(
              icon: Icon(
                isFavorited ? Icons.star : Icons.star_border,
                color: isFavorited ? Colors.amber : null,
              ),
              onPressed: () async {
                await ref.read(favoriteToggleProvider(exerciseId).notifier).toggle();
                // Refresh state
                ref.invalidate(isExerciseFavoritedProvider(exerciseId));
                ref.invalidate(favoriteExercisesProvider);
              },
              tooltip: isFavorited ? 'Remove from favorites' : 'Add to favorites',
            ),
            loading: () => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: exerciseAsync.when(
        data: (exercise) => _buildExerciseDetails(context, exercise),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildExerciseDetails(BuildContext context, Exercise exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Custom badge
          if (exercise.isCustom) ...[
            Chip(
              label: const Text('Custom Exercise'),
              backgroundColor: Colors.blue[100],
              avatar: const Icon(Icons.person, size: 18),
            ),
            const SizedBox(height: 16),
          ],

          // Info cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  'Category',
                  exercise.primaryCategory,
                  Icons.category,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(
                  context,
                  'Equipment',
                  exercise.equipmentName,
                  Icons.fitness_center,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            context,
            'Difficulty',
            exercise.difficultyName,
            Icons.trending_up,
            _getDifficultyColor(exercise.difficulty),
          ),
          const SizedBox(height: 24),

          // Description
          if (exercise.description != null) ...[
            _buildSectionTitle(context, 'Description'),
            const SizedBox(height: 8),
            Text(
              exercise.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
          ],

          // Muscle groups
          _buildSectionTitle(context, 'Muscle Groups'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: exercise.muscleGroups.map((muscle) {
              return Chip(
                label: Text(muscle),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Instructions
          if (exercise.instructions != null) ...[
            _buildSectionTitle(context, 'Instructions'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                exercise.instructions!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Video (placeholder for AC8 - P1)
          if (exercise.videoUrl != null) ...[
            _buildSectionTitle(context, 'Video Tutorial'),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline, size: 64),
                    SizedBox(height: 8),
                    Text('Video player coming soon'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return Colors.green;
      case ExerciseDifficulty.intermediate:
        return Colors.orange;
      case ExerciseDifficulty.advanced:
        return Colors.red;
    }
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load exercise',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
