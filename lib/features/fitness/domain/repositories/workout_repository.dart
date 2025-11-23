import '../entities/workout_log.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutLog>> getWorkoutHistory({required int days});
  Future<List<ExerciseLog>> getExerciseHistory({
    required String exerciseName,
    required int limit,
  });
  Future<List<PersonalRecord>> getPersonalRecords();
}

// Mock implementation for BATCH 4
class MockWorkoutRepository implements WorkoutRepository {
  @override
  Future<List<WorkoutLog>> getWorkoutHistory({required int days}) async {
    // Return mock data for charts
    final now = DateTime.now();
    return List.generate(10, (index) {
      final date = now.subtract(Duration(days: index * 3));
      return WorkoutLog(
        id: 'workout-$index',
        date: date,
        exercises: [
          ExerciseLog(
            name: 'Bench Press',
            date: date,
            sets: [
              const WorkoutSet(weight: 80 + (index * 2.5), reps: 8, restSeconds: 120, rpe: 7),
              const WorkoutSet(weight: 80 + (index * 2.5), reps: 8, restSeconds: 120, rpe: 8),
            ],
          ),
        ],
        totalDurationMinutes: 60,
      );
    });
  }

  @override
  Future<List<ExerciseLog>> getExerciseHistory({
    required String exerciseName,
    required int limit,
  }) async {
    final now = DateTime.now();
    return List.generate(limit, (index) {
      final date = now.subtract(Duration(days: index * 7));
      return ExerciseLog(
        name: exerciseName,
        date: date,
        sets: [
          WorkoutSet(
            weight: 70 + (index * 2.5),
            reps: 8 + (index % 2),
            restSeconds: 120,
            rpe: 7 + (index % 2).toDouble(),
          ),
        ],
      );
    });
  }

  @override
  Future<List<PersonalRecord>> getPersonalRecords() async {
    final now = DateTime.now();
    return [
      PersonalRecord(
        exerciseName: 'Bench Press',
        weight: 100,
        date: now.subtract(const Duration(days: 5)),
      ),
      PersonalRecord(
        exerciseName: 'Squat',
        weight: 120,
        date: now.subtract(const Duration(days: 10)),
      ),
    ];
  }
}
