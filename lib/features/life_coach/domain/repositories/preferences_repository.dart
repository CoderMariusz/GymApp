import '../entities/user_preferences.dart';

abstract class PreferencesRepository {
  Future<UserPreferences> getUserPreferences();
  Future<void> saveUserPreferences(UserPreferences prefs);
}

// Temporary mock implementation - will be replaced when Profile feature is enhanced
class MockPreferencesRepository implements PreferencesRepository {
  @override
  Future<UserPreferences> getUserPreferences() async {
    return const UserPreferences(
      userId: 'mock-user',
      workStartTime: '09:00',
      workEndTime: '17:00',
      preferredExerciseTime: 'morning',
      isMorningPerson: true,
      focusAreas: ['fitness', 'productivity', 'wellness'],
    );
  }

  @override
  Future<void> saveUserPreferences(UserPreferences prefs) async {
    // Will be implemented with proper storage later
  }
}
