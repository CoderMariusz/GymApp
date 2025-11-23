import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed.dart';

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String userId,
    required String workStartTime,      // "09:00"
    required String workEndTime,        // "17:00"
    String? preferredExerciseTime,      // "morning" | "afternoon" | "evening"
    @Default(true) bool isMorningPerson,
    @Default([]) List<String> focusAreas,  // ["fitness", "career", "wellness"]
  }) = _UserPreferences;
}
