import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_set_entity.freezed.dart';

/// Exercise set entity for individual workout sets
@freezed
class ExerciseSetEntity with _$ExerciseSetEntity {
  const factory ExerciseSetEntity({
    required String id,
    required String workoutLogId,
    required String exerciseName,
    required int setNumber,
    double? weight, // kg or lbs
    int? reps,
    int? duration, // seconds, for timed exercises (planks, etc.)
    int? restTime, // seconds
    String? notes,
    required DateTime createdAt,
  }) = _ExerciseSetEntity;

  const ExerciseSetEntity._();

  /// Whether this is a timed exercise (like plank)
  bool get isTimedExercise => duration != null && duration! > 0;

  /// Whether this is a weighted exercise
  bool get isWeightedExercise => weight != null && weight! > 0;

  /// Get volume for this set (weight * reps)
  double get volume {
    if (weight == null || reps == null) return 0.0;
    return weight! * reps!;
  }

  /// Get formatted set description
  String get description {
    if (isTimedExercise) {
      final minutes = duration! ~/ 60;
      final seconds = duration! % 60;
      return '${minutes}m ${seconds}s';
    } else if (isWeightedExercise) {
      return '${weight!.toStringAsFixed(1)}kg × ${reps ?? 0} reps';
    } else {
      return '${reps ?? 0} reps';
    }
  }
}
