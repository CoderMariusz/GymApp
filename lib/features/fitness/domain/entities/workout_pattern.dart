import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout_log.dart';

part 'workout_pattern.freezed.dart';

/// Represents a detected workout pattern for an exercise
@freezed
sealed class WorkoutPattern with _$WorkoutPattern {
  const factory WorkoutPattern({
    required String exerciseName,
    required int averageSets,
    required int averageReps,
    required double lastWeight,
    required double suggestedWeight,
    required int averageRestSeconds,
    required DateTime lastPerformed,
    required int performanceCount,  // How many times this exercise was done
    double? averageRpe,
    String? progressionReason,  // Why we suggest this weight
  }) = _WorkoutPattern;
}

/// Represents a prefilled suggestion for a workout
@freezed
sealed class WorkoutSuggestion with _$WorkoutSuggestion {
  const factory WorkoutSuggestion({
    required String exerciseName,
    required List<SuggestedSet> sets,
    required String rationale,  // AI explanation for the suggestion
    @Default(false) bool isProgressiveOverload,
  }) = _WorkoutSuggestion;
}

/// Individual set suggestion
@freezed
sealed class SuggestedSet with _$SuggestedSet {
  const factory SuggestedSet({
    required double weight,
    required int reps,
    required int restSeconds,
    double? targetRpe,
    String? note,  // e.g., "Increase from last time", "Deload recommended"
  }) = _SuggestedSet;
}

/// Progressive overload strategy
enum OverloadStrategy {
  increaseWeight,   // Same reps, more weight
  increaseReps,     // Same weight, more reps
  increaseVolume,   // More sets
  maintain,         // Keep same (recovery)
  deload,          // Reduce intensity (RPE was too high)
}
