import 'dart:convert';
import '../../../core/ai/ai_service.dart';
import '../domain/repositories/goals_repository.dart';
import '../domain/repositories/check_in_repository.dart';
import '../domain/repositories/preferences_repository.dart';
import 'models/goal_suggestion.dart';

class GoalSuggester {
  final AIService _aiService;
  final GoalsRepository _goalsRepo;
  final CheckInRepository _checkInRepo;
  final PreferencesRepository _prefsRepo;

  GoalSuggester({
    required AIService aiService,
    required GoalsRepository goalsRepo,
    required CheckInRepository checkInRepo,
    required PreferencesRepository prefsRepo,
  })  : _aiService = aiService,
        _goalsRepo = goalsRepo,
        _checkInRepo = checkInRepo,
        _prefsRepo = prefsRepo;

  Future<List<GoalSuggestion>> suggestGoals({int count = 3, String? userId}) async {
    try {
      // 1. Gather context
      final existingGoals = await _goalsRepo.getActiveGoals(userId ?? 'default');
      final recentCheckIns = await _checkInRepo.getRecentCheckIns(days: 7);
      final prefs = await _prefsRepo.getUserPreferences();

      // 2. Build prompts
      final systemPrompt = _buildSystemPrompt();
      final userPrompt = _buildUserPrompt(
        existingGoals: existingGoals,
        recentCheckIns: recentCheckIns,
        prefs: prefs,
        count: count,
      );

      // 3. Get AI suggestions
      final response = await _aiService.generateCompletion(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
      );

      // 4. Parse suggestions
      final suggestionsJson = jsonDecode(response.content);
      final suggestions = (suggestionsJson['suggestions'] as List)
          .map((json) => GoalSuggestion.fromJson(json))
          .toList();

      return suggestions;
    } catch (e) {
      throw Exception('Failed to generate goal suggestions: ${e.toString()}');
    }
  }

  String _buildSystemPrompt() => '''
You are a goal-setting AI coach for the LifeOS app.

Your role:
- Suggest realistic, achievable goals based on user context
- Consider their existing goals to avoid duplicates
- Align with their preferences and current lifestyle
- Provide actionable milestones

Guidelines:
1. Suggest SMART goals (Specific, Measurable, Achievable, Relevant, Time-bound)
2. Mix of short-term (1-4 weeks) and medium-term (1-3 months) goals
3. Balance categories (fitness, health, career, personal, social)
4. Provide clear "why" (motivation) for each goal
5. Include 3-5 milestones (mini-goals) for tracking progress
6. Be realistic about timelines
7. Consider user's energy and mood patterns

Output format (JSON):
{
  "suggestions": [
    {
      "title": "Run 5km without stopping",
      "description": "Build cardio endurance to run 5km continuously",
      "category": "fitness",
      "why": "Improves cardiovascular health and builds mental resilience",
      "action_plan": "Start with run/walk intervals. Increase running time by 10% each week. Practice 3x per week.",
      "estimated_days": 42,
      "milestones": [
        "Run 1km without stopping",
        "Complete 2km run",
        "Finish 3km continuously",
        "Achieve 4km run",
        "Complete full 5km"
      ]
    }
  ]
}
''';

  String _buildUserPrompt({
    required List existingGoals,
    required List recentCheckIns,
    required dynamic prefs,
    required int count,
  }) {
    final existingContext = existingGoals.isEmpty
        ? 'No existing goals.'
        : '''
Current Goals:
${existingGoals.map((g) => '- ${g.title} (${g.category.name})').join('\n')}
''';

    final moodContext = recentCheckIns.isEmpty
        ? 'No recent check-ins.'
        : '''
Recent Check-ins (7 days):
- Average mood: ${_calculateAverage(recentCheckIns, (c) => c.mood)}/10
- Average energy: ${_calculateAverage(recentCheckIns, (c) => c.energy)}/10
- Average sleep: ${_calculateAverage(recentCheckIns, (c) => c.sleepHours)}h
''';

    final prefsContext = '''
User Preferences:
- Focus areas: ${prefs.focusAreas.join(', ')}
- Work schedule: ${prefs.workStartTime} - ${prefs.workEndTime}
- Exercise preference: ${prefs.preferredExerciseTime ?? 'flexible'}
- Morning person: ${prefs.isMorningPerson ? 'Yes' : 'No'}
''';

    return '''
Suggest $count new goals for the user.

$existingContext

$moodContext

$prefsContext

Important:
- Don't duplicate existing goals
- Consider their energy/mood patterns
- Align with focus areas
- Make goals diverse (different categories)

Generate $count goal suggestions (JSON format):
''';
  }

  double _calculateAverage(List items, double Function(dynamic) getValue) {
    if (items.isEmpty) return 0;
    final sum = items.map(getValue).reduce((a, b) => a + b);
    return sum / items.length;
  }
}
