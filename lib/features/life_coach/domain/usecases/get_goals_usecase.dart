import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/life_coach/domain/entities/goal_entity.dart';
import 'package:lifeos/features/life_coach/domain/repositories/goals_repository.dart';

class GetGoalsUseCase {
  final GoalsRepository _repository;

  GetGoalsUseCase(this._repository);

  Future<Result<List<GoalEntity>>> call(String userId, {bool activeOnly = false}) async {
    if (activeOnly) {
      return await _repository.getActiveGoals(userId);
    }
    return await _repository.getAllGoals(userId);
  }
}
