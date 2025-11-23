import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:lifeos/features/fitness/domain/entities/exercise_set_entity.dart';

/// Repository interface for workout log operations
abstract class WorkoutLogRepository {
  /// Create a new workout log
  Future<Result<WorkoutLogEntity>> createWorkoutLog(WorkoutLogEntity workoutLog);

  /// Create a workout log with sets (transaction)
  Future<Result<WorkoutLogEntity>> createWorkoutLogWithSets(
    WorkoutLogEntity workoutLog,
    List<ExerciseSetEntity> sets,
  );

  /// Get workout log by ID
  Future<Result<WorkoutLogEntity>> getWorkoutLogById(String id);

  /// Get all workout logs for a user
  Future<Result<List<WorkoutLogEntity>>> getAllWorkoutLogs(String userId);

  /// Get workout logs for a specific date
  Future<Result<List<WorkoutLogEntity>>> getWorkoutLogsForDate(
    String userId,
    DateTime date,
  );

  /// Get workout logs for a date range
  Future<Result<List<WorkoutLogEntity>>> getWorkoutLogsInRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update a workout log
  Future<Result<WorkoutLogEntity>> updateWorkoutLog(WorkoutLogEntity workoutLog);

  /// Delete a workout log
  Future<Result<void>> deleteWorkoutLog(String id);

  /// Get exercise sets for a workout log
  Future<Result<List<ExerciseSetEntity>>> getSetsForWorkout(String workoutLogId);

  /// Add exercise set to workout
  Future<Result<ExerciseSetEntity>> addExerciseSet(ExerciseSetEntity set);

  /// Update exercise set
  Future<Result<ExerciseSetEntity>> updateExerciseSet(ExerciseSetEntity set);

  /// Delete exercise set
  Future<Result<void>> deleteExerciseSet(String setId);

  /// Get workout statistics for a user
  Future<Result<WorkoutStats>> getWorkoutStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Workout statistics
class WorkoutStats {
  final int totalWorkouts;
  final int totalSets;
  final double totalVolume; // weight * reps
  final int totalDuration; // seconds
  final Map<String, int> exerciseCounts; // exercise name -> count

  WorkoutStats({
    required this.totalWorkouts,
    required this.totalSets,
    required this.totalVolume,
    required this.totalDuration,
    required this.exerciseCounts,
  });

  double get averageWorkoutDuration =>
      totalWorkouts > 0 ? totalDuration / totalWorkouts : 0;

  double get averageSetsPerWorkout =>
      totalWorkouts > 0 ? totalSets / totalWorkouts : 0;
}
