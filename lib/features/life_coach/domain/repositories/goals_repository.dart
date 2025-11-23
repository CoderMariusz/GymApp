import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/life_coach/domain/entities/goal_entity.dart';

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

// Temporary mock implementation - will be replaced when Epic 2 stories are implemented
class MockGoalsRepository implements GoalsRepository {
  @override
  Future<Result<GoalEntity>> createGoal(GoalEntity goal) async {
    return Result.success(goal);
  }

  @override
  Future<Result<GoalEntity>> getGoalById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<GoalEntity>>> getAllGoals(String userId) async {
    return Result.success([]);
  }

  @override
  Future<Result<List<GoalEntity>>> getActiveGoals(String userId) async {
    // Return empty list for now - will be populated when Epic 2 is implemented
    return Result.success([]);
  }

  @override
  Future<Result<List<GoalEntity>>> getCompletedGoals(String userId) async {
    return Result.success([]);
  }

  @override
  Future<Result<List<GoalEntity>>> getGoalsByCategory(String userId, String category) async {
    return Result.success([]);
  }

  @override
  Future<Result<GoalEntity>> updateGoal(GoalEntity goal) async {
    return Result.success(goal);
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> archiveGoal(String id) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> recordProgress(String goalId, double value, String? notes) async {
    return Result.success(null);
  }

  @override
  Future<Result<double>> getProgressPercentage(String goalId) async {
    return Result.success(0.0);
  }
}
