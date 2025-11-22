import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:gymapp/features/fitness/domain/repositories/workout_log_repository.dart';

/// Use case for quick logging a workout (simplified entry)
class QuickLogWorkoutUseCase {
  final WorkoutLogRepository _repository;

  QuickLogWorkoutUseCase(this._repository);

  Future<Result<WorkoutLogEntity>> call(WorkoutLogEntity workoutLog) async {
    // Validate it's marked as quick log
    if (!workoutLog.isQuickLog) {
      return Result.failure(
        ValidationFailure('Workout must be marked as quick log'),
      );
    }

    // Create workout log with sets
    return await _repository.createWorkoutLogWithSets(
      workoutLog,
      workoutLog.sets,
    );
  }
}

class ValidationFailure implements Failure {
  final String message;

  ValidationFailure(this.message);

  @override
  String toString() => message;
}
