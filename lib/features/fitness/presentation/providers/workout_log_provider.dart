import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/database/database_providers.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/fitness/data/repositories/workout_log_repository_impl.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:lifeos/features/fitness/domain/entities/exercise_set_entity.dart';
import 'package:lifeos/features/fitness/domain/repositories/workout_log_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/create_workout_log_usecase.dart';
import 'package:lifeos/features/fitness/domain/usecases/quick_log_workout_usecase.dart';
import 'package:lifeos/features/fitness/domain/usecases/get_workout_history_usecase.dart';

part 'workout_log_provider.g.dart';

/// Database provider for workout logs
@riverpod
AppDatabase workoutLogDatabase(WorkoutLogDatabaseRef ref) {
  return ref.watch(appDatabaseProvider);
}

/// Repository provider
@riverpod
WorkoutLogRepository workoutLogRepository(WorkoutLogRepositoryRef ref) {
  final database = ref.watch(workoutLogDatabaseProvider);
  return WorkoutLogRepositoryImpl(database);
}

/// Create workout log use case
@riverpod
CreateWorkoutLogUseCase createWorkoutLogUseCase(CreateWorkoutLogUseCaseRef ref) {
  final repository = ref.watch(workoutLogRepositoryProvider);
  return CreateWorkoutLogUseCase(repository);
}

/// Quick log workout use case
@riverpod
QuickLogWorkoutUseCase quickLogWorkoutUseCase(QuickLogWorkoutUseCaseRef ref) {
  final repository = ref.watch(workoutLogRepositoryProvider);
  return QuickLogWorkoutUseCase(repository);
}

/// Get workout history use case
@riverpod
GetWorkoutHistoryUseCase getWorkoutHistoryUseCase(GetWorkoutHistoryUseCaseRef ref) {
  final repository = ref.watch(workoutLogRepositoryProvider);
  return GetWorkoutHistoryUseCase(repository);
}

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
@riverpod
class WorkoutLogNotifier extends _$WorkoutLogNotifier {
  late final WorkoutLogRepository _repository;
  late final CreateWorkoutLogUseCase _createWorkoutLog;
  late final QuickLogWorkoutUseCase _quickLogWorkout;
  late final GetWorkoutHistoryUseCase _getWorkoutHistory;

  @override
  WorkoutLogState build() {
    _repository = ref.watch(workoutLogRepositoryProvider);
    _createWorkoutLog = ref.watch(createWorkoutLogUseCaseProvider);
    _quickLogWorkout = ref.watch(quickLogWorkoutUseCaseProvider);
    _getWorkoutHistory = ref.watch(getWorkoutHistoryUseCaseProvider);

    return WorkoutLogState();
  }

  /// Create workout log
  Future<Result<WorkoutLogEntity>> createWorkoutLog(
      WorkoutLogEntity workoutLog) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createWorkoutLog(workoutLog);

    result.map(
      success: (success) {
        state = state.copyWith(
          isLoading: false,
          workoutHistory: [success.data, ...state.workoutHistory],
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.exception.toString(),
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

    result.map(
      success: (success) {
        state = state.copyWith(
          isLoading: false,
          workoutHistory: [success.data, ...state.workoutHistory],
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.exception.toString(),
        );
      },
    );

    return result;
  }

  /// Load workout history
  Future<void> loadWorkoutHistory(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getWorkoutHistory(userId);

    result.map(
      success: (success) {
        state = state.copyWith(
          isLoading: false,
          workoutHistory: success.data,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.exception.toString(),
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
