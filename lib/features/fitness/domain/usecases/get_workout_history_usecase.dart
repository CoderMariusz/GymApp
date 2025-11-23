import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:lifeos/features/fitness/domain/repositories/workout_log_repository.dart';

/// Use case for getting workout history
class GetWorkoutHistoryUseCase {
  final WorkoutLogRepository _repository;

  GetWorkoutHistoryUseCase(this._repository);

  Future<Result<List<WorkoutLogEntity>>> call(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (startDate != null && endDate != null) {
      return await _repository.getWorkoutLogsInRange(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
    }

    return await _repository.getAllWorkoutLogs(userId);
  }
}
