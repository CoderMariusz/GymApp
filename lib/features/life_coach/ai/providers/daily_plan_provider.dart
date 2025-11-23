import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/core/ai/ai_provider.dart';
import 'package:lifeos/core/database/database.dart';
import '../../domain/repositories/goals_repository.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../data/repositories/daily_plan_repository.dart';
import '../daily_plan_generator.dart';
import '../models/daily_plan.dart';

part 'daily_plan_provider.g.dart';

// Database provider (reuse existing if available, or create new)
@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}

// Repository providers (mocks for now - will be replaced when Epic 2 stories are implemented)
@riverpod
GoalsRepository goalsRepository(GoalsRepositoryRef ref) {
  return MockGoalsRepository();
}

@riverpod
CheckInRepository checkInRepository(CheckInRepositoryRef ref) {
  return MockCheckInRepository();
}

@riverpod
PreferencesRepository preferencesRepository(PreferencesRepositoryRef ref) {
  return MockPreferencesRepository();
}

@riverpod
DailyPlanRepository dailyPlanRepository(DailyPlanRepositoryRef ref) {
  return DailyPlanRepository(ref.watch(appDatabaseProvider));
}

@riverpod
DailyPlanGenerator dailyPlanGenerator(DailyPlanGeneratorRef ref) {
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
      final plan = await generator.generatePlan();
      state = AsyncValue.data(plan);
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
}

// Migration note: Use existing appDatabaseProvider if available
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
