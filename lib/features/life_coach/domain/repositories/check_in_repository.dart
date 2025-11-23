import '../entities/morning_check_in.dart';

abstract class CheckInRepository {
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
}
