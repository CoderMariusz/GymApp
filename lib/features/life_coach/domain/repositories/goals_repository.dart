import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/life_coach/domain/entities/goal_entity.dart';

/// Repository interface for goals operations
abstract class GoalsRepository {
  Future<Result<GoalEntity>> createGoal(GoalEntity goal);
  Future<Result<GoalEntity>> getGoalById(String id);
  Future<Result<List<GoalEntity>>> getAllGoals(String userId);
  Future<Result<List<GoalEntity>>> getActiveGoals(String userId);
  Future<Result<List<GoalEntity>>> getCompletedGoals(String userId);
  Future<Result<List<GoalEntity>>> getGoalsByCategory(String userId, String category);
  Future<Result<GoalEntity>> updateGoal(GoalEntity goal);
  Future<Result<void>> deleteGoal(String id);
  Future<Result<void>> archiveGoal(String id);
  Future<Result<void>> recordProgress(String goalId, double value, String? notes);
  Future<Result<double>> getProgressPercentage(String goalId);
}
