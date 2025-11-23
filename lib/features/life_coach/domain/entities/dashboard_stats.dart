import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    required int totalGoals,
    required int activeGoals,
    required int completedGoals,
    required int checkInStreak,
    required int overallProgress,      // 0-100%
    required DateTime calculatedAt,
  }) = _DashboardStats;
}
