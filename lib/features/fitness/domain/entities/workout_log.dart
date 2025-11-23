import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_log.freezed.dart';

@freezed
class WorkoutSet with _$WorkoutSet {
  const factory WorkoutSet({
    required double weight,
    required int reps,
    required int restSeconds,
    double? rpe,  // Rate of Perceived Exertion (1-10)
  }) = _WorkoutSet;
}

@freezed
class ExerciseLog with _$ExerciseLog {
  const factory ExerciseLog({
    required String name,
    required List<WorkoutSet> sets,
    required DateTime date,
  }) = _ExerciseLog;
}

@freezed
class WorkoutLog with _$WorkoutLog {
  const factory WorkoutLog({
    required String id,
    required DateTime date,
    required List<ExerciseLog> exercises,
    required int totalDurationMinutes,
  }) = _WorkoutLog;
}

@freezed
class PersonalRecord with _$PersonalRecord {
  const factory PersonalRecord({
    required String exerciseName,
    required double weight,
    required DateTime date,
  }) = _PersonalRecord;
}
