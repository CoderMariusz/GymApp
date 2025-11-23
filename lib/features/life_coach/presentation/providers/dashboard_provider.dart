import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/charts/models/chart_data.dart';
import '../../../../core/charts/processors/data_aggregator.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../../domain/repositories/goals_repository.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/goal.dart';
import '../../ai/providers/daily_plan_provider.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardStats> dashboardStats(Ref ref) async {
  final goalsRepo = ref.watch(goalsRepositoryProvider);
  final checkInRepo = ref.watch(checkInRepositoryProvider);

  final allGoalsResult = await goalsRepo.getAllGoals();
  final allGoals = allGoalsResult.dataOrThrow;
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
Future<List<ChartDataPoint>> moodTrend(Ref ref, {required int days}) async {
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
Future<List<ChartDataPoint>> energyTrend(Ref ref, {required int days}) async {
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
  Ref ref, {
  required int days,
}) async {
  final goalsRepo = ref.watch(goalsRepositoryProvider);
  final completedGoalsResult = await goalsRepo.getCompletedGoals(days: days);
  final completedGoals = completedGoalsResult.dataOrThrow;

  // Filter out goals without completedAt date before aggregation
  final goalsWithCompletedDate = completedGoals.where((goal) => goal.completedAt != null).toList();

  return DataAggregator.aggregateByPeriod(
    items: goalsWithCompletedDate,
    getDate: (goal) => goal.completedAt!,  // Safe: filtered above
    getValue: (_) => 1.0,  // Count each goal as 1
    period: AggregationPeriod.weekly,
    type: AggregationType.sum,
  );
}
