import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/life_coach/domain/entities/goal_entity.dart';
import 'package:gymapp/features/life_coach/domain/repositories/goals_repository.dart';

class UpdateGoalUseCase {
  final GoalsRepository _repository;

  UpdateGoalUseCase(this._repository);

  Future<Result<GoalEntity>> call(GoalEntity goal) async {
    return await _repository.updateGoal(goal);
  }
}
