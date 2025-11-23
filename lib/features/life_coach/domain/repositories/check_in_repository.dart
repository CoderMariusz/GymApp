import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/life_coach/domain/entities/check_in_entity.dart';
import '../entities/morning_check_in.dart';

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

  // Additional methods for morning check-in
  Future<MorningCheckIn?> getCheckInForDate(DateTime date);
  Future<List<MorningCheckIn>> getRecentCheckIns({required int days});
  Future<int> getCurrentStreak();
}

// Temporary mock implementation - will be replaced when Story 2.3 is implemented
class MockCheckInRepository implements CheckInRepository {
  @override
  Future<MorningCheckIn?> getCheckInForDate(DateTime date) async {
    // Return sample check-in for today
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return MorningCheckIn(
        id: '1',
        date: date,
        mood: 7,
        energy: 8,
        sleepQuality: 7,
        sleepHours: 7.5,
        notes: 'Feeling good, ready for the day!',
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  @override
  Future<List<MorningCheckIn>> getRecentCheckIns({required int days}) async {
    return [];
  }

  @override
  Future<int> getCurrentStreak() async {
    return 5; // 5-day streak
  }

  // Implement required methods (will be properly implemented in Story 2.3)
  @override
  Future<Result<CheckInEntity>> createCheckIn(CheckInEntity checkIn) {
    throw UnimplementedError();
  }

  @override
  Future<Result<CheckInEntity>> getCheckInById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<CheckInEntity>>> getAllCheckIns(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<CheckInEntity>>> getCheckInsForDate(String userId, DateTime date) {
    throw UnimplementedError();
  }

  @override
  Future<Result<CheckInEntity?>> getTodaysCheckIn(String userId, CheckInType type) {
    throw UnimplementedError();
  }

  @override
  Future<Result<CheckInEntity>> updateCheckIn(CheckInEntity checkIn) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteCheckIn(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<CheckInEntity>>> getCheckInsInRange(String userId, {required DateTime startDate, required DateTime endDate}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<int>> getCheckInStreak(String userId) {
    throw UnimplementedError();
  }
}
