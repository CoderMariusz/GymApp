import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/core/ai/ai_provider.dart';
import '../../ai/providers/daily_plan_provider.dart';
import '../goal_suggester.dart';
import '../models/goal_suggestion.dart';

part 'goal_suggestion_provider.g.dart';

@riverpod
GoalSuggester goalSuggester(GoalSuggesterRef ref) {
  return GoalSuggester(
    aiService: ref.watch(aiServiceProvider),
    goalsRepo: ref.watch(goalsRepositoryProvider),
    checkInRepo: ref.watch(checkInRepositoryProvider),
    prefsRepo: ref.watch(preferencesRepositoryProvider),
  );
}

@riverpod
class GoalSuggestionsNotifier extends _$GoalSuggestionsNotifier {
  @override
  Future<List<GoalSuggestion>> build({int count = 3}) async {
    // Don't auto-load on init - wait for user action
    return [];
  }

  Future<void> generateSuggestions() async {
    state = const AsyncValue.loading();

    try {
      final suggester = ref.read(goalSuggesterProvider);
      final suggestions = await suggester.suggestGoals(count: count);
      state = AsyncValue.data(suggestions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await generateSuggestions();
  }
}
