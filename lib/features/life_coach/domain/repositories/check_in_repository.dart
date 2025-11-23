import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/life_coach/domain/entities/check_in_entity.dart';

/// Repository interface for check-in operations
abstract class CheckInRepository {
  /// Create a new check-in
  Future<Result<CheckInEntity>> createCheckIn(CheckInEntity checkIn);

  /// Get check-in by ID
  Future<Result<CheckInEntity>> getCheckInById(String id);

  /// Get all check-ins for a user
  Future<Result<List<CheckInEntity>>> getAllCheckIns(String userId);

  /// Get check-ins for a specific date
  Future<Result<List<CheckInEntity>>> getCheckInsForDate(
    String userId,
    DateTime date,
  );

  /// Get today's check-in (morning or evening)
  Future<Result<CheckInEntity?>> getTodaysCheckIn(
    String userId,
    CheckInType type,
  );

  /// Update a check-in
  Future<Result<CheckInEntity>> updateCheckIn(CheckInEntity checkIn);

  /// Delete a check-in
  Future<Result<void>> deleteCheckIn(String id);

  /// Get check-ins for a date range
  Future<Result<List<CheckInEntity>>> getCheckInsInRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get check-in streak (consecutive days with check-ins)
  Future<Result<int>> getCheckInStreak(String userId);
}
