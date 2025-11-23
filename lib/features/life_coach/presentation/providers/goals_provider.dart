import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymapp/core/database/database.dart';
import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/core/initialization/app_initializer.dart';
import 'package:gymapp/features/life_coach/data/repositories/goals_repository_impl.dart';
import 'package:gymapp/features/life_coach/domain/entities/goal_entity.dart';
import 'package:gymapp/features/life_coach/domain/repositories/goals_repository.dart';
import 'package:gymapp/features/life_coach/domain/usecases/create_goal_usecase.dart';
import 'package:gymapp/features/life_coach/domain/usecases/get_goals_usecase.dart';
import 'package:gymapp/features/life_coach/domain/usecases/update_goal_usecase.dart';
import 'package:gymapp/features/life_coach/domain/usecases/delete_goal_usecase.dart';
import 'package:gymapp/features/life_coach/domain/usecases/record_goal_progress_usecase.dart';

final goalsDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(appDatabaseProvider);
});

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  final database = ref.watch(goalsDatabaseProvider);
  return GoalsRepositoryImpl(database);
});

final createGoalUseCaseProvider = Provider<CreateGoalUseCase>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return CreateGoalUseCase(repository);
});

final getGoalsUseCaseProvider = Provider<GetGoalsUseCase>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return GetGoalsUseCase(repository);
});

final updateGoalUseCaseProvider = Provider<UpdateGoalUseCase>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return UpdateGoalUseCase(repository);
});

final deleteGoalUseCaseProvider = Provider<DeleteGoalUseCase>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return DeleteGoalUseCase(repository);
});

final recordGoalProgressUseCaseProvider = Provider<RecordGoalProgressUseCase>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return RecordGoalProgressUseCase(repository);
});

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

class GoalsNotifier extends StateNotifier<GoalsState> {
  final GoalsRepository _repository;
  final CreateGoalUseCase _createGoal;
  final GetGoalsUseCase _getGoals;
  final UpdateGoalUseCase _updateGoal;
  final DeleteGoalUseCase _deleteGoal;
  final RecordGoalProgressUseCase _recordProgress;

  GoalsNotifier(
    this._repository,
    this._createGoal,
    this._getGoals,
    this._updateGoal,
    this._deleteGoal,
    this._recordProgress,
  ) : super(GoalsState());

  Future<Result<GoalEntity>> createGoal(GoalEntity goal) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createGoal(goal);

    result.when(
      success: (createdGoal) {
        state = state.copyWith(
          isLoading: false,
          goals: [createdGoal, ...state.goals],
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

  Future<void> loadGoals(String userId, {bool activeOnly = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getGoals(userId, activeOnly: activeOnly);

    result.when(
      success: (goals) {
        state = state.copyWith(
          isLoading: false,
          goals: goals,
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

  Future<Result<GoalEntity>> updateGoal(GoalEntity goal) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateGoal(goal);

    result.when(
      success: (updatedGoal) {
        final updatedGoals = state.goals.map((g) {
          return g.id == updatedGoal.id ? updatedGoal : g;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          goals: updatedGoals,
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

  Future<Result<void>> deleteGoal(String goalId) async {
    final result = await _deleteGoal(goalId);

    result.when(
      success: (_) {
        state = state.copyWith(
          goals: state.goals.where((g) => g.id != goalId).toList(),
        );
      },
      failure: (failure) {
        state = state.copyWith(error: failure.toString());
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

final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  final createGoal = ref.watch(createGoalUseCaseProvider);
  final getGoals = ref.watch(getGoalsUseCaseProvider);
  final updateGoal = ref.watch(updateGoalUseCaseProvider);
  final deleteGoal = ref.watch(deleteGoalUseCaseProvider);
  final recordProgress = ref.watch(recordGoalProgressUseCaseProvider);

  return GoalsNotifier(
    repository,
    createGoal,
    getGoals,
    updateGoal,
    deleteGoal,
    recordProgress,
  );
});
