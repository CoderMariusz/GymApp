import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:gymapp/features/fitness/domain/repositories/workout_log_repository.dart';

/// Use case for creating a workout log with sets
class CreateWorkoutLogUseCase {
  final WorkoutLogRepository _repository;

  CreateWorkoutLogUseCase(this._repository);

  Future<Result<WorkoutLogEntity>> call(WorkoutLogEntity workoutLog) async {
    // If workout has sets, create with transaction
    if (workoutLog.sets.isNotEmpty) {
      return await _repository.createWorkoutLogWithSets(
        workoutLog,
        workoutLog.sets,
      );
    }

    // Otherwise just create the workout log
    return await _repository.createWorkoutLog(workoutLog);
  }
}
