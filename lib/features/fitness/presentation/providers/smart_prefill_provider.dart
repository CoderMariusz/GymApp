import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/workout_pattern.dart';
import '../../domain/usecases/smart_prefill_service.dart';
import 'fitness_charts_provider.dart';

part 'smart_prefill_provider.g.dart';

/// Provider for SmartPrefillService instance
@riverpod
SmartPrefillService smartPrefillService(SmartPrefillServiceRef ref) {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  return SmartPrefillService(workoutRepo);
}

/// Generate workout suggestion for a specific exercise
@riverpod
Future<WorkoutSuggestion?> workoutSuggestion(
  WorkoutSuggestionRef ref, {
  required String exerciseName,
}) async {
  final service = ref.watch(smartPrefillServiceProvider);
  return service.generateSuggestion(exerciseName: exerciseName);
}

/// Check if we have enough pattern data for an exercise
@riverpod
Future<bool> hasPatternData(
  HasPatternDataRef ref, {
  required String exerciseName,
}) async {
  final service = ref.watch(smartPrefillServiceProvider);
  return service.hasPatternData(exerciseName);
}
