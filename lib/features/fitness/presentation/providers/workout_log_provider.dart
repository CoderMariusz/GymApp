import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymapp/core/database/database.dart';
import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/core/initialization/app_initializer.dart';
import 'package:gymapp/features/fitness/data/repositories/workout_log_repository_impl.dart';
import 'package:gymapp/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:gymapp/features/fitness/domain/entities/exercise_set_entity.dart';
import 'package:gymapp/features/fitness/domain/repositories/workout_log_repository.dart';
import 'package:gymapp/features/fitness/domain/usecases/create_workout_log_usecase.dart';
import 'package:gymapp/features/fitness/domain/usecases/quick_log_workout_usecase.dart';
import 'package:gymapp/features/fitness/domain/usecases/get_workout_history_usecase.dart';

/// Database provider for workout logs
final workoutLogDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(appDatabaseProvider);
});

/// Repository provider
final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  final database = ref.watch(workoutLogDatabaseProvider);
  return WorkoutLogRepositoryImpl(database);
});

/// Create workout log use case
final createWorkoutLogUseCaseProvider =
    Provider<CreateWorkoutLogUseCase>((ref) {
  final repository = ref.watch(workoutLogRepositoryProvider);
  return CreateWorkoutLogUseCase(repository);
});

/// Quick log workout use case
final quickLogWorkoutUseCaseProvider =
    Provider<QuickLogWorkoutUseCase>((ref) {
  final repository = ref.watch(workoutLogRepositoryProvider);
  return QuickLogWorkoutUseCase(repository);
});

/// Get workout history use case
final getWorkoutHistoryUseCaseProvider =
    Provider<GetWorkoutHistoryUseCase>((ref) {
  final repository = ref.watch(workoutLogRepositoryProvider);
  return GetWorkoutHistoryUseCase(repository);
});

/// Workout log state
class WorkoutLogState {
  final bool isLoading;
  final String? error;
  final List<WorkoutLogEntity> workoutHistory;
  final WorkoutLogEntity? currentWorkout;
  final List<ExerciseSetEntity> currentSets;

  WorkoutLogState({
    this.isLoading = false,
    this.error,
    this.workoutHistory = const [],
    this.currentWorkout,
    this.currentSets = const [],
  });

  WorkoutLogState copyWith({
    bool? isLoading,
    String? error,
    List<WorkoutLogEntity>? workoutHistory,
    WorkoutLogEntity? currentWorkout,
    List<ExerciseSetEntity>? currentSets,
  }) {
    return WorkoutLogState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      workoutHistory: workoutHistory ?? this.workoutHistory,
      currentWorkout: currentWorkout ?? this.currentWorkout,
      currentSets: currentSets ?? this.currentSets,
    );
  }
}

/// Workout log notifier
class WorkoutLogNotifier extends StateNotifier<WorkoutLogState> {
  final WorkoutLogRepository _repository;
  final CreateWorkoutLogUseCase _createWorkoutLog;
  final QuickLogWorkoutUseCase _quickLogWorkout;
  final GetWorkoutHistoryUseCase _getWorkoutHistory;

  WorkoutLogNotifier(
    this._repository,
    this._createWorkoutLog,
    this._quickLogWorkout,
    this._getWorkoutHistory,
  ) : super(WorkoutLogState());

  /// Create workout log
  Future<Result<WorkoutLogEntity>> createWorkoutLog(
      WorkoutLogEntity workoutLog) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createWorkoutLog(workoutLog);

    result.when(
      success: (createdWorkout) {
        state = state.copyWith(
          isLoading: false,
          workoutHistory: [createdWorkout, ...state.workoutHistory],
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
      },
    );

    return result;
  }

  /// Quick log workout
  Future<Result<WorkoutLogEntity>> quickLogWorkout(
      WorkoutLogEntity workoutLog) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _quickLogWorkout(workoutLog);

    result.when(
      success: (createdWorkout) {
        state = state.copyWith(
          isLoading: false,
          workoutHistory: [createdWorkout, ...state.workoutHistory],
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
      },
    );

    return result;
  }

  /// Load workout history
  Future<void> loadWorkoutHistory(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getWorkoutHistory(userId);

    result.when(
      success: (workouts) {
        state = state.copyWith(
          isLoading: false,
          workoutHistory: workouts,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
      },
    );
  }

  /// Add exercise set to current workout
  void addExerciseSet(ExerciseSetEntity set) {
    state = state.copyWith(
      currentSets: [...state.currentSets, set],
    );
  }

  /// Update exercise set
  void updateExerciseSet(int index, ExerciseSetEntity set) {
    final updatedSets = [...state.currentSets];
    updatedSets[index] = set;
    state = state.copyWith(currentSets: updatedSets);
  }

  /// Remove exercise set
  void removeExerciseSet(int index) {
    final updatedSets = [...state.currentSets];
    updatedSets.removeAt(index);
    state = state.copyWith(currentSets: updatedSets);
  }

  /// Clear current sets
  void clearCurrentSets() {
    state = state.copyWith(currentSets: []);
  }
}

/// Workout log provider
final workoutLogProvider =
    StateNotifierProvider<WorkoutLogNotifier, WorkoutLogState>((ref) {
  final repository = ref.watch(workoutLogRepositoryProvider);
  final createWorkout = ref.watch(createWorkoutLogUseCaseProvider);
  final quickLog = ref.watch(quickLogWorkoutUseCaseProvider);
  final getHistory = ref.watch(getWorkoutHistoryUseCaseProvider);

  return WorkoutLogNotifier(
    repository,
    createWorkout,
    quickLog,
    getHistory,
  );
});
