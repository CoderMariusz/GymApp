import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/charts/models/chart_data.dart';
import '../../../../core/charts/processors/data_aggregator.dart';
import '../../domain/repositories/workout_repository.dart';
import 'dart:math';

part 'fitness_charts_provider.g.dart';

@riverpod
WorkoutRepository workoutRepository(WorkoutRepositoryRef ref) {
  return MockWorkoutRepository();
}

@riverpod
Future<List<ChartDataPoint>> strengthProgress(
  StrengthProgressRef ref, {
  required String exercise,
  int weeks = 12,
}) async {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final workouts = await workoutRepo.getWorkoutHistory(days: weeks * 7);

  // Filter workouts containing this exercise
  final exerciseLogs = workouts
      .expand((workout) => workout.exercises)
      .where((e) => e.name == exercise)
      .toList();

  if (exerciseLogs.isEmpty) return [];

  // Use REUSABLE aggregator to get max weight per week
  return DataAggregator.aggregateByPeriod(
    items: exerciseLogs,
    getDate: (e) => e.date,
    getValue: (e) => e.sets.map((s) => s.weight).reduce(max),
    period: AggregationPeriod.weekly,
    type: AggregationType.max,
  );
}

@riverpod
Future<List<ChartDataPoint>> weeklyVolume(
  WeeklyVolumeRef ref, {
  int weeks = 8,
}) async {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final workouts = await workoutRepo.getWorkoutHistory(days: weeks * 7);

  return DataAggregator.aggregateByPeriod(
    items: workouts,
    getDate: (workout) => workout.date,
    getValue: (workout) {
      // Calculate total volume (weight × reps) for this workout
      return workout.exercises
          .expand((e) => e.sets)
          .map((s) => s.weight * s.reps)
          .fold(0.0, (sum, volume) => sum + volume);
    },
    period: AggregationPeriod.weekly,
    type: AggregationType.sum,
  );
}

@riverpod
Future<List<ChartDataPoint>> personalRecords(PersonalRecordsRef ref) async {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final prs = await workoutRepo.getPersonalRecords();

  return prs.map((pr) => ChartDataPoint(
    x: pr.date.millisecondsSinceEpoch.toDouble(),
    y: pr.weight,
    label: pr.exerciseName,
    metadata: pr,
  )).toList();
}
