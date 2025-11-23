import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/database/database_providers.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/life_coach/data/repositories/goals_repository_impl.dart';
import 'package:lifeos/features/life_coach/domain/entities/goal_entity.dart';
import 'package:lifeos/features/life_coach/domain/repositories/goals_repository.dart';
import 'package:lifeos/features/life_coach/domain/usecases/create_goal_usecase.dart';
import 'package:lifeos/features/life_coach/domain/usecases/get_goals_usecase.dart';
import 'package:lifeos/features/life_coach/domain/usecases/update_goal_usecase.dart';
import 'package:lifeos/features/life_coach/domain/usecases/delete_goal_usecase.dart';
import 'package:lifeos/features/life_coach/domain/usecases/record_goal_progress_usecase.dart';

part 'goals_provider.g.dart';

@riverpod
AppDatabase goalsDatabase(Ref ref) {
  return ref.watch(appDatabaseProvider);
}

@riverpod
GoalsRepository goalsRepository(Ref ref) {
  final database = ref.watch(goalsDatabaseProvider);
  return GoalsRepositoryImpl(database);
}

@riverpod
CreateGoalUseCase createGoalUseCase(Ref ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return CreateGoalUseCase(repository);
}

@riverpod
GetGoalsUseCase getGoalsUseCase(Ref ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return GetGoalsUseCase(repository);
}

@riverpod
UpdateGoalUseCase updateGoalUseCase(Ref ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return UpdateGoalUseCase(repository);
}

@riverpod
DeleteGoalUseCase deleteGoalUseCase(Ref ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return DeleteGoalUseCase(repository);
}

@riverpod
RecordGoalProgressUseCase recordGoalProgressUseCase(Ref ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return RecordGoalProgressUseCase(repository);
}

class GoalsState {
  final bool isLoading;
  final String? error;
  final List<GoalEntity> goals;

  GoalsState({
    this.isLoading = false,
    this.error,
    this.goals = const [],
  });

  GoalsState copyWith({
    bool? isLoading,
    String? error,
    List<GoalEntity>? goals,
  }) {
    return GoalsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      goals: goals ?? this.goals,
    );
  }
}

@riverpod
class GoalsNotifier extends _$GoalsNotifier {
  late final GoalsRepository _repository;
  late final CreateGoalUseCase _createGoal;
  late final GetGoalsUseCase _getGoals;
  late final UpdateGoalUseCase _updateGoal;
  late final DeleteGoalUseCase _deleteGoal;
  late final RecordGoalProgressUseCase _recordProgress;

  @override
  GoalsState build() {
    _repository = ref.watch(goalsRepositoryProvider);
    _createGoal = ref.watch(createGoalUseCaseProvider);
    _getGoals = ref.watch(getGoalsUseCaseProvider);
    _updateGoal = ref.watch(updateGoalUseCaseProvider);
    _deleteGoal = ref.watch(deleteGoalUseCaseProvider);
    _recordProgress = ref.watch(recordGoalProgressUseCaseProvider);

    return GoalsState();
  }

  Future<Result<GoalEntity>> createGoal(GoalEntity goal) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createGoal(goal);

    result.map(
      success: (success) {
        state = state.copyWith(
          isLoading: false,
          goals: [success.data, ...state.goals],
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

  Future<void> loadGoals(String userId, {bool activeOnly = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getGoals(userId, activeOnly: activeOnly);

    result.map(
      success: (success) {
        state = state.copyWith(
          isLoading: false,
          goals: success.data,
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

  Future<Result<GoalEntity>> updateGoal(GoalEntity goal) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateGoal(goal);

    result.map(
      success: (success) {
        final updatedGoals = state.goals.map((g) {
          return g.id == success.data.id ? success.data : g;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          goals: updatedGoals,
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

  Future<Result<void>> deleteGoal(String goalId) async {
    final result = await _deleteGoal(goalId);

    result.map(
      success: (success) {
        state = state.copyWith(
          goals: state.goals.where((g) => g.id != goalId).toList(),
        );
      },
      failure: (failure) {
        state = state.copyWith(error: failure.exception.toString());
      },
    );

    return result;
  }

  Future<Result<void>> recordProgress(String goalId, double value, String? notes) async {
    final result = await _recordProgress(goalId, value, notes);

    if (result.isSuccess) {
      final goal = state.goals.firstWhere((g) => g.id == goalId);
      await updateGoal(goal);
    }

    return result;
  }
}
