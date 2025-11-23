import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_entity.freezed.dart';
part 'goal_entity.g.dart';

/// Goal entity for tracking personal goals
@freezed
class GoalEntity with _$GoalEntity {
  const factory GoalEntity({
    required String id,
    required String userId,
    required String title,
    String? description,
    required String category,
    DateTime? targetDate,
    double? targetValue,
    String? unit,
    @Default(0.0) double currentValue,
    @Default(0) int completionPercentage,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    List<String>? tags,
    @Default(1) int priority,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isSynced,
  }) = _GoalEntity;

  const GoalEntity._();

  factory GoalEntity.fromJson(Map<String, dynamic> json) =>
      _$GoalEntityFromJson(json);

  /// Whether goal has a numeric target
  bool get hasTarget => targetValue != null && targetValue! > 0;

  /// Calculate progress percentage based on current vs target value
  double get progressPercentage {
    if (!hasTarget) return 0;
    return ((currentValue / targetValue!) * 100).clamp(0, 100);
  }

  /// Check if goal is overdue
  bool get isOverdue {
    if (targetDate == null || isCompleted) return false;
    return DateTime.now().isAfter(targetDate!);
  }

  /// Get time remaining until target date
  Duration? get timeRemaining {
    if (targetDate == null || isCompleted) return null;
    final now = DateTime.now();
    if (now.isAfter(targetDate!)) return null;
    return targetDate!.difference(now);
  }

  /// Get days remaining until target date
  int? get daysRemaining {
    final remaining = timeRemaining;
    if (remaining == null) return null;
    return remaining.inDays;
  }

  /// Get formatted progress string
  String get formattedProgress {
    if (!hasTarget) return 'No target set';
    if (unit != null) {
      return '${currentValue.toStringAsFixed(1)} / ${targetValue!.toStringAsFixed(1)} $unit';
    }
    return '${currentValue.toStringAsFixed(1)} / ${targetValue!.toStringAsFixed(1)}';
  }
}
