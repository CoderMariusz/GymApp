import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/core/error/failures.dart';
import 'package:lifeos/features/life_coach/data/models/goal_model.dart';
import 'package:lifeos/features/life_coach/domain/entities/goal_entity.dart';
import 'package:lifeos/features/life_coach/domain/repositories/goals_repository.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  final AppDatabase _database;

  GoalsRepositoryImpl(this._database);

  @override
  Future<Result<GoalEntity>> createGoal(GoalEntity goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      await _database.into(_database.goals).insert(model.toDriftCompanion());
      return Result.success(goal);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create goal: $e'));
    }
  }

  @override
  Future<Result<GoalEntity>> getGoalById(String id) async {
    try {
      final row = await (_database.select(_database.goals)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      if (row == null) {
        return Result.failure(DatabaseFailure('Goal not found'));
      }

      return Result.success(GoalModel.fromDrift(row).toEntity());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get goal: $e'));
    }
  }

  @override
  Future<Result<List<GoalEntity>>> getAllGoals(String userId) async {
    try {
      final rows = await (_database.select(_database.goals)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([
              (tbl) => OrderingTerm(expression: tbl.priority, mode: OrderingMode.desc),
              (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
            ]))
          .get();

      final entities = rows.map((row) => GoalModel.fromDrift(row).toEntity()).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get goals: $e'));
    }
  }

  @override
  Future<Result<List<GoalEntity>>> getActiveGoals(String userId) async {
    try {
      final rows = await (_database.select(_database.goals)
            ..where((tbl) =>
                tbl.userId.equals(userId) &
                tbl.isCompleted.equals(false) &
                tbl.isArchived.equals(false))
            ..orderBy([
              (tbl) => OrderingTerm(expression: tbl.priority, mode: OrderingMode.desc),
            ]))
          .get();

      final entities = rows.map((row) => GoalModel.fromDrift(row).toEntity()).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get active goals: $e'));
    }
  }

  @override
  Future<Result<List<GoalEntity>>> getCompletedGoals(String userId) async {
    try {
      final rows = await (_database.select(_database.goals)
            ..where((tbl) =>
                tbl.userId.equals(userId) &
                tbl.isCompleted.equals(true))
            ..orderBy([
              (tbl) => OrderingTerm(expression: tbl.completedAt, mode: OrderingMode.desc),
            ]))
          .get();

      final entities = rows.map((row) => GoalModel.fromDrift(row).toEntity()).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get completed goals: $e'));
    }
  }

  @override
  Future<Result<List<GoalEntity>>> getGoalsByCategory(String userId, String category) async {
    try {
      final rows = await (_database.select(_database.goals)
            ..where((tbl) =>
                tbl.userId.equals(userId) &
                tbl.category.equals(category) &
                tbl.isArchived.equals(false))
            ..orderBy([
              (tbl) => OrderingTerm(expression: tbl.priority, mode: OrderingMode.desc),
            ]))
          .get();

      final entities = rows.map((row) => GoalModel.fromDrift(row).toEntity()).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get goals by category: $e'));
    }
  }

  @override
  Future<Result<GoalEntity>> updateGoal(GoalEntity goal) async {
    try {
      final model = GoalModel.fromEntity(goal.copyWith(updatedAt: DateTime.now()));
      await (_database.update(_database.goals)
            ..where((tbl) => tbl.id.equals(goal.id)))
          .write(model.toDriftCompanion());

      return Result.success(goal);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update goal: $e'));
    }
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    try {
      await (_database.delete(_database.goals)
            ..where((tbl) => tbl.id.equals(id)))
          .go();

      await (_database.delete(_database.goalProgressTable)
            ..where((tbl) => tbl.goalId.equals(id)))
          .go();

      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete goal: $e'));
    }
  }

  @override
  Future<Result<void>> archiveGoal(String id) async {
    try {
      await (_database.update(_database.goals)
            ..where((tbl) => tbl.id.equals(id)))
          .write(const GoalsCompanion(
            isArchived: Value(true),
            updatedAt: Value.ofDefault(),
          ));

      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to archive goal: $e'));
    }
  }

  @override
  Future<Result<void>> recordProgress(String goalId, double value, String? notes) async {
    try {
      await _database.into(_database.goalProgressTable).insert(
            GoalProgressTableCompanion.insert(
              id: const Value.absent(),
              goalId: goalId,
              timestamp: DateTime.now(),
              value: value,
              notes: Value(notes),
            ),
          );

      final goal = await getGoalById(goalId);
      await goal.when(
        success: (data) async {
          final targetVal = data.targetValue;
          final percentage = data.hasTarget && targetVal != null && targetVal > 0
              ? ((value / targetVal) * 100).clamp(0, 100).round()
              : 0;

          await updateGoal(data.copyWith(
            currentValue: value,
            completionPercentage: percentage,
            isCompleted: percentage >= 100,
            completedAt: percentage >= 100 ? DateTime.now() : null,
          ));
        },
        failure: (_) {},
      );

      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to record progress: $e'));
    }
  }

  @override
  Future<Result<double>> getProgressPercentage(String goalId) async {
    final result = await getGoalById(goalId);
    return result.when(
      success: (data) => Result.success(data.progressPercentage),
      failure: (exception) => Result.failure(exception),
    );
  }
}
