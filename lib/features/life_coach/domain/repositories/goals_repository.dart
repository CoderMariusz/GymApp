import '../entities/goal.dart';

abstract class GoalsRepository {
  Future<List<Goal>> getAllGoals();
  Future<List<Goal>> getActiveGoals();
  Future<int> getOverallProgress();
  Future<List<Goal>> getCompletedGoals({required int days});
}

// Temporary mock implementation - will be replaced when Story 2.1/2.3 are implemented
class MockGoalsRepository implements GoalsRepository {
  @override
  Future<List<Goal>> getAllGoals() async {
    return [];
  }

  @override
  Future<List<Goal>> getActiveGoals() async {
    // Return sample goals for AI context
    return [
      Goal(
        id: '1',
        title: 'Lose 5kg weight',
        description: 'Reduce weight through diet and exercise',
        category: GoalCategory.fitness,
        status: GoalStatus.active,
        targetDate: DateTime.now().add(const Duration(days: 60)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Goal(
        id: '2',
        title: 'Run 5km without stopping',
        description: 'Build cardio endurance',
        category: GoalCategory.fitness,
        status: GoalStatus.active,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<int> getOverallProgress() async {
    return 65; // 65% progress
  }

  @override
  Future<List<Goal>> getCompletedGoals({required int days}) async {
    return [];
  }
}
