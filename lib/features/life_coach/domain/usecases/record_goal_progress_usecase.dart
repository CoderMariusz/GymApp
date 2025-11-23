import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/life_coach/domain/repositories/goals_repository.dart';

class RecordGoalProgressUseCase {
  final GoalsRepository _repository;

  RecordGoalProgressUseCase(this._repository);

  Future<Result<void>> call(String goalId, double value, String? notes) async {
    return await _repository.recordProgress(goalId, value, notes);
  }
}
