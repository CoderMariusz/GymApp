import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/features/fitness/domain/entities/exercise_set_entity.dart';

part 'workout_log_entity.freezed.dart';

/// Workout log entity for tracking workouts
@freezed
class WorkoutLogEntity with _$WorkoutLogEntity {
  const factory WorkoutLogEntity({
    required String id,
    required String userId,
    required DateTime timestamp,
    required String workoutName,
    @Default(0) int duration, // seconds
    String? notes,
    @Default(false) bool isQuickLog,
    @Default([]) List<ExerciseSetEntity> sets,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isSynced,
  }) = _WorkoutLogEntity;

  const WorkoutLogEntity._();

  /// Get total number of sets
  int get totalSets => sets.length;

  /// Get total volume (weight * reps)
  double get totalVolume {
    return sets.fold(0.0, (sum, set) {
      final weight = set.weight ?? 0.0;
      final reps = set.reps ?? 0;
      return sum + (weight * reps);
    });
  }

  /// Get unique exercises count
  int get uniqueExercises {
    return sets.map((set) => set.exerciseName).toSet().length;
  }

  /// Get formatted duration string
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
