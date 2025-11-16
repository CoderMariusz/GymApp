# Story 2.2 - Detailed Technical Context
## AI Daily Plan Generation

**Story:** 2.2
**Epic:** 2 - Life Coach MVP
**Sprint:** 2
**Story Points:** 5
**Complexity:** ⭐⭐⭐⭐⭐

---

## 🎯 Executive Summary

AI Daily Plan Generation creates personalized 5-8 task daily plans based on user context (mood, energy, sleep quality, goals, workouts). This is a **core value proposition** of LifeOS Life Coach module.

**Key Challenge:** Aggregate cross-module context, generate high-quality AI plans in <3s, and route between AI models (Llama/Claude/GPT-4) based on subscription tier.

---

## 📊 SYSTEM ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│ TRIGGER: Morning Check-in Completed                         │
│  User submits: mood=4, energy=3, sleep_quality=4            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: Context Aggregation (<500ms)                        │
│                                                              │
│  Fetch user context:                                         │
│  1. Morning check-in data (mood, energy, sleep)             │
│  2. Active goals (max 3 for free tier)                      │
│  3. Scheduled workouts (from Fitness module)                │
│  4. Stress level (from Mind module, if available)           │
│  5. Yesterday's completion rate                             │
│  6. User preferences (AI personality: Sage vs Momentum)     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: Build AI Prompt (<200ms)                            │
│                                                              │
│  Template-based prompt with:                                 │
│  - User context (JSON format)                               │
│  - AI personality instructions                              │
│  - Task format requirements                                 │
│  - Examples (few-shot learning)                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: AI Model Routing (Tier-based)                       │
│                                                              │
│  Free Tier → Llama 3 (self-hosted, 3-5 plans/day limit)    │
│  Standard → Claude (Anthropic API, unlimited)               │
│  Premium → GPT-4 (OpenAI API, unlimited)                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: Call AI API (<2.5s)                                 │
│                                                              │
│  - Send prompt to AI model                                  │
│  - Stream response (if supported)                           │
│  - Parse JSON response                                      │
│  - Validate task structure                                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: Save & Display (<200ms)                             │
│                                                              │
│  1. Save to daily_plans table (Drift + Supabase)            │
│  2. Update UI with generated plan                           │
│  3. Log generation time + model used                        │
│                                                              │
│  Total Time: <3s ✅                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 💻 IMPLEMENTATION

### Context Aggregation Service

```dart
@freezed
class UserContext with _$UserContext {
  const factory UserContext({
    required CheckInData morningCheckIn,
    required List<Goal> activeGoals,
    List<ScheduledWorkout>? scheduledWorkouts,
    int? stressLevel,
    double? yesterdayCompletionRate,
    required AIPersonality aiPersonality,
    required SubscriptionTier tier,
  }) = _UserContext;
}

class ContextAggregationService {
  final CheckInRepository _checkInRepository;
  final GoalsRepository _goalsRepository;
  final CrossModuleService _crossModuleService;
  final UserSettingsRepository _settingsRepository;

  Future<UserContext> aggregateContext(String userId) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Fetch all context in parallel
      final results = await Future.wait([
        _checkInRepository.getTodayCheckIn(userId),
        _goalsRepository.getActiveGoals(userId),
        _crossModuleService.getScheduledWorkouts(userId),
        _crossModuleService.getStressLevelForToday(userId),
        _getYesterdayCompletionRate(userId),
        _settingsRepository.getSettings(userId),
        _subscriptionService.getSubscription(userId),
      ]);

      stopwatch.stop();
      print('Context aggregation: ${stopwatch.elapsedMilliseconds}ms');

      return UserContext(
        morningCheckIn: results[0] as CheckInData,
        activeGoals: results[1] as List<Goal>,
        scheduledWorkouts: results[2] as List<ScheduledWorkout>?,
        stressLevel: results[3] as int?,
        yesterdayCompletionRate: results[4] as double?,
        aiPersonality: (results[5] as UserSettings).aiPersonality,
        tier: (results[6] as Subscription).tier,
      );

    } catch (e) {
      print('Context aggregation error: $e');
      rethrow;
    }
  }

  Future<double?> _getYesterdayCompletionRate(String userId) async {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    final plan = await _dailyPlansRepository.getPlanForDate(userId, yesterday);

    if (plan == null) return null;

    final completed = plan.tasks.where((t) => t.completed).length;
    final total = plan.tasks.length;

    return total > 0 ? completed / total : null;
  }
}
```

---

### AI Prompt Engineering

```dart
class DailyPlanPromptBuilder {
  String buildPrompt(UserContext context) {
    return '''You are a ${ context.aiPersonality == AIPersonality.sage ? 'wise, supportive' : 'energetic, motivational' } life coach creating a daily plan.

**User Context (Today):**
- Mood: ${context.morningCheckIn.mood}/5 (${_moodLabel(context.morningCheckIn.mood)})
- Energy: ${context.morningCheckIn.energy}/5 (${_energyLabel(context.morningCheckIn.energy)})
- Sleep Quality: ${context.morningCheckIn.sleepQuality}/5 (${_sleepLabel(context.morningCheckIn.sleepQuality)})
${context.stressLevel != null ? '- Stress Level: ${context.stressLevel}/5' : ''}
${context.yesterdayCompletionRate != null ? '- Yesterday Completion: ${(context.yesterdayCompletionRate! * 100).toInt()}%' : ''}

**Active Goals:**
${context.activeGoals.map((g) => '- ${g.title} (${g.category})').join('\n')}

**Scheduled Workouts:**
${context.scheduledWorkouts?.map((w) => '- ${w.name} at ${w.scheduledTime}').join('\n') ?? 'None'}

**Task:**
Generate a personalized daily plan with 5-8 tasks.

**Guidelines:**
1. Balance difficulty based on energy level (low energy → easier tasks)
2. Include goal-related tasks (at least 1 per active goal if possible)
3. Factor in scheduled workouts (don't overwhelm if heavy workout day)
4. Adjust tone based on mood (low mood → gentle encouragement)
5. Include variety: work, health, personal development, relationships
6. Each task: 15-60 minutes duration
7. Prioritize tasks: P0 (must do), P1 (should do), P2 (nice to do)
8. Include motivational insight at the end

**Response Format (JSON):**
{
  "tasks": [
    {
      "title": "Task title (max 60 chars)",
      "description": "Optional details (max 120 chars)",
      "priority": "P0" | "P1" | "P2",
      "estimatedMinutes": 30,
      "category": "work" | "health" | "personal" | "relationships",
      "goalId": "goal-id-if-related" | null
    }
  ],
  "insight": "One-sentence motivational insight (max 150 chars)"
}

**Example (for low energy day):**
{
  "tasks": [
    {"title": "Morning meditation (10 min)", "priority": "P0", "estimatedMinutes": 10, "category": "health"},
    {"title": "Review project roadmap", "priority": "P1", "estimatedMinutes": 30, "category": "work"},
    {"title": "Light walk (20 min)", "priority": "P1", "estimatedMinutes": 20, "category": "health"},
    {"title": "Call a friend", "priority": "P2", "estimatedMinutes": 20, "category": "relationships"},
    {"title": "Read 10 pages", "priority": "P2", "estimatedMinutes": 20, "category": "personal"}
  ],
  "insight": "Low energy today? Focus on consistency over intensity. Small wins build momentum."
}

**JSON Response:**''';
  }

  String _moodLabel(int mood) {
    const labels = ['Very low', 'Low', 'Neutral', 'Good', 'Great'];
    return labels[mood - 1];
  }

  String _energyLabel(int energy) {
    const labels = ['Exhausted', 'Low', 'Moderate', 'Good', 'High'];
    return labels[energy - 1];
  }

  String _sleepLabel(int sleep) {
    const labels = ['Poor', 'Fair', 'OK', 'Good', 'Excellent'];
    return labels[sleep - 1];
  }
}
```

---

### AI Model Routing

```dart
class AIModelRouter {
  final AIServiceLlama _llama;
  final AIServiceClaude _claude;
  final AIServiceGPT4 _gpt4;
  final RateLimiter _rateLimiter;

  Future<AIResponse> generateDailyPlan({
    required String userId,
    required String prompt,
    required SubscriptionTier tier,
  }) async {
    // Check rate limit (free tier: 5 plans/day)
    if (tier == SubscriptionTier.free) {
      final canGenerate = await _rateLimiter.checkLimit(
        userId: userId,
        action: 'daily_plan_generation',
        maxPerDay: 5,
      );

      if (!canGenerate) {
        throw RateLimitException('Daily plan limit reached (5/day on free tier)');
      }
    }

    // Route to appropriate AI model
    final stopwatch = Stopwatch()..start();

    try {
      AIResponse response;

      switch (tier) {
        case SubscriptionTier.free:
          response = await _llama.generate(prompt, maxTokens: 500);
          break;
        case SubscriptionTier.singleModule:
        case SubscriptionTier.threeModulePack:
          response = await _claude.generate(prompt, maxTokens: 500);
          break;
        case SubscriptionTier.fullAccess:
          response = await _gpt4.generate(prompt, maxTokens: 500);
          break;
      }

      stopwatch.stop();
      print('AI generation (${tier.name}): ${stopwatch.elapsedMilliseconds}ms');

      // Increment rate limiter
      if (tier == SubscriptionTier.free) {
        await _rateLimiter.increment(userId, 'daily_plan_generation');
      }

      return response;

    } catch (e) {
      print('AI generation error: $e');
      rethrow;
    }
  }
}

@freezed
class AIResponse with _$AIResponse {
  const factory AIResponse({
    required String content,
    required AIModel model,
    required int tokensUsed,
    required Duration latency,
  }) = _AIResponse;
}

enum AIModel { llama3, claude3Sonnet, gpt4 }
```

---

### Response Parsing & Validation

```dart
class DailyPlanParser {
  DailyPlan parseAIResponse(AIResponse response, String userId, DateTime date) {
    try {
      // Extract JSON from response (AI might add explanatory text)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response.content);
      if (jsonMatch == null) {
        throw ParsingException('No JSON found in AI response');
      }

      final json = jsonDecode(jsonMatch.group(0)!);

      // Validate structure
      if (!json.containsKey('tasks') || !json.containsKey('insight')) {
        throw ParsingException('Missing required fields: tasks or insight');
      }

      final List<dynamic> tasksJson = json['tasks'];

      if (tasksJson.isEmpty || tasksJson.length > 10) {
        throw ParsingException('Invalid task count: ${tasksJson.length} (expected 5-8)');
      }

      // Parse tasks
      final tasks = tasksJson.map((t) => _parseTask(t)).toList();

      // Validate task priorities (at least 1 P0 task)
      final p0Count = tasks.where((t) => t.priority == Priority.p0).length;
      if (p0Count == 0) {
        print('Warning: No P0 tasks, upgrading first task');
        tasks.first = tasks.first.copyWith(priority: Priority.p0);
      }

      return DailyPlan(
        id: uuid.v4(),
        userId: userId,
        date: date,
        tasks: tasks,
        insight: json['insight'] as String,
        generatedBy: response.model,
        createdAt: DateTime.now().toUtc(),
      );

    } catch (e) {
      print('Parsing error: $e');
      throw ParsingException('Failed to parse AI response: $e');
    }
  }

  PlanTask _parseTask(Map<String, dynamic> json) {
    return PlanTask(
      id: uuid.v4(),
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: _parsePriority(json['priority']),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 30,
      category: _parseCategory(json['category']),
      goalId: json['goalId'] as String?,
      completed: false,
    );
  }

  Priority _parsePriority(dynamic value) {
    if (value == 'P0') return Priority.p0;
    if (value == 'P1') return Priority.p1;
    if (value == 'P2') return Priority.p2;
    return Priority.p1;  // Default
  }

  TaskCategory _parseCategory(dynamic value) {
    const map = {
      'work': TaskCategory.work,
      'health': TaskCategory.health,
      'personal': TaskCategory.personal,
      'relationships': TaskCategory.relationships,
    };
    return map[value] ?? TaskCategory.personal;
  }
}
```

---

## 🧪 TESTING STRATEGY

### Unit Tests

```dart
test('Context aggregation fetches all required data', () async {
  // Setup
  await createMockCheckIn(userId, mood: 4, energy: 3, sleepQuality: 5);
  await createMockGoals(userId, count: 3);

  // Execute
  final context = await contextAggregationService.aggregateContext(userId);

  // Assert
  expect(context.morningCheckIn.mood, equals(4));
  expect(context.activeGoals.length, equals(3));
  expect(context.aiPersonality, isNotNull);
});

test('Prompt builder includes all context', () {
  final context = UserContext(/* ... */);
  final prompt = promptBuilder.buildPrompt(context);

  expect(prompt, contains('Mood: 4/5'));
  expect(prompt, contains('Energy: 3/5'));
  expect(prompt, contains('Active Goals:'));
});

test('AI router selects correct model based on tier', () async {
  // Free tier → Llama
  final freePlan = await aiRouter.generateDailyPlan(
    userId: userId,
    prompt: testPrompt,
    tier: SubscriptionTier.free,
  );
  expect(freePlan.model, equals(AIModel.llama3));

  // Premium tier → GPT-4
  final premiumPlan = await aiRouter.generateDailyPlan(
    userId: userId,
    prompt: testPrompt,
    tier: SubscriptionTier.fullAccess,
  );
  expect(premiumPlan.model, equals(AIModel.gpt4));
});

test('Parser extracts tasks from valid JSON', () {
  final response = AIResponse(
    content: '''
{
  "tasks": [
    {"title": "Morning meditation", "priority": "P0", "estimatedMinutes": 10, "category": "health"},
    {"title": "Review emails", "priority": "P1", "estimatedMinutes": 20, "category": "work"}
  ],
  "insight": "Start your day with calm focus"
}
''',
    model: AIModel.claude3Sonnet,
    tokensUsed: 200,
    latency: Duration(seconds: 2),
  );

  final plan = parser.parseAIResponse(response, userId, DateTime.now());

  expect(plan.tasks.length, equals(2));
  expect(plan.tasks.first.title, equals('Morning meditation'));
  expect(plan.insight, equals('Start your day with calm focus'));
});
```

### Integration Tests

```dart
test('E2E: Generate daily plan from check-in', () async {
  // 1. Complete morning check-in
  await checkInService.submitCheckIn(
    userId: userId,
    mood: 4,
    energy: 3,
    sleepQuality: 5,
  );

  // 2. Generate daily plan
  final plan = await dailyPlanService.generateDailyPlan(userId);

  // 3. Assert plan generated
  expect(plan.tasks.length, greaterThanOrEqualTo(5));
  expect(plan.tasks.length, lessThanOrEqualTo(8));
  expect(plan.insight, isNotEmpty);
  expect(plan.generatedBy, isNotNull);

  // 4. Verify saved to database
  final savedPlan = await dailyPlansRepository.getPlanForDate(userId, DateTime.now());
  expect(savedPlan, isNotNull);
  expect(savedPlan!.id, equals(plan.id));
});
```

---

## ⚡ PERFORMANCE OPTIMIZATION

**Target: <3s total**

Breakdown:
- Context aggregation: <500ms (parallel fetches)
- Prompt building: <200ms (template-based)
- AI API call: <2.5s (Llama: <2s, Claude: <3s, GPT-4: <4s)
- Parsing & saving: <200ms

**Optimizations:**
1. Parallel context fetching (Future.wait)
2. Cache user settings (avoid repeated queries)
3. Stream AI responses (show progress indicator)
4. Optimistic UI (show "Generating..." immediately)

---

## ✅ DEFINITION OF DONE

- [ ] Context aggregation working (<500ms)
- [ ] AI model routing correct (Llama/Claude/GPT-4)
- [ ] Daily plan generation <3s (95th percentile)
- [ ] Rate limiting enforced (free tier: 5/day)
- [ ] Response parsing robust (handles malformed JSON)
- [ ] Unit tests passing (context, prompt, routing, parsing)
- [ ] Integration tests passing (E2E flow)
- [ ] Code reviewed and merged

---

**Created:** 2025-01-16
**Author:** Winston (BMAD Architect)
**Status:** Ready for Implementation
