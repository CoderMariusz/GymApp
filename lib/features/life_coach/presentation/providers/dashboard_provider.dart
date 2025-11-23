import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/charts/models/chart_data.dart';
import '../../../../core/charts/processors/data_aggregator.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../../domain/repositories/goals_repository.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/goal.dart';
import '../../ai/providers/daily_plan_provider.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardStats> dashboardStats(DashboardStatsRef ref) async {
  final goalsRepo = ref.watch(goalsRepositoryProvider);
  final checkInRepo = ref.watch(checkInRepositoryProvider);

  final allGoals = await goalsRepo.getAllGoals();
  final activeGoals = allGoals.where((g) => g.status == GoalStatus.active).length;
  final completedGoals = allGoals.where((g) => g.status == GoalStatus.completed).length;

  final streak = await checkInRepo.getCurrentStreak();
  final progress = await goalsRepo.getOverallProgress();

  return DashboardStats(
    totalGoals: allGoals.length,
    activeGoals: activeGoals,
    completedGoals: completedGoals,
    checkInStreak: streak,
    overallProgress: progress,
    calculatedAt: DateTime.now(),
  );
}

@riverpod
Future<List<ChartDataPoint>> moodTrend(MoodTrendRef ref, {required int days}) async {
  final checkInRepo = ref.watch(checkInRepositoryProvider);
  final checkIns = await checkInRepo.getRecentCheckIns(days: days);

  // Use REUSABLE DataAggregator!
  return DataAggregator.aggregateByPeriod(
    items: checkIns,
    getDate: (checkIn) => checkIn.date,
    getValue: (checkIn) => checkIn.mood.toDouble(),
    period: AggregationPeriod.daily,
    type: AggregationType.average,
  );
}

@riverpod
Future<List<ChartDataPoint>> energyTrend(EnergyTrendRef ref, {required int days}) async {
  final checkInRepo = ref.watch(checkInRepositoryProvider);
  final checkIns = await checkInRepo.getRecentCheckIns(days: days);

  return DataAggregator.aggregateByPeriod(
    items: checkIns,
    getDate: (checkIn) => checkIn.date,
    getValue: (checkIn) => checkIn.energy.toDouble(),
    period: AggregationPeriod.daily,
    type: AggregationType.average,
  );
}

@riverpod
Future<List<ChartDataPoint>> goalCompletion(
  GoalCompletionRef ref,
  {required int days},
) async {
  final goalsRepo = ref.watch(goalsRepositoryProvider);
  final completedGoals = await goalsRepo.getCompletedGoals(days: days);

  return DataAggregator.aggregateByPeriod(
    items: completedGoals,
    getDate: (goal) => goal.completedAt!,
    getValue: (_) => 1.0,  // Count each goal as 1
    period: AggregationPeriod.weekly,
    type: AggregationType.sum,
  );
}
