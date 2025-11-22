import 'package:drift/drift.dart';
import 'package:gymapp/core/database/database.dart';
import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/core/error/failures.dart';
import 'package:gymapp/features/fitness/data/models/workout_log_model.dart';
import 'package:gymapp/features/fitness/data/models/exercise_set_model.dart';
import 'package:gymapp/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:gymapp/features/fitness/domain/entities/exercise_set_entity.dart';
import 'package:gymapp/features/fitness/domain/repositories/workout_log_repository.dart';

class WorkoutLogRepositoryImpl implements WorkoutLogRepository {
  final AppDatabase _database;

  WorkoutLogRepositoryImpl(this._database);

  @override
  Future<Result<WorkoutLogEntity>> createWorkoutLog(
      WorkoutLogEntity workoutLog) async {
    try {
      final model = WorkoutLogModel.fromEntity(workoutLog);
      await _database.into(_database.workoutLogs).insert(
            model.toDriftCompanion(),
          );
      return Result.success(workoutLog);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to create workout log: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<WorkoutLogEntity>> createWorkoutLogWithSets(
    WorkoutLogEntity workoutLog,
    List<ExerciseSetEntity> sets,
  ) async {
    try {
      // Create workout log
      final workoutModel = WorkoutLogModel.fromEntity(workoutLog);
      await _database.into(_database.workoutLogs).insert(
            workoutModel.toDriftCompanion(),
          );

      // Create exercise sets
      for (final set in sets) {
        final setModel = ExerciseSetModel.fromEntity(set);
        await _database.into(_database.exerciseSets).insert(
              setModel.toDriftCompanion(),
            );
      }

      // Return workout log with sets
      final result = workoutLog.copyWith(sets: sets);
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        DatabaseFailure(
            'Failed to create workout log with sets: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<WorkoutLogEntity>> getWorkoutLogById(String id) async {
    try {
      final row = await (_database.select(_database.workoutLogs)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      if (row == null) {
        return Result.failure(
          DatabaseFailure('Workout log not found'),
        );
      }

      // Get sets for this workout
      final setsResult = await getSetsForWorkout(id);
      List<ExerciseSetEntity> sets = [];
      setsResult.when(
        success: (s) => sets = s,
        failure: (_) => null,
      );

      final model = WorkoutLogModel.fromDrift(row);
      return Result.success(model.toEntity(sets: sets));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get workout log: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<WorkoutLogEntity>>> getAllWorkoutLogs(
      String userId) async {
    try {
      final rows = await (_database.select(_database.workoutLogs)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([
              (tbl) => OrderingTerm(
                    expression: tbl.timestamp,
                    mode: OrderingMode.desc,
                  )
            ]))
          .get();

      final entities = <WorkoutLogEntity>[];
      for (final row in rows) {
        final setsResult = await getSetsForWorkout(row.id);
        List<ExerciseSetEntity> sets = [];
        setsResult.when(
          success: (s) => sets = s,
          failure: (_) => null,
        );

        final model = WorkoutLogModel.fromDrift(row);
        entities.add(model.toEntity(sets: sets));
      }

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get workout logs: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<WorkoutLogEntity>>> getWorkoutLogsForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final rows = await (_database.select(_database.workoutLogs)
            ..where((tbl) =>
                tbl.userId.equals(userId) &
                tbl.timestamp.isBiggerOrEqualValue(startOfDay) &
                tbl.timestamp.isSmallerThanValue(endOfDay)))
          .get();

      final entities = <WorkoutLogEntity>[];
      for (final row in rows) {
        final setsResult = await getSetsForWorkout(row.id);
        List<ExerciseSetEntity> sets = [];
        setsResult.when(
          success: (s) => sets = s,
          failure: (_) => null,
        );

        final model = WorkoutLogModel.fromDrift(row);
        entities.add(model.toEntity(sets: sets));
      }

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get workout logs for date: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<WorkoutLogEntity>>> getWorkoutLogsInRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final rows = await (_database.select(_database.workoutLogs)
            ..where((tbl) =>
                tbl.userId.equals(userId) &
                tbl.timestamp.isBiggerOrEqualValue(startDate) &
                tbl.timestamp.isSmallerOrEqualValue(endDate))
            ..orderBy([
              (tbl) => OrderingTerm(
                    expression: tbl.timestamp,
                    mode: OrderingMode.desc,
                  )
            ]))
          .get();

      final entities = <WorkoutLogEntity>[];
      for (final row in rows) {
        final setsResult = await getSetsForWorkout(row.id);
        List<ExerciseSetEntity> sets = [];
        setsResult.when(
          success: (s) => sets = s,
          failure: (_) => null,
        );

        final model = WorkoutLogModel.fromDrift(row);
        entities.add(model.toEntity(sets: sets));
      }

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        DatabaseFailure(
            'Failed to get workout logs in range: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<WorkoutLogEntity>> updateWorkoutLog(
      WorkoutLogEntity workoutLog) async {
    try {
      final model = WorkoutLogModel.fromEntity(workoutLog);
      await (_database.update(_database.workoutLogs)
            ..where((tbl) => tbl.id.equals(workoutLog.id)))
          .write(model.toDriftCompanion());

      return Result.success(workoutLog);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to update workout log: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteWorkoutLog(String id) async {
    try {
      // Delete associated sets first
      await (_database.delete(_database.exerciseSets)
            ..where((tbl) => tbl.workoutLogId.equals(id)))
          .go();

      // Delete workout log
      await (_database.delete(_database.workoutLogs)
            ..where((tbl) => tbl.id.equals(id)))
          .go();

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to delete workout log: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<ExerciseSetEntity>>> getSetsForWorkout(
      String workoutLogId) async {
    try {
      final rows = await (_database.select(_database.exerciseSets)
            ..where((tbl) => tbl.workoutLogId.equals(workoutLogId))
            ..orderBy([
              (tbl) => OrderingTerm(expression: tbl.setNumber)
            ]))
          .get();

      final entities =
          rows.map((row) => ExerciseSetModel.fromDrift(row).toEntity()).toList();

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get exercise sets: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<ExerciseSetEntity>> addExerciseSet(
      ExerciseSetEntity set) async {
    try {
      final model = ExerciseSetModel.fromEntity(set);
      await _database.into(_database.exerciseSets).insert(
            model.toDriftCompanion(),
          );
      return Result.success(set);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to add exercise set: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<ExerciseSetEntity>> updateExerciseSet(
      ExerciseSetEntity set) async {
    try {
      final model = ExerciseSetModel.fromEntity(set);
      await (_database.update(_database.exerciseSets)
            ..where((tbl) => tbl.id.equals(set.id)))
          .write(model.toDriftCompanion());

      return Result.success(set);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to update exercise set: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteExerciseSet(String setId) async {
    try {
      await (_database.delete(_database.exerciseSets)
            ..where((tbl) => tbl.id.equals(setId)))
          .go();

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to delete exercise set: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<WorkoutStats>> getWorkoutStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Result<List<WorkoutLogEntity>> logsResult;

      if (startDate != null && endDate != null) {
        logsResult = await getWorkoutLogsInRange(
          userId,
          startDate: startDate,
          endDate: endDate,
        );
      } else {
        logsResult = await getAllWorkoutLogs(userId);
      }

      return logsResult.when(
        success: (logs) {
          int totalSets = 0;
          double totalVolume = 0.0;
          int totalDuration = 0;
          Map<String, int> exerciseCounts = {};

          for (final log in logs) {
            totalSets += log.totalSets;
            totalVolume += log.totalVolume;
            totalDuration += log.duration;

            for (final set in log.sets) {
              exerciseCounts[set.exerciseName] =
                  (exerciseCounts[set.exerciseName] ?? 0) + 1;
            }
          }

          final stats = WorkoutStats(
            totalWorkouts: logs.length,
            totalSets: totalSets,
            totalVolume: totalVolume,
            totalDuration: totalDuration,
            exerciseCounts: exerciseCounts,
          );

          return Result.success(stats);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get workout stats: ${e.toString()}'),
      );
    }
  }
}
