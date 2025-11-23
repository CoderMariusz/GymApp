import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../core/ai/ai_service.dart';
import '../domain/repositories/goals_repository.dart';
import '../domain/repositories/check_in_repository.dart';
import '../data/repositories/daily_plan_repository.dart';
import '../domain/repositories/preferences_repository.dart';
import 'models/daily_plan.dart';
import 'models/plan_task.dart';
import 'prompts/daily_plan_prompt.dart';

class DailyPlanGenerator {
  final AIService _aiService;
  final GoalsRepository _goalsRepo;
  final CheckInRepository _checkInRepo;
  final DailyPlanRepository _planRepo;
  final PreferencesRepository _prefsRepo;

  DailyPlanGenerator({
    required AIService aiService,
    required GoalsRepository goalsRepo,
    required CheckInRepository checkInRepo,
    required DailyPlanRepository planRepo,
    required PreferencesRepository prefsRepo,
  })  : _aiService = aiService,
        _goalsRepo = goalsRepo,
        _checkInRepo = checkInRepo,
        _planRepo = planRepo,
        _prefsRepo = prefsRepo;

  Future<DailyPlan> generatePlan({
    DateTime? targetDate,
    bool useStreaming = false,
  }) async {
    try {
      final date = targetDate ?? DateTime.now();

      // 1. Gather context
      final checkIn = await _checkInRepo.getCheckInForDate(date);
      final goals = await _goalsRepo.getActiveGoals();
      final events = await _fetchCalendarEvents(date);
      final prefs = await _prefsRepo.getUserPreferences();

      // 2. Build prompts
      final systemPrompt = DailyPlanPrompt.buildSystemPrompt();
      final userPrompt = DailyPlanPrompt.buildUserPrompt(
        checkIn: checkIn,
        goals: goals,
        events: events,
        prefs: prefs,
        targetDate: date,
      );

      // 3. Call AI
      final response = await _aiService.generateCompletion(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
      );

      // 4. Parse response
      final planJson = jsonDecode(response.content);
      final plan = _parsePlan(planJson, date, response);

      // 5. Save to local DB
      await _planRepo.savePlan(plan);

      return plan;
    } catch (e) {
      throw Exception('Failed to generate daily plan: ${e.toString()}');
    }
  }

  DailyPlan _parsePlan(
    Map<String, dynamic> json,
    DateTime date,
    dynamic aiResponse,
  ) {
    final tasks = (json['tasks'] as List)
        .map((taskJson) => PlanTask.fromJson({
              ...taskJson,
              'id': taskJson['id'] ?? const Uuid().v4(),
            }))
        .toList();

    return DailyPlan(
      id: const Uuid().v4(),
      date: DateTime(date.year, date.month, date.day),
      tasks: tasks,
      dailyTheme: json['daily_theme'] ?? 'Balanced productivity',
      motivationalQuote: json['motivational_quote'],
      createdAt: DateTime.now(),
      source: PlanSource.ai_generated,
      metadata: {
        'ai_model': 'gpt-4o-mini',
        'tokens_used': aiResponse.tokensUsed,
        'cost': aiResponse.estimatedCost,
      },
    );
  }

  Future<List<CalendarEvent>> _fetchCalendarEvents(DateTime date) async {
    // TODO: Integrate with device calendar or your own calendar feature
    // For now, return empty list
    return [];
  }
}
