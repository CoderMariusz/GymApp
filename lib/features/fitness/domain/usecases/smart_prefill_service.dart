import 'dart:math';
import '../entities/workout_log.dart';
import '../entities/workout_pattern.dart';
import '../repositories/workout_repository.dart';

/// Smart prefill service that detects patterns and suggests progressive overload
class SmartPrefillService {
  final WorkoutRepository _workoutRepository;

  SmartPrefillService(this._workoutRepository);

  /// Analyze workout history and generate a suggestion for the given exercise
  Future<WorkoutSuggestion?> generateSuggestion({
    required String exerciseName,
    int historyLimit = 10,
  }) async {
    // 1. Get exercise history
    final history = await _workoutRepository.getExerciseHistory(
      exerciseName: exerciseName,
      limit: historyLimit,
    );

    if (history.isEmpty) {
      return null; // No pattern available, user needs to log manually
    }

    // 2. Detect pattern from history
    final pattern = _detectPattern(history);

    // 3. Determine overload strategy based on last performance
    final strategy = _determineOverloadStrategy(history, pattern);

    // 4. Generate set suggestions
    final sets = _generateSuggestedSets(pattern, strategy);

    // 5. Build rationale
    final rationale = _buildRationale(pattern, strategy, history);

    return WorkoutSuggestion(
      exerciseName: exerciseName,
      sets: sets,
      rationale: rationale,
      isProgressiveOverload: strategy != OverloadStrategy.maintain,
    );
  }

  /// Detect workout pattern from history
  WorkoutPattern _detectPattern(List<ExerciseLog> history) {
    if (history.isEmpty) {
      throw ArgumentError('History cannot be empty');
    }

    final lastWorkout = history.first; // Most recent
    final allSets = history.expand((log) => log.sets).toList();

    // Calculate averages
    final avgSets = (history.map((log) => log.sets.length).reduce((a, b) => a + b) /
        history.length).round();

    final avgReps = (allSets.map((s) => s.reps).reduce((a, b) => a + b) /
        allSets.length).round();

    final avgRest = (allSets.map((s) => s.restSeconds).reduce((a, b) => a + b) /
        allSets.length).round();

    // Get last workout stats
    final lastWeight = lastWorkout.sets
        .map((s) => s.weight)
        .reduce(max);

    final avgRpe = allSets.where((s) => s.rpe != null).isNotEmpty
        ? allSets.where((s) => s.rpe != null).map((s) => s.rpe!).reduce((a, b) => a + b) /
            allSets.where((s) => s.rpe != null).length
        : null;

    return WorkoutPattern(
      exerciseName: lastWorkout.name,
      averageSets: avgSets,
      averageReps: avgReps,
      lastWeight: lastWeight,
      suggestedWeight: lastWeight, // Will be adjusted by strategy
      averageRestSeconds: avgRest,
      lastPerformed: lastWorkout.date,
      performanceCount: history.length,
      averageRpe: avgRpe,
    );
  }

  /// Determine which progressive overload strategy to apply
  OverloadStrategy _determineOverloadStrategy(
    List<ExerciseLog> history,
    WorkoutPattern pattern,
  ) {
    if (history.isEmpty) return OverloadStrategy.maintain;

    final lastWorkout = history.first;
    final lastRpe = lastWorkout.sets
        .where((s) => s.rpe != null)
        .map((s) => s.rpe!)
        .toList();

    // No RPE data, default to small weight increase
    if (lastRpe.isEmpty) {
      return OverloadStrategy.increaseWeight;
    }

    final avgLastRpe = lastRpe.reduce((a, b) => a + b) / lastRpe.length;

    // Decision tree based on RPE
    if (avgLastRpe >= 9.0) {
      // Too hard, deload
      return OverloadStrategy.deload;
    } else if (avgLastRpe >= 7.5 && avgLastRpe < 9.0) {
      // Good intensity, maintain or slight increase
      return pattern.performanceCount >= 3
          ? OverloadStrategy.increaseWeight
          : OverloadStrategy.maintain;
    } else if (avgLastRpe >= 6.0 && avgLastRpe < 7.5) {
      // Moderate, increase reps or weight
      return OverloadStrategy.increaseReps;
    } else {
      // Too easy, definitely increase
      return OverloadStrategy.increaseWeight;
    }
  }

  /// Generate suggested sets based on pattern and strategy
  List<SuggestedSet> _generateSuggestedSets(
    WorkoutPattern pattern,
    OverloadStrategy strategy,
  ) {
    final sets = <SuggestedSet>[];

    for (int i = 0; i < pattern.averageSets; i++) {
      double weight = pattern.lastWeight;
      int reps = pattern.averageReps;
      String? note;
      double? targetRpe = pattern.averageRpe;

      switch (strategy) {
        case OverloadStrategy.increaseWeight:
          // Standard progression: 2.5-5kg increase
          weight = pattern.lastWeight + (pattern.lastWeight > 80 ? 2.5 : 5.0);
          note = 'Weight increased for progressive overload';
          targetRpe = targetRpe != null ? min(targetRpe + 0.5, 9.5) : 8.0;
          break;

        case OverloadStrategy.increaseReps:
          // Keep weight, add 1-2 reps
          reps = pattern.averageReps + (pattern.averageReps < 8 ? 2 : 1);
          note = 'More reps to build volume';
          targetRpe = targetRpe != null ? min(targetRpe + 0.5, 9.0) : 7.5;
          break;

        case OverloadStrategy.increaseVolume:
          // Already handled by averageSets
          note = 'Additional set for volume';
          break;

        case OverloadStrategy.deload:
          // Reduce weight by 10%
          weight = pattern.lastWeight * 0.9;
          note = 'Deload week - recovery recommended';
          targetRpe = 6.0;
          break;

        case OverloadStrategy.maintain:
          note = 'Same as last time - consistency';
          break;
      }

      sets.add(SuggestedSet(
        weight: weight,
        reps: reps,
        restSeconds: pattern.averageRestSeconds,
        targetRpe: targetRpe,
        note: i == 0 ? note : null, // Only first set gets note
      ));
    }

    // Add extra set if volume strategy
    if (strategy == OverloadStrategy.increaseVolume && sets.length < 5) {
      sets.add(SuggestedSet(
        weight: pattern.lastWeight,
        reps: pattern.averageReps,
        restSeconds: pattern.averageRestSeconds,
        targetRpe: pattern.averageRpe,
        note: 'Extra set for progressive overload',
      ));
    }

    return sets;
  }

  /// Build human-readable rationale for the suggestion
  String _buildRationale(
    WorkoutPattern pattern,
    OverloadStrategy strategy,
    List<ExerciseLog> history,
  ) {
    final daysSinceLast = DateTime.now().difference(pattern.lastPerformed).inDays;

    final buffer = StringBuffer();
    buffer.writeln('📊 Based on ${pattern.performanceCount} previous workouts:');
    buffer.writeln('• Last performed: $daysSinceLast days ago');
    buffer.writeln('• Last weight: ${pattern.lastWeight.toStringAsFixed(1)}kg');

    if (pattern.averageRpe != null) {
      buffer.writeln('• Average RPE: ${pattern.averageRpe!.toStringAsFixed(1)}/10');
    }

    buffer.write('\n💡 Recommendation: ');

    switch (strategy) {
      case OverloadStrategy.increaseWeight:
        buffer.writeln('Increase weight slightly. You\'re ready for more!');
        break;
      case OverloadStrategy.increaseReps:
        buffer.writeln('Add more reps to build endurance and volume.');
        break;
      case OverloadStrategy.increaseVolume:
        buffer.writeln('Add another set to increase total volume.');
        break;
      case OverloadStrategy.deload:
        buffer.writeln('Time for a deload. Last session was very hard.');
        break;
      case OverloadStrategy.maintain:
        buffer.writeln('Maintain current intensity for consistency.');
        break;
    }

    return buffer.toString();
  }

  /// Quick check if we have enough data for a good suggestion
  Future<bool> hasPatternData(String exerciseName) async {
    final history = await _workoutRepository.getExerciseHistory(
      exerciseName: exerciseName,
      limit: 2,
    );
    return history.length >= 2; // Need at least 2 workouts for a pattern
  }
}
