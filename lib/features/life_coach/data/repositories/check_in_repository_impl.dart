import 'package:drift/drift.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/core/error/failures.dart';
import 'package:lifeos/features/life_coach/data/models/check_in_model.dart';
import 'package:lifeos/features/life_coach/domain/entities/check_in_entity.dart';
import 'package:lifeos/features/life_coach/domain/repositories/check_in_repository.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final AppDatabase _database;

  CheckInRepositoryImpl(this._database);

  @override
  Future<Result<CheckInEntity>> createCheckIn(CheckInEntity checkIn) async {
    try {
      final model = CheckInModel.fromEntity(checkIn);
      await _database.into(_database.checkIns).insert(model.toDriftCompanion());
      return Result.success(checkIn);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to create check-in: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<CheckInEntity>> getCheckInById(String id) async {
    try {
      final row = await (_database.select(_database.checkIns)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      if (row == null) {
        return Result.failure(
          DatabaseFailure('Check-in not found'),
        );
      }

      final model = CheckInModel.fromDrift(row);
      return Result.success(model.toEntity());
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get check-in: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<CheckInEntity>>> getAllCheckIns(String userId) async {
    try {
      final rows = await (_database.select(_database.checkIns)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([
              (tbl) => OrderingTerm(
                    expression: tbl.timestamp,
                    mode: OrderingMode.desc,
                  )
            ]))
          .get();

      final entities = rows
          .map((row) => CheckInModel.fromDrift(row).toEntity())
          .toList();

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get check-ins: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<CheckInEntity>>> getCheckInsForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final rows = await (_database.select(_database.checkIns)
            ..where((tbl) =>
                tbl.userId.equals(userId) &
                tbl.timestamp.isBiggerOrEqualValue(startOfDay) &
                tbl.timestamp.isSmallerThanValue(endOfDay)))
          .get();

      final entities = rows
          .map((row) => CheckInModel.fromDrift(row).toEntity())
          .toList();

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get check-ins for date: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<CheckInEntity?>> getTodaysCheckIn(
    String userId,
    CheckInType type,
  ) async {
    try {
      final today = DateTime.now();
      final result = await getCheckInsForDate(userId, today);

      return result.when(
        success: (data) {
          final todaysCheckIn = data
              .where((checkIn) => checkIn.type == type)
              .firstOrNull;
          return Result.success(todaysCheckIn);
        },
        failure: (exception) => Result.failure(exception),
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get today\'s check-in: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<CheckInEntity>> updateCheckIn(CheckInEntity checkIn) async {
    try {
      final model = CheckInModel.fromEntity(checkIn);
      await (_database.update(_database.checkIns)
            ..where((tbl) => tbl.id.equals(checkIn.id)))
          .write(model.toDriftCompanion());

      return Result.success(checkIn);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to update check-in: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteCheckIn(String id) async {
    try {
      await (_database.delete(_database.checkIns)
            ..where((tbl) => tbl.id.equals(id)))
          .go();

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to delete check-in: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<CheckInEntity>>> getCheckInsInRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final rows = await (_database.select(_database.checkIns)
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

      final entities = rows
          .map((row) => CheckInModel.fromDrift(row).toEntity())
          .toList();

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to get check-ins in range: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<int>> getCheckInStreak(String userId) async {
    try {
      // Get all check-ins ordered by date
      final result = await getAllCheckIns(userId);

      return result.when(
        success: (data) {
          if (data.isEmpty) return const Result.success(0);

          // Calculate streak
          int streak = 0;
          DateTime? lastDate;

          for (final checkIn in data) {
            final checkInDate = DateTime(
              checkIn.timestamp.year,
              checkIn.timestamp.month,
              checkIn.timestamp.day,
            );

            if (lastDate == null) {
              // First check-in
              final today = DateTime.now();
              final todayDate = DateTime(today.year, today.month, today.day);

              // Only count if check-in is today or yesterday
              if (checkInDate == todayDate ||
                  checkInDate == todayDate.subtract(const Duration(days: 1))) {
                streak = 1;
                lastDate = checkInDate;
              } else {
                break;
              }
            } else {
              // Check if consecutive day
              final dayDiff = lastDate.difference(checkInDate).inDays;

              if (dayDiff == 1) {
                streak++;
                lastDate = checkInDate;
              } else if (dayDiff == 0) {
                // Same day, don't increment streak
                continue;
              } else {
                // Streak broken
                break;
              }
            }
          }

          return Result.success(streak);
        },
        failure: (exception) => Result.failure(exception),
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Failed to calculate streak: ${e.toString()}'),
      );
    }
  }
}
