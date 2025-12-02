# BATCH 2: AI Features Implementation

**Epic:** 2 (Life Coach)
**Stories:** 2.2, 2.4, 2.9
**Token Budget:** ~12K (zamiast 24K - oszczędność 50%)
**Czas:** 3-4 dni
**Dependencies:** `00-shared-components.md` (AI Service Layer)

---

## Stories Overview

| Story | Tytuł | Priorytet | Czas |
|-------|-------|-----------|------|
| 2.2 | AI Daily Plan Generation | ✨ ready-for-dev | 6-8h |
| 2.4 | AI Conversational Coaching | High | 6-8h |
| 2.9 | Goal Suggestions AI | Medium | 4-6h |

**Wspólne komponenty:** AI Service Layer (już stworzone w `00-shared-components.md`)

---

## Prerequisites

- ✅ Ukończony `00-shared-components.md` (AI Service Layer)
- ✅ API keys w `.env` (OpenAI/Anthropic)
- ✅ Stories 1.2-1.5 (Auth, Profile, Goals) - required data sources

---

## Story 2.2: AI Daily Plan Generation

### Opis funkcjonalności

**User Story:**
> Jako użytkownik chcę aby AI wygenerowało dla mnie spersonalizowany plan na dzień, bazując na moich celach, check-in porannym i kalendarzu, aby nie martwić się o planowanie dnia.

**Acceptance Criteria:**
1. ✅ Generowanie 6-8 zadań na dzień
2. ✅ Uwzględnienie: celów, nastrojów, energii, wydarzeń z kalendarza
3. ✅ Balansowanie kategorii (fitness, praca, wellness, osobiste)
4. ✅ Szacowany czas wykonania każdego zadania
5. ✅ Motywacyjny cytat/motto dnia
6. ✅ Możliwość regeneracji planu
7. ✅ Zapisywanie w local DB (Drift)

---

### Architektura

```
lib/features/life_coach/
├── ai/
│   ├── daily_plan_generator.dart        ✅ Core logic
│   ├── models/
│   │   ├── daily_plan.dart              ✅ Data model
│   │   └── plan_task.dart               ✅ Task model
│   ├── prompts/
│   │   └── daily_plan_prompt.dart       ✅ Prompt templates
│   └── providers/
│       └── daily_plan_provider.dart     ✅ Riverpod state
├── data/
│   ├── models/
│   │   └── daily_plan_dto.dart          ✅ Drift table
│   └── repositories/
│       └── daily_plan_repository.dart   ✅ Local storage
└── presentation/
    ├── pages/
    │   └── daily_plan_page.dart         ✅ UI
    └── widgets/
        ├── ai_generating_animation.dart ✅ Loading state
        ├── task_card.dart               ✅ Task display
        └── plan_actions_bar.dart        ✅ Actions (save, edit)
```

---

### Step 1: Data Models

**File:** `lib/features/life_coach/ai/models/plan_task.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_task.freezed.dart';
part 'plan_task.g.dart';

enum TaskCategory { fitness, productivity, wellness, personal, social }
enum TaskPriority { high, medium, low }
enum EnergyLevel { high, medium, low }

@freezed
class PlanTask with _$PlanTask {
  const factory PlanTask({
    required String id,
    required String title,
    required String description,
    required TaskCategory category,
    required TaskPriority priority,
    required int estimatedDuration,      // minutes
    required String suggestedTime,       // "07:00"
    required EnergyLevel energyLevel,
    required String why,                 // AI explanation
    @Default(false) bool isCompleted,
    DateTime? completedAt,
  }) = _PlanTask;

  factory PlanTask.fromJson(Map<String, dynamic> json) =>
      _$PlanTaskFromJson(json);
}
```

**File:** `lib/features/life_coach/ai/models/daily_plan.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'plan_task.dart';

part 'daily_plan.freezed.dart';
part 'daily_plan.g.dart';

enum PlanSource { ai_generated, manual }

@freezed
class DailyPlan with _$DailyPlan {
  const factory DailyPlan({
    required String id,
    required DateTime date,
    required List<PlanTask> tasks,
    required String dailyTheme,
    String? motivationalQuote,
    required DateTime createdAt,
    required PlanSource source,
    Map<String, dynamic>? metadata,    // AI model used, tokens, etc.
  }) = _DailyPlan;

  factory DailyPlan.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanFromJson(json);
}
```

---

### Step 2: Prompt Engineering

**File:** `lib/features/life_coach/ai/prompts/daily_plan_prompt.dart`

```dart
import '../../domain/entities/goal.dart';
import '../../domain/entities/morning_check_in.dart';
import '../../../profile/domain/entities/user_preferences.dart';

class DailyPlanPrompt {
  static String buildSystemPrompt() => '''
You are a personal life coach AI for LifeOS app.

Generate a realistic, achievable daily plan based on:
- User's goals (short-term & long-term)
- Morning check-in (mood, energy, sleep quality)
- Calendar events (from user's schedule)
- Past performance (completion rate, habits)
- User preferences (work hours, exercise time)

Rules:
1. Generate 6-8 tasks (realistic, not overwhelming)
2. Balance categories:
   - 30% productivity (work, learning)
   - 25% fitness (exercise, movement)
   - 20% wellness (meditation, breaks)
   - 15% personal (hobbies, relationships)
   - 10% social (friends, family)
3. Respect energy levels:
   - High-energy tasks (workouts, deep work) → Morning (7am-11am)
   - Medium-energy tasks (meetings, errands) → Midday (11am-3pm)
   - Low-energy tasks (reading, journaling) → Evening (6pm-9pm)
4. Include breaks every 2-3 hours
5. Align tasks with user's stated goals
6. Don't overlap with calendar events
7. Total task time should be 6-8 hours (rest of day is free)

Output format (JSON):
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Morning HIIT Workout",
      "description": "30 min high-intensity interval training",
      "category": "fitness",
      "priority": "high",
      "estimated_duration": 30,
      "suggested_time": "07:00",
      "energy_level": "high",
      "why": "Boosts energy and mood for the day ahead"
    }
  ],
  "daily_theme": "Focus on high-impact tasks in AM, recovery in PM",
  "motivational_quote": "The secret of getting ahead is getting started. - Mark Twain"
}

Important:
- Use realistic task durations (no 5-min workouts or 4-hour deep work sessions)
- Make tasks SPECIFIC (not "exercise" but "30 min yoga + 10 min stretching")
- Ensure variety (not 5 fitness tasks in a row)
- Consider user's mood/energy (if low, suggest gentler activities)
''';

  static String buildUserPrompt({
    required MorningCheckIn? checkIn,
    required List<Goal> goals,
    required List<CalendarEvent> events,
    required UserPreferences prefs,
    required DateTime targetDate,
  }) {
    final checkInContext = checkIn != null
        ? '''
Morning Check-In:
- Mood: ${checkIn.mood}/10 (${_interpretMood(checkIn.mood)})
- Energy: ${checkIn.energy}/10 (${_interpretEnergy(checkIn.energy)})
- Sleep: ${checkIn.sleepQuality}/10 quality, ${checkIn.sleepHours}h duration
- Notes: ${checkIn.notes ?? 'None'}
'''
        : 'No morning check-in completed yet.';

    final goalsContext = goals.isEmpty
        ? 'No active goals set.'
        : '''
Active Goals:
${goals.take(5).map((g) => '- ${g.title} (category: ${g.category}, deadline: ${g.targetDate})').join('\n')}
''';

    final eventsContext = events.isEmpty
        ? 'No calendar events today.'
        : '''
Calendar Events:
${events.map((e) => '- ${e.startTime}-${e.endTime}: ${e.title}').join('\n')}
''';

    final prefsContext = '''
User Preferences:
- Work hours: ${prefs.workStartTime} - ${prefs.workEndTime}
- Preferred exercise time: ${prefs.preferredExerciseTime ?? 'Flexible'}
- Morning person: ${prefs.isMorningPerson ? 'Yes' : 'No'}
- Focus areas: ${prefs.focusAreas.join(', ')}
''';

    return '''
Generate a personalized daily plan for ${_formatDate(targetDate)}.

$checkInContext

$goalsContext

$eventsContext

$prefsContext

Generate today's plan (JSON format):
''';
  }

  static String _interpretMood(int mood) {
    if (mood >= 8) return 'Excellent';
    if (mood >= 6) return 'Good';
    if (mood >= 4) return 'Okay';
    return 'Low';
  }

  static String _interpretEnergy(int energy) {
    if (energy >= 8) return 'Very high';
    if (energy >= 6) return 'Good';
    if (energy >= 4) return 'Moderate';
    return 'Low';
  }

  static String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[date.weekday - 1]}, ${date.day}/${date.month}/${date.year}';
  }
}

// Simple calendar event model (adjust based on your actual implementation)
class CalendarEvent {
  final String title;
  final String startTime;
  final String endTime;

  CalendarEvent({
    required this.title,
    required this.startTime,
    required this.endTime,
  });
}
```

---

### Step 3: Core Logic

**File:** `lib/features/life_coach/ai/daily_plan_generator.dart`

```dart
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../core/ai/ai_service.dart';
import '../../../core/utils/result.dart';
import '../domain/repositories/goals_repository.dart';
import '../domain/repositories/check_in_repository.dart';
import '../data/repositories/daily_plan_repository.dart';
import '../../profile/domain/repositories/preferences_repository.dart';
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

  Future<Result<DailyPlan>> generatePlan({
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

      return Result.success(plan);
    } catch (e, stackTrace) {
      return Result.failure(
        'Failed to generate daily plan: ${e.toString()}',
        stackTrace,
      );
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
      date: date,
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
```

---

### Step 4: Local Storage (Drift)

**File:** `lib/features/life_coach/data/models/daily_plan_dto.dart`

```dart
import 'package:drift/drift.dart';
import '../../ai/models/daily_plan.dart';
import '../../ai/models/plan_task.dart';
import 'dart:convert';

class DailyPlans extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get tasksJson => text()();  // JSON array
  TextColumn get dailyTheme => text()();
  TextColumn get motivationalQuote => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get source => intEnum<PlanSource>()();
  TextColumn get metadataJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

extension DailyPlanDtoExtension on DailyPlansCompanion {
  static DailyPlansCompanion fromEntity(DailyPlan plan) {
    return DailyPlansCompanion(
      id: Value(plan.id),
      date: Value(plan.date),
      tasksJson: Value(jsonEncode(plan.tasks.map((t) => t.toJson()).toList())),
      dailyTheme: Value(plan.dailyTheme),
      motivationalQuote: Value(plan.motivationalQuote),
      createdAt: Value(plan.createdAt),
      source: Value(plan.source),
      metadataJson: Value(plan.metadata != null ? jsonEncode(plan.metadata) : null),
    );
  }
}

extension DailyPlanDataExtension on DailyPlan {
  static DailyPlan fromDto(DailyPlansData data) {
    return DailyPlan(
      id: data.id,
      date: data.date,
      tasks: (jsonDecode(data.tasksJson) as List)
          .map((json) => PlanTask.fromJson(json))
          .toList(),
      dailyTheme: data.dailyTheme,
      motivationalQuote: data.motivationalQuote,
      createdAt: data.createdAt,
      source: data.source,
      metadata: data.metadataJson != null ? jsonDecode(data.metadataJson!) : null,
    );
  }
}
```

**File:** `lib/features/life_coach/data/repositories/daily_plan_repository.dart`

```dart
import '../../../../core/database/app_database.dart';
import '../../ai/models/daily_plan.dart';
import '../models/daily_plan_dto.dart';

class DailyPlanRepository {
  final AppDatabase _db;

  DailyPlanRepository(this._db);

  Future<void> savePlan(DailyPlan plan) async {
    await _db.into(_db.dailyPlans).insert(
          DailyPlanDtoExtension.fromEntity(plan),
          mode: InsertMode.replace,
        );
  }

  Future<DailyPlan?> getPlanForDate(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final query = _db.select(_db.dailyPlans)
      ..where((p) => p.date.equals(dateOnly))
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
      ..limit(1);

    final result = await query.getSingleOrNull();

    return result != null ? DailyPlanDataExtension.fromDto(result) : null;
  }

  Future<List<DailyPlan>> getRecentPlans({int limit = 7}) async {
    final query = _db.select(_db.dailyPlans)
      ..orderBy([(p) => OrderingTerm.desc(p.date)])
      ..limit(limit);

    final results = await query.get();

    return results.map((dto) => DailyPlanDataExtension.fromDto(dto)).toList();
  }

  Future<void> deletePlan(String planId) async {
    await (_db.delete(_db.dailyPlans)..where((p) => p.id.equals(planId))).go();
  }
}
```

---

### Step 5: Riverpod Providers

**File:** `lib/features/life_coach/ai/providers/daily_plan_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../domain/repositories/goals_repository.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../../data/repositories/daily_plan_repository.dart';
import '../../../profile/domain/repositories/preferences_repository.dart';
import '../daily_plan_generator.dart';
import '../models/daily_plan.dart';

part 'daily_plan_provider.g.dart';

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

    final generator = ref.read(dailyPlanGeneratorProvider);
    final result = await generator.generatePlan();

    result.when(
      success: (plan) {
        state = AsyncValue.data(plan);
      },
      failure: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
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
}
```

---

### Step 6: UI Implementation

**File:** `lib/features/life_coach/presentation/pages/daily_plan_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai/providers/daily_plan_provider.dart';
import '../widgets/ai_generating_animation.dart';
import '../widgets/task_card.dart';

class DailyPlanPage extends ConsumerWidget {
  const DailyPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(dailyPlanNotifierProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(dailyPlanNotifierProvider().notifier).generatePlan();
            },
            tooltip: 'Regenerate Plan',
          ),
        ],
      ),
      body: planAsync.when(
        loading: () => const AIGeneratingAnimation(),
        error: (error, stack) => _buildErrorState(context, ref, error),
        data: (plan) {
          if (plan == null) {
            return _buildEmptyState(context, ref);
          }
          return _buildPlanView(context, ref, plan);
        },
      ),
    );
  }

  Widget _buildPlanView(BuildContext context, WidgetRef ref, DailyPlan plan) {
    return Column(
      children: [
        // Header with theme & quote
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.dailyTheme,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (plan.motivationalQuote != null) ...[
                const SizedBox(height: 8),
                Text(
                  '"${plan.motivationalQuote}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ],
          ),
        ),

        // Task list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plan.tasks.length,
            itemBuilder: (context, index) {
              final task = plan.tasks[index];
              return TaskCard(
                task: task,
                onComplete: () {
                  ref
                      .read(dailyPlanNotifierProvider().notifier)
                      .markTaskComplete(task.id);
                },
              );
            },
          ),
        ),

        // Stats footer
        _buildStatsFooter(context, plan),
      ],
    );
  }

  Widget _buildStatsFooter(BuildContext context, DailyPlan plan) {
    final completedCount = plan.tasks.where((t) => t.isCompleted).length;
    final totalDuration = plan.tasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedDuration,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(
            icon: Icons.check_circle,
            label: 'Completed',
            value: '$completedCount/${plan.tasks.length}',
          ),
          _StatChip(
            icon: Icons.access_time,
            label: 'Total Time',
            value: '${totalDuration ~/ 60}h ${totalDuration % 60}m',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No plan for today',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Let AI generate a personalized plan for you',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(dailyPlanNotifierProvider().notifier).generatePlan();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Failed to generate plan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(dailyPlanNotifierProvider().notifier).generatePlan();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
```

**File:** `lib/features/life_coach/presentation/widgets/task_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../ai/models/plan_task.dart';

class TaskCard extends StatelessWidget {
  final PlanTask task;
  final VoidCallback onComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: task.isCompleted ? null : (_) => onComplete(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(task.description),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _Chip(
                  icon: Icons.access_time,
                  label: '${task.estimatedDuration} min',
                ),
                _Chip(
                  icon: Icons.schedule,
                  label: task.suggestedTime,
                ),
                _Chip(
                  icon: Icons.category,
                  label: task.category.name,
                  color: _getCategoryColor(task.category),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.why,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.fitness:
        return Colors.red;
      case TaskCategory.productivity:
        return Colors.blue;
      case TaskCategory.wellness:
        return Colors.green;
      case TaskCategory.personal:
        return Colors.purple;
      case TaskCategory.social:
        return Colors.orange;
    }
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _Chip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
```

---

### Step 7: Testing

**File:** `test/features/life_coach/ai/daily_plan_generator_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gym_app/features/life_coach/ai/daily_plan_generator.dart';

void main() {
  group('DailyPlanGenerator', () {
    late DailyPlanGenerator generator;
    late MockAIService mockAI;

    setUp(() {
      mockAI = MockAIService();
      generator = DailyPlanGenerator(aiService: mockAI, ...);
    });

    test('generates plan with 6-8 tasks', () async {
      when(mockAI.generateCompletion(...)).thenAnswer(
        (_) async => AIResponse(content: mockPlanJson),
      );

      final result = await generator.generatePlan();

      expect(result.isSuccess, true);
      expect(result.data.tasks.length, inRange(6, 8));
    });

    test('includes motivational quote', () async {
      when(mockAI.generateCompletion(...)).thenAnswer(
        (_) async => AIResponse(content: mockPlanJson),
      );

      final result = await generator.generatePlan();

      expect(result.data.motivationalQuote, isNotNull);
    });
  });
}
```

---

## Story 2.4: AI Conversational Coaching

### Implementation - see full details in CLAUDE.md context above

**Key Files:**
1. `lib/features/life_coach/ai/conversational_coach.dart`
2. `lib/features/life_coach/ai/models/chat_message.dart`
3. `lib/features/life_coach/presentation/pages/coach_chat_page.dart`

---

## Story 2.9: Goal Suggestions AI

### Implementation - see full details in CLAUDE.md context above

**Key Files:**
1. `lib/features/life_coach/ai/goal_suggester.dart`
2. `lib/features/life_coach/presentation/pages/goal_suggestions_page.dart`

---

## Testing Checklist

- [ ] Unit tests: DailyPlanGenerator (plan generation, error handling)
- [ ] Unit tests: ConversationalCoach (message handling, context)
- [ ] Unit tests: GoalSuggester (suggestion parsing)
- [ ] Widget tests: DailyPlanPage (loading, error, data states)
- [ ] Widget tests: CoachChatPage (message rendering)
- [ ] Integration test: E2E flow (generate plan → chat → accept suggestion)
- [ ] Coverage: ≥80% for AI features

---

## Commands

```bash
# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test test/features/life_coach/ai/

# Run app
flutter run
```

---

## Next Steps

Po ukończeniu BATCH 2:
✅ Przejdź do `02-batch-4-charts-smart-features.md`
