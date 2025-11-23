import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/core/ai/ai_provider.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/database/database_providers.dart';
import 'package:lifeos/core/error/result.dart';
import '../../domain/repositories/goals_repository.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../data/repositories/daily_plan_repository.dart';
import '../daily_plan_generator.dart';
import '../models/daily_plan.dart';

part 'daily_plan_provider.g.dart';

// Repository providers (mocks for now - will be replaced when Epic 2 stories are implemented)
@riverpod
GoalsRepository goalsRepository(Ref ref) {
  return MockGoalsRepository();
}

@riverpod
CheckInRepository checkInRepository(Ref ref) {
  return MockCheckInRepository();
}

@riverpod
PreferencesRepository preferencesRepository(Ref ref) {
  return MockPreferencesRepository();
}

@riverpod
DailyPlanRepository dailyPlanRepository(Ref ref) {
  return DailyPlanRepository(ref.watch(appDatabaseProvider));
}

@riverpod
DailyPlanGenerator dailyPlanGenerator(Ref ref) {
  return DailyPlanGenerator(
    aiService: ref.watch(aiServiceProvider),
    goalsRepo: ref.watch(goalsRepositoryProvider),
    checkInRepo: ref.watch(checkInRepositoryProvider),
    planRepo: ref.watch(dailyPlanRepositoryProvider),
    prefsRepo: ref.watch(preferencesRepositoryProvider),
  );
}

// State provider for the UI
@riverpod
class DailyPlanNotifier extends _$DailyPlanNotifier {
  @override
  Future<DailyPlan?> build({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final repo = ref.watch(dailyPlanRepositoryProvider);
    return await repo.getPlanForDate(targetDate);
  }

  Future<void> generatePlan() async {
    state = const AsyncValue.loading();

    try {
      final generator = ref.read(dailyPlanGeneratorProvider);
      final result = await generator.generatePlan();

      result.map(
        success: (success) {
          state = AsyncValue.data(success.data);
        },
        failure: (failure) {
          state = AsyncValue.error(failure.exception, StackTrace.current);
        },
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markTaskComplete(String taskId) async {
    final currentPlan = state.value;
    if (currentPlan == null) return;

    final updatedTasks = currentPlan.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return task;
    }).toList();

    final updatedPlan = currentPlan.copyWith(tasks: updatedTasks);

    // Save to DB
    await ref.read(dailyPlanRepositoryProvider).savePlan(updatedPlan);

    // Update state
    state = AsyncValue.data(updatedPlan);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Reorder tasks by dragging
  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final currentPlan = state.value;
    if (currentPlan == null) return;

    final tasks = List<PlanTask>.from(currentPlan.tasks);

    // Handle drag & drop indices
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);

    final updatedPlan = currentPlan.copyWith(
      tasks: tasks,
      source: PlanSource.manual, // Mark as manually edited
    );

    await ref.read(dailyPlanRepositoryProvider).savePlan(updatedPlan);
    state = AsyncValue.data(updatedPlan);
  }

  /// Add a new task to the plan
  Future<void> addTask(PlanTask task) async {
    final currentPlan = state.value;
    if (currentPlan == null) return;

    final updatedTasks = [...currentPlan.tasks, task];
    final updatedPlan = currentPlan.copyWith(
      tasks: updatedTasks,
      source: PlanSource.manual,
    );

    await ref.read(dailyPlanRepositoryProvider).savePlan(updatedPlan);
    state = AsyncValue.data(updatedPlan);
  }

  /// Edit an existing task
  Future<void> editTask(PlanTask updatedTask) async {
    final currentPlan = state.value;
    if (currentPlan == null) return;

    final updatedTasks = currentPlan.tasks.map((task) {
      return task.id == updatedTask.id ? updatedTask : task;
    }).toList();

    final updatedPlan = currentPlan.copyWith(
      tasks: updatedTasks,
      source: PlanSource.manual,
    );

    await ref.read(dailyPlanRepositoryProvider).savePlan(updatedPlan);
    state = AsyncValue.data(updatedPlan);
  }

  /// Delete a task from the plan
  Future<void> deleteTask(String taskId) async {
    final currentPlan = state.value;
    if (currentPlan == null) return;

    final updatedTasks = currentPlan.tasks.where((t) => t.id != taskId).toList();
    final updatedPlan = currentPlan.copyWith(
      tasks: updatedTasks,
      source: PlanSource.manual,
    );

    await ref.read(dailyPlanRepositoryProvider).savePlan(updatedPlan);
    state = AsyncValue.data(updatedPlan);
  }
}