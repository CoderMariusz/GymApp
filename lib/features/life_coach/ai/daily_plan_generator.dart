import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../core/ai/ai_service.dart';
import '../../../core/error/result.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/rate_limiter.dart';
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
  final RateLimiter _rateLimiter;

  DailyPlanGenerator({
    required AIService aiService,
    required GoalsRepository goalsRepo,
    required CheckInRepository checkInRepo,
    required DailyPlanRepository planRepo,
    required PreferencesRepository prefsRepo,
    RateLimiter? rateLimiter,
  })  : _aiService = aiService,
        _goalsRepo = goalsRepo,
        _checkInRepo = checkInRepo,
        _planRepo = planRepo,
        _prefsRepo = prefsRepo,
        _rateLimiter = rateLimiter ??
            RateLimiter(
              requestsPerMinute: 5,
              burstSize: 2,
            );

  Future<Result<DailyPlan>> generatePlan({
    DateTime? targetDate,
    bool useStreaming = false,
    String? userId,
  }) async {
    // Check rate limit (use userId or 'default' as key)
    final rateLimitKey = userId ?? 'default';
    try {
      _rateLimiter.checkLimit(rateLimitKey);
    } on RateLimitFailure catch (e) {
      return Result.failure(e);
    }

    try {
      final date = targetDate ?? DateTime.now();

      // 1. Gather context
      final checkIn = await _checkInRepo.getCheckInForDate(date);
      final goals = await _goalsRepo.getActiveGoals(userId ?? 'default');
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

      // 4. Parse response with proper error handling
      Map<String, dynamic> planJson;
      try {
        final decoded = jsonDecode(response.content);
        if (decoded is! Map<String, dynamic>) {
          return Result.failure(
            AIParsingFailure('AI response is not a valid JSON object'),
          );
        }
        planJson = decoded;
      } on FormatException catch (e) {
        return Result.failure(
          AIParsingFailure('Invalid JSON format: ${e.message}'),
        );
      }

      final planResult = _parsePlan(planJson, date, response);
      if (planResult.isFailure) {
        return planResult;
      }

      final plan = planResult.dataOrThrow;

      // 5. Save to local DB
      try {
        await _planRepo.savePlan(plan);
      } catch (e) {
        return Result.failure(
          DatabaseFailure('Failed to save plan: ${e.toString()}'),
        );
      }

      return Result.success(plan);
    } on NetworkFailure catch (e) {
      return Result.failure(e);
    } on AIServiceFailure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        AIServiceFailure('Unexpected error generating plan: ${e.toString()}'),
      );
    }
  }

  Result<DailyPlan> _parsePlan(
    Map<String, dynamic> json,
    DateTime date,
    dynamic aiResponse,
  ) {
    try {
      // Validate tasks field
      final tasksData = json['tasks'];
      if (tasksData is! List) {
        return Result.failure(
          AIParsingFailure('Expected "tasks" to be a list, got ${tasksData.runtimeType}'),
        );
      }

      // Parse tasks with error handling
      final tasks = <PlanTask>[];
      for (var i = 0; i < tasksData.length; i++) {
        final taskJson = tasksData[i];
        if (taskJson is! Map<String, dynamic>) {
          return Result.failure(
            AIParsingFailure('Task at index $i is not a valid object'),
          );
        }

        try {
          final task = PlanTask.fromJson({
            ...taskJson,
            'id': taskJson['id'] ?? const Uuid().v4(),
          });
          tasks.add(task);
        } catch (e) {
          return Result.failure(
            AIParsingFailure('Failed to parse task at index $i: ${e.toString()}'),
          );
        }
      }

      final plan = DailyPlan(
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

      return Result.success(plan);
    } catch (e) {
      return Result.failure(
        AIParsingFailure('Failed to parse plan: ${e.toString()}'),
      );
    }
  }

  Future<List<CalendarEvent>> _fetchCalendarEvents(DateTime date) async {
    // TODO: Integrate with device calendar or your own calendar feature
    // For now, return empty list
    return [];
  }
}
