// ============================================================================
// LifeOS - Tracking Mixin for Progress Tracking
// ============================================================================
// Used in: Goals, Measurements, Workouts, Habits, Check-Ins
// ============================================================================

import 'package:gymapp/core/error/result.dart';

/// Mixin for entities that track progress over time
///
/// Provides:
/// - Progress calculation
/// - Historical data access
/// - Trend analysis
/// - Completion tracking
mixin TrackingMixin<T, ID> {
  /// Gets progress history for an entity
  ///
  /// Returns list of progress snapshots ordered by date
  Future<Result<List<ProgressSnapshot<T>>>> getProgressHistory(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets current progress percentage (0-100)
  ///
  /// Returns:
  /// - Success with progress value
  /// - Failure if entity not found or cannot calculate
  Future<Result<double>> getProgressPercentage(ID entityId);

  /// Gets progress trend (improving, declining, stable)
  ///
  /// Analyzes recent progress data to determine trend
  Future<Result<ProgressTrend>> getProgressTrend(
    ID entityId, {
    int daysToAnalyze = 7,
  });

  /// Records a progress update
  ///
  /// Stores snapshot of current state
  Future<Result<void>> recordProgress(
    ID entityId,
    Map<String, dynamic> data,
  );

  /// Gets streak information (consecutive days with progress)
  Future<Result<StreakInfo>> getStreak(ID entityId);

  /// Checks if entity is completed/achieved
  Future<Result<bool>> isCompleted(ID entityId);

  /// Marks entity as completed
  Future<Result<void>> markCompleted(ID entityId, {DateTime? completedAt});

  /// Gets completion rate for a period
  ///
  /// Useful for habits, check-ins, etc.
  Future<Result<double>> getCompletionRate(
    ID entityId, {
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Snapshot of progress at a specific point in time
class ProgressSnapshot<T> {
  final T entity;
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? metadata;

  const ProgressSnapshot({
    required this.entity,
    required this.timestamp,
    required this.value,
    this.metadata,
  });
}

/// Progress trend indicator
enum ProgressTrend {
  improving,
  declining,
  stable,
  insufficient_data,
}

extension ProgressTrendExtension on ProgressTrend {
  String get label {
    switch (this) {
      case ProgressTrend.improving:
        return 'Improving';
      case ProgressTrend.declining:
        return 'Declining';
      case ProgressTrend.stable:
        return 'Stable';
      case ProgressTrend.insufficient_data:
        return 'Not enough data';
    }
  }

  String get emoji {
    switch (this) {
      case ProgressTrend.improving:
        return '📈';
      case ProgressTrend.declining:
        return '📉';
      case ProgressTrend.stable:
        return '➡️';
      case ProgressTrend.insufficient_data:
        return '❓';
    }
  }
}

/// Streak information
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final bool isActive;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.isActive,
  });

  /// Whether streak is broken (no activity today)
  bool get isBroken => !isActive;

  /// Days until streak resets (usually 1)
  int get daysUntilReset => isActive ? 0 : 1;
}

/// Mixin for milestone tracking
mixin MilestoneMixin<T, ID> {
  /// Gets all milestones for an entity
  Future<Result<List<Milestone>>> getMilestones(ID entityId);

  /// Adds a milestone
  Future<Result<Milestone>> addMilestone(
    ID entityId, {
    required String title,
    required double targetValue,
    String? description,
  });

  /// Checks which milestones have been reached
  Future<Result<List<Milestone>>> getAchievedMilestones(ID entityId);

  /// Gets next unreached milestone
  Future<Result<Milestone?>> getNextMilestone(ID entityId);
}

/// Represents a milestone/achievement
class Milestone {
  final String id;
  final String title;
  final String? description;
  final double targetValue;
  final DateTime? achievedAt;
  final bool isAchieved;

  const Milestone({
    required this.id,
    required this.title,
    this.description,
    required this.targetValue,
    this.achievedAt,
    required this.isAchieved,
  });

  Milestone copyWith({
    String? id,
    String? title,
    String? description,
    double? targetValue,
    DateTime? achievedAt,
    bool? isAchieved,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      achievedAt: achievedAt ?? this.achievedAt,
      isAchieved: isAchieved ?? this.isAchieved,
    );
  }
}

/// Mixin for comparison tracking (e.g., compare this week vs last week)
mixin ComparisonMixin<T, ID> {
  /// Compares progress between two periods
  ///
  /// Returns comparison result with percentage change
  Future<Result<ComparisonResult>> comparePeriods(
    ID entityId, {
    required DateTime period1Start,
    required DateTime period1End,
    required DateTime period2Start,
    required DateTime period2End,
  });

  /// Compares current week vs last week
  Future<Result<ComparisonResult>> compareWeeks(ID entityId);

  /// Compares current month vs last month
  Future<Result<ComparisonResult>> compareMonths(ID entityId);
}

/// Result of comparing two periods
class ComparisonResult {
  final double period1Value;
  final double period2Value;
  final double change;
  final double percentageChange;
  final bool isImprovement;

  const ComparisonResult({
    required this.period1Value,
    required this.period2Value,
    required this.change,
    required this.percentageChange,
    required this.isImprovement,
  });

  String get changeLabel {
    if (change > 0) return '+${change.toStringAsFixed(1)}';
    return change.toStringAsFixed(1);
  }

  String get percentageLabel {
    if (percentageChange > 0) return '+${percentageChange.toStringAsFixed(1)}%';
    return '${percentageChange.toStringAsFixed(1)}%';
  }
}
