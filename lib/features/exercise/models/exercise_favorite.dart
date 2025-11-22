// Story 3.2: Exercise Library - Exercise Favorite Model
// AC7: Favorite exercises (star icon) → Quick access

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_favorite.freezed.dart';
part 'exercise_favorite.g.dart';

/// Model representing a user's favorited exercise
///
/// Maps to the `exercise_favorites` table in Supabase
@freezed
class ExerciseFavorite with _$ExerciseFavorite {
  const factory ExerciseFavorite({
    /// Unique identifier for the favorite
    required String id,

    /// User ID who favorited the exercise
    required String userId,

    /// Exercise ID that was favorited
    required String exerciseId,

    /// Timestamp when exercise was favorited
    required DateTime createdAt,

    /// Timestamp when favorite was last updated
    DateTime? updatedAt,
  }) = _ExerciseFavorite;

  /// Create ExerciseFavorite from JSON (Supabase response)
  factory ExerciseFavorite.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFavoriteFromJson(json);
}
