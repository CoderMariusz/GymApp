import 'package:freezed_annotation/freezed_annotation.dart';

part 'meditation_entity.freezed.dart';

/// Meditation category types
enum MeditationCategory {
  stressRelief('stress_relief', 'Stress Relief'),
  sleep('sleep', 'Sleep'),
  focus('focus', 'Focus'),
  anxiety('anxiety', 'Anxiety'),
  gratitude('gratitude', 'Gratitude');

  const MeditationCategory(this.value, this.displayName);

  final String value;
  final String displayName;

  static MeditationCategory fromString(String value) {
    return MeditationCategory.values.firstWhere(
      (cat) => cat.value == value,
      orElse: () => MeditationCategory.stressRelief,
    );
  }
}

/// Domain entity for a guided meditation
@freezed
class MeditationEntity with _$MeditationEntity {
  const factory MeditationEntity({
    required String id,
    required String title,
    required String description,
    required int durationSeconds,
    required MeditationCategory category,
    required String audioUrl,
    required String thumbnailUrl,
    required DateTime createdAt,
    required bool isPremium,
    @Default(false) bool isFavorited,
    @Default(false) bool isDownloaded,
    @Default(0) int completionCount,
  }) = _MeditationEntity;

  const MeditationEntity._();

  /// Get duration in minutes for display
  int get durationMinutes => (durationSeconds / 60).round();

  /// Get formatted duration string (e.g., "10 min")
  String get durationFormatted => '$durationMinutes min';

  /// Check if meditation is accessible for free tier
  bool get isAccessibleForFree => !isPremium;
}
