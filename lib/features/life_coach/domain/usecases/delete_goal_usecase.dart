import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/life_coach/domain/repositories/goals_repository.dart';

class DeleteGoalUseCase {
  final GoalsRepository _repository;

  DeleteGoalUseCase(this._repository);

  Future<Result<void>> call(String goalId) async {
    return await _repository.deleteGoal(goalId);
  }
}
