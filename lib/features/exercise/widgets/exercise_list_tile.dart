// Story 3.2: Exercise List Tile Widget
// Displays exercise in list with favorite button
//
// AC4: Exercise details: Name, category, muscle groups, instructions
// AC7: Favorite exercises (star icon) → Quick access

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../providers/exercise_providers.dart';

class ExerciseListTile extends ConsumerWidget {
  const ExerciseListTile({
    super.key,
    required this.exercise,
    required this.onTap,
    this.showCustomBadge = false,
  });

  final Exercise exercise;
  final VoidCallback onTap;
  final bool showCustomBadge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(isExerciseFavoritedProvider(exercise.id));

    return ListTile(
      leading: _buildExerciseIcon(),
      title: Row(
        children: [
          Expanded(
            child: Text(
              exercise.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (showCustomBadge || exercise.isCustom) ...[
            const SizedBox(width: 8),
            Chip(
              label: const Text('Custom', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.blue[100],
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and equipment
          Text(
            '${exercise.primaryCategory} • ${exercise.equipmentName}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          // Muscle groups
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: exercise.muscleGroups.take(3).map((muscle) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  muscle,
                  style: const TextStyle(fontSize: 10),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      trailing: isFavorited.when(
        data: (favorited) => IconButton(
          icon: Icon(
            favorited ? Icons.star : Icons.star_border,
            color: favorited ? Colors.amber : Colors.grey,
          ),
          onPressed: () async {
            // Toggle favorite (AC7)
            await ref.read(favoriteToggleProvider(exercise.id).notifier).toggle();

            // Invalidate favorites list to refresh
            ref.invalidate(favoriteExercisesProvider);
          },
        ),
        loading: () => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (_, __) => const Icon(Icons.star_border, color: Colors.grey),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      isThreeLine: true,
    );
  }

  Widget _buildExerciseIcon() {
    // Get icon based on equipment
    IconData icon;
    Color iconColor;

    switch (exercise.equipment) {
      case EquipmentType.barbell:
        icon = Icons.fitness_center;
        iconColor = Colors.blue;
        break;
      case EquipmentType.dumbbell:
        icon = Icons.fitness_center;
        iconColor = Colors.green;
        break;
      case EquipmentType.machine:
        icon = Icons.settings;
        iconColor = Colors.purple;
        break;
      case EquipmentType.bodyweight:
        icon = Icons.accessibility_new;
        iconColor = Colors.orange;
        break;
      case EquipmentType.cable:
        icon = Icons.cable;
        iconColor = Colors.teal;
        break;
      case EquipmentType.other:
        icon = Icons.more_horiz;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}
