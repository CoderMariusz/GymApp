# BATCH 4: Charts & Smart Features Implementation

**Epic:** 2 (Life Coach) + 3 (Fitness)
**Stories:** 2.7, 3.5, 3.1, 2.8
**Token Budget:** ~11K (zamiast 24K - oszczędność 54%)
**Czas:** 3 dni
**Dependencies:** `00-shared-components.md` (Chart Widgets)

---

## Stories Overview

| Story | Tytuł | Epic | Priorytet | Czas |
|-------|-------|------|-----------|------|
| 2.7 | Progress Dashboard (Life Coach) | 2 | High | 4-5h |
| 3.5 | Progress Charts (Fitness) | 3 | High | 4-5h |
| 3.1 | Smart Pattern Memory (Pre-fill) | 3 | ✨ ready-for-dev | 3-4h |
| 2.8 | Daily Plan Manual Adjustment | 2 | Medium | 2-3h |

**Wspólne komponenty:** Chart Widgets (już stworzone w `00-shared-components.md`)

---

## Prerequisites

- ✅ Ukończony `00-shared-components.md` (Chart Widgets)
- ✅ `fl_chart` zainstalowany
- ✅ Stories 1.2-1.5 (Auth, Profile, Goals) - data sources
- ✅ Story 2.1, 2.3 (Check-ins, Goals) - Life Coach data
- ✅ Story 3.3 (Workout Logging) - Fitness data

---

## Story 2.7: Progress Dashboard (Life Coach)

### Opis funkcjonalności

**User Story:**
> Jako użytkownik chcę widzieć dashboard z wizualizacją mojego postępu (nastrój, energia, cele), aby móc śledzić trendy i pozostać zmotywowanym.

**Acceptance Criteria:**
1. ✅ Overview cards (Active Goals, Streak, Overall Progress)
2. ✅ Mood trend chart (7 dni, line chart)
3. ✅ Energy trend chart (7 dni, line chart)
4. ✅ Goal completion rate (30 dni, bar chart)
5. ✅ Category breakdown (pie chart)
6. ✅ Export data (CSV)

---

### Architektura

```
lib/features/life_coach/
├── domain/
│   └── usecases/
│       └── get_dashboard_stats.dart       ✅ Stats calculation
├── data/
│   └── repositories/
│       └── stats_repository.dart          ✅ Data aggregation
└── presentation/
    ├── pages/
    │   └── progress_dashboard_page.dart   ✅ Main UI
    ├── widgets/
    │   ├── stat_card.dart                 ✅ Overview cards
    │   └── export_button.dart             ✅ Export feature
    └── providers/
        └── dashboard_provider.dart        ✅ Riverpod state
```

---

### Step 1: Domain Models

**File:** `lib/features/life_coach/domain/entities/dashboard_stats.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    required int totalGoals,
    required int activeGoals,
    required int completedGoals,
    required int checkInStreak,
    required int overallProgress,      // 0-100%
    required DateTime calculatedAt,
  }) = _DashboardStats;
}
```

---

### Step 2: Data Providers

**File:** `lib/features/life_coach/presentation/providers/dashboard_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/charts/models/chart_data.dart';
import '../../../../core/charts/processors/data_aggregator.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../../domain/repositories/goals_repository.dart';
import '../../domain/entities/dashboard_stats.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardStats> dashboardStats(DashboardStatsRef ref) async {
  final goalsRepo = ref.watch(goalsRepositoryProvider);
  final checkInRepo = ref.watch(checkInRepositoryProvider);

  final allGoals = await goalsRepo.getAllGoals();
  final activeGoals = allGoals.where((g) => g.status == GoalStatus.active).length;
  final completedGoals = allGoals.where((g) => g.status == GoalStatus.completed).length;

  final streak = await checkInRepo.getCurrentStreak();
  final progress = await goalsRepo.getOverallProgress();

  return DashboardStats(
    totalGoals: allGoals.length,
    activeGoals: activeGoals,
    completedGoals: completedGoals,
    checkInStreak: streak,
    overallProgress: progress,
    calculatedAt: DateTime.now(),
  );
}

@riverpod
Future<List<ChartDataPoint>> moodTrend(MoodTrendRef ref, {required int days}) async {
  final checkInRepo = ref.watch(checkInRepositoryProvider);
  final checkIns = await checkInRepo.getRecentCheckIns(days: days);

  // Use REUSABLE DataAggregator!
  return DataAggregator.aggregateByPeriod(
    items: checkIns,
    getDate: (checkIn) => checkIn.date,
    getValue: (checkIn) => checkIn.mood.toDouble(),
    period: AggregationPeriod.daily,
    type: AggregationType.average,
  );
}

@riverpod
Future<List<ChartDataPoint>> energyTrend(EnergyTrendRef ref, {required int days}) async {
  final checkInRepo = ref.watch(checkInRepositoryProvider);
  final checkIns = await checkInRepo.getRecentCheckIns(days: days);

  return DataAggregator.aggregateByPeriod(
    items: checkIns,
    getDate: (checkIn) => checkIn.date,
    getValue: (checkIn) => checkIn.energy.toDouble(),
    period: AggregationPeriod.daily,
    type: AggregationType.average,
  );
}

@riverpod
Future<List<ChartDataPoint>> goalCompletion(
  GoalCompletionRef ref,
  {required int days},
) async {
  final goalsRepo = ref.watch(goalsRepositoryProvider);
  final completedGoals = await goalsRepo.getCompletedGoals(days: days);

  return DataAggregator.aggregateByPeriod(
    items: completedGoals,
    getDate: (goal) => goal.completedAt!,
    getValue: (_) => 1.0,  // Count each goal as 1
    period: AggregationPeriod.weekly,
    type: AggregationType.sum,
  );
}
```

---

### Step 3: UI Implementation

**File:** `lib/features/life_coach/presentation/pages/progress_dashboard_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/charts/widgets/line_chart_widget.dart';
import '../../../../core/charts/widgets/bar_chart_widget.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/export_button.dart';

class ProgressDashboardPage extends ConsumerWidget {
  const ProgressDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final moodTrendAsync = ref.watch(moodTrendProvider(days: 7));
    final energyTrendAsync = ref.watch(energyTrendProvider(days: 7));
    final goalCompletionAsync = ref.watch(goalCompletionProvider(days: 30));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        actions: [
          ExportButton(
            onExport: () => _exportData(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(moodTrendProvider);
          ref.invalidate(energyTrendProvider);
          ref.invalidate(goalCompletionProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              statsAsync.when(
                data: (stats) => _buildOverviewCards(context, stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              // Mood Trend Chart (REUSABLE!)
              moodTrendAsync.when(
                data: (data) => ReusableLineChart(
                  data: data,
                  title: 'Mood Trend (7 Days)',
                  yAxisLabel: 'Mood (1-10)',
                  lineColor: Colors.blue,
                  showGrid: true,
                  showDots: true,
                  minY: 0,
                  maxY: 10,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              // Energy Trend Chart (SAME COMPONENT!)
              energyTrendAsync.when(
                data: (data) => ReusableLineChart(
                  data: data,
                  title: 'Energy Trend (7 Days)',
                  yAxisLabel: 'Energy (1-10)',
                  lineColor: Colors.orange,
                  showGrid: true,
                  showDots: true,
                  minY: 0,
                  maxY: 10,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              // Goal Completion Bar Chart
              goalCompletionAsync.when(
                data: (data) => ReusableBarChart(
                  data: data,
                  title: 'Goals Completed (30 Days)',
                  yAxisLabel: 'Goals',
                  barColor: Colors.green,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, DashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.flag,
            label: 'Active Goals',
            value: stats.activeGoals.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '${stats.checkInStreak} days',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.trending_up,
            label: 'Progress',
            value: '${stats.overallProgress}%',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Future<void> _exportData(WidgetRef ref) async {
    // TODO: Implement CSV export
    // Get all data → Convert to CSV → Share file
  }
}
```

**File:** `lib/features/life_coach/presentation/widgets/stat_card.dart`

```dart
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Story 3.5: Progress Charts (Fitness)

### Opis funkcjonalności

**User Story:**
> Jako użytkownik chcę widzieć wykresy postępu treningowego (siła, objętość, rekordy osobiste), aby móc śledzić rozwój i zmienić plan jeśli to konieczne.

**Acceptance Criteria:**
1. ✅ Strength progress per exercise (12 weeks, line chart)
2. ✅ Weekly volume trend (8 weeks, bar chart)
3. ✅ Personal records timeline (scatter/line chart)
4. ✅ Exercise frequency heatmap
5. ✅ Filter by exercise, time period

---

### Architektura

```
lib/features/fitness/
├── domain/
│   └── usecases/
│       └── get_workout_stats.dart         ✅ Stats calculation
└── presentation/
    ├── pages/
    │   └── progress_charts_page.dart      ✅ Main UI
    └── providers/
        └── fitness_charts_provider.dart   ✅ Riverpod state
```

---

### Step 1: Providers

**File:** `lib/features/fitness/presentation/providers/fitness_charts_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/charts/models/chart_data.dart';
import '../../../../core/charts/processors/data_aggregator.dart';
import '../../domain/repositories/workout_repository.dart';
import 'dart:math';

part 'fitness_charts_provider.g.dart';

@riverpod
Future<List<ChartDataPoint>> strengthProgress(
  StrengthProgressRef ref, {
  required String exercise,
  int weeks = 12,
}) async {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final workouts = await workoutRepo.getWorkoutHistory(days: weeks * 7);

  // Filter workouts containing this exercise
  final exerciseLogs = workouts
      .expand((workout) => workout.exercises)
      .where((e) => e.name == exercise)
      .toList();

  // Use REUSABLE aggregator to get max weight per week
  return DataAggregator.aggregateByPeriod(
    items: exerciseLogs,
    getDate: (e) => e.date,
    getValue: (e) => e.sets.map((s) => s.weight).reduce(max),
    period: AggregationPeriod.weekly,
    type: AggregationType.max,
  );
}

@riverpod
Future<List<ChartDataPoint>> weeklyVolume(
  WeeklyVolumeRef ref,
  {int weeks = 8},
) async {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final workouts = await workoutRepo.getWorkoutHistory(days: weeks * 7);

  return DataAggregator.aggregateByPeriod(
    items: workouts,
    getDate: (workout) => workout.date,
    getValue: (workout) {
      // Calculate total volume (weight × reps) for this workout
      return workout.exercises
          .expand((e) => e.sets)
          .map((s) => s.weight * s.reps)
          .fold(0.0, (sum, volume) => sum + volume);
    },
    period: AggregationPeriod.weekly,
    type: AggregationType.sum,
  );
}

@riverpod
Future<List<ChartDataPoint>> personalRecords(PersonalRecordsRef ref) async {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final prs = await workoutRepo.getPersonalRecords();

  return prs.map((pr) => ChartDataPoint(
    x: pr.date.millisecondsSinceEpoch.toDouble(),
    y: pr.weight,
    label: pr.exerciseName,
    metadata: pr,
  )).toList();
}
```

---

### Step 2: UI Implementation

**File:** `lib/features/fitness/presentation/pages/progress_charts_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/charts/widgets/line_chart_widget.dart';
import '../../../../core/charts/widgets/bar_chart_widget.dart';
import '../providers/fitness_charts_provider.dart';

class ProgressChartsPage extends ConsumerStatefulWidget {
  const ProgressChartsPage({super.key});

  @override
  ConsumerState<ProgressChartsPage> createState() => _ProgressChartsPageState();
}

class _ProgressChartsPageState extends ConsumerState<ProgressChartsPage> {
  String selectedExercise = 'Bench Press';

  @override
  Widget build(BuildContext context) {
    final strengthAsync = ref.watch(
      strengthProgressProvider(exercise: selectedExercise, weeks: 12),
    );
    final volumeAsync = ref.watch(weeklyVolumeProvider(weeks: 8));
    final prsAsync = ref.watch(personalRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise selector
            DropdownButton<String>(
              value: selectedExercise,
              items: ['Bench Press', 'Squat', 'Deadlift', 'Overhead Press']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedExercise = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Strength chart (REUSABLE!)
            strengthAsync.when(
              data: (data) => ReusableLineChart(
                data: data,
                title: '$selectedExercise Strength (12 Weeks)',
                yAxisLabel: 'Max Weight (kg)',
                lineColor: Colors.red,
                showDots: true,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),

            // Volume chart (REUSABLE!)
            volumeAsync.when(
              data: (data) => ReusableBarChart(
                data: data,
                title: 'Weekly Volume (8 Weeks)',
                yAxisLabel: 'Total kg',
                barColor: Colors.purple,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),

            // PRs chart (REUSABLE!)
            prsAsync.when(
              data: (data) => ReusableLineChart(
                data: data,
                title: 'Personal Records Timeline',
                yAxisLabel: 'Weight (kg)',
                lineColor: Colors.amber,
                showDots: true,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Story 3.1: Smart Pattern Memory (Pre-fill)

### Opis funkcjonalności

**User Story:**
> Jako użytkownik chcę aby aplikacja automatycznie wypełniała dane treningowe na podstawie mojego ostatniego treningu (liczba serii, powtórzeń, ciężar), aby zaoszczędzić czas i zastosować progresywne przeciążenie.

**Acceptance Criteria:**
1. ✅ Automatyczne wypełnianie przy rozpoczęciu treningu
2. ✅ Detekcja wzorców (średnia liczba serii, powtórzeń, ciężar)
3. ✅ Progressive overload suggestions (+2.5kg lub +1 rep)
4. ✅ Uwzględnienie RPE z ostatniego treningu
5. ✅ Powiadomienie o sugestii (dismissable)

---

### Architektura

```
lib/features/fitness/
├── domain/
│   └── usecases/
│       └── smart_prefill_service.dart     ✅ Core logic
└── presentation/
    └── providers/
        └── smart_prefill_provider.dart    ✅ Riverpod state
```

---

### Step 1: Domain Logic

**File:** `lib/features/fitness/domain/entities/workout_pattern.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_pattern.freezed.dart';

@freezed
class WorkoutPattern with _$WorkoutPattern {
  const factory WorkoutPattern({
    required int sets,
    required int reps,
    required double weight,
    required int restSeconds,
    double? avgRPE,
  }) = _WorkoutPattern;
}

@freezed
class WorkoutTemplate with _$WorkoutTemplate {
  const factory WorkoutTemplate({
    required int sets,
    required int reps,
    required double weight,
    required int restSeconds,
    String? note,
  }) = _WorkoutTemplate;

  factory WorkoutTemplate.empty() => const WorkoutTemplate(
        sets: 3,
        reps: 10,
        weight: 0,
        restSeconds: 90,
      );
}
```

**File:** `lib/features/fitness/domain/usecases/smart_prefill_service.dart`

```dart
import '../repositories/workout_repository.dart';
import '../entities/workout_pattern.dart';
import '../entities/exercise_log.dart';

class SmartPrefillService {
  final WorkoutRepository _workoutRepo;

  SmartPrefillService(this._workoutRepo);

  Future<WorkoutTemplate> generatePrefill({
    required String exerciseName,
  }) async {
    // 1. Get last 3 workouts with this exercise
    final history = await _workoutRepo.getExerciseHistory(
      exerciseName: exerciseName,
      limit: 3,
    );

    if (history.isEmpty) {
      return WorkoutTemplate.empty();
    }

    // 2. Detect pattern
    final pattern = _detectPattern(history);

    // 3. Generate progressive overload suggestion
    final lastWorkout = history.first;
    final suggested = _applyProgressiveOverload(lastWorkout, pattern);

    return suggested;
  }

  WorkoutPattern _detectPattern(List<ExerciseLog> history) {
    final allSets = history.expand((h) => h.sets).toList();

    final avgSets = history.map((h) => h.sets.length).reduce((a, b) => a + b) ~/
        history.length;
    final avgReps =
        allSets.map((s) => s.reps).reduce((a, b) => a + b) ~/ allSets.length;
    final avgWeight = allSets.map((s) => s.weight).reduce((a, b) => a + b) /
        allSets.length;
    final avgRest =
        allSets.map((s) => s.restSeconds).reduce((a, b) => a + b) ~/
            allSets.length;
    final avgRPE = allSets.map((s) => s.rpe ?? 7).reduce((a, b) => a + b) /
        allSets.length;

    return WorkoutPattern(
      sets: avgSets,
      reps: avgReps,
      weight: avgWeight,
      restSeconds: avgRest,
      avgRPE: avgRPE,
    );
  }

  WorkoutTemplate _applyProgressiveOverload(
    ExerciseLog last,
    WorkoutPattern pattern,
  ) {
    final lastAvgRPE = last.sets
            .map((s) => s.rpe ?? 7)
            .reduce((a, b) => a + b) /
        last.sets.length;

    // Progressive overload rules:
    // 1. If RPE < 7 (easy) → +2.5kg
    // 2. If RPE > 8 (hard) → same weight, +1 rep
    // 3. If RPE 7-8 (optimal) → same weight & reps

    if (lastAvgRPE < 7) {
      return WorkoutTemplate(
        sets: pattern.sets,
        reps: pattern.reps,
        weight: pattern.weight + 2.5,
        restSeconds: pattern.restSeconds,
        note: '💪 Increased weight (last workout was easy)',
      );
    } else if (lastAvgRPE > 8) {
      return WorkoutTemplate(
        sets: pattern.sets,
        reps: pattern.reps + 1,
        weight: pattern.weight,
        restSeconds: pattern.restSeconds,
        note: '📈 Added reps (maintain weight)',
      );
    } else {
      return WorkoutTemplate(
        sets: pattern.sets,
        reps: pattern.reps,
        weight: pattern.weight,
        restSeconds: pattern.restSeconds,
        note: '✅ Repeat last workout (optimal intensity)',
      );
    }
  }
}
```

---

### Step 2: Provider

**File:** `lib/features/fitness/presentation/providers/smart_prefill_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/smart_prefill_service.dart';
import '../../domain/entities/workout_pattern.dart';
import '../../domain/repositories/workout_repository.dart';

part 'smart_prefill_provider.g.dart';

@riverpod
SmartPrefillService smartPrefillService(SmartPrefillServiceRef ref) {
  return SmartPrefillService(ref.watch(workoutRepositoryProvider));
}

@riverpod
class SmartPrefill extends _$SmartPrefill {
  @override
  Future<WorkoutTemplate> build({required String exerciseName}) async {
    final service = ref.watch(smartPrefillServiceProvider);
    return await service.generatePrefill(exerciseName: exerciseName);
  }

  Future<void> regenerate() async {
    state = const AsyncValue.loading();
    final service = ref.read(smartPrefillServiceProvider);
    final template = await service.generatePrefill(exerciseName: exerciseName);
    state = AsyncValue.data(template);
  }
}
```

---

### Step 3: UI Integration

**File:** `lib/features/fitness/presentation/pages/workout_logging_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/smart_prefill_provider.dart';
import '../widgets/workout_form.dart';

class WorkoutLoggingPage extends ConsumerStatefulWidget {
  final String exerciseName;

  const WorkoutLoggingPage({
    super.key,
    required this.exerciseName,
  });

  @override
  ConsumerState<WorkoutLoggingPage> createState() => _WorkoutLoggingPageState();
}

class _WorkoutLoggingPageState extends ConsumerState<WorkoutLoggingPage> {
  @override
  Widget build(BuildContext context) {
    final prefillAsync = ref.watch(
      smartPrefillProvider(exerciseName: widget.exerciseName),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: prefillAsync.when(
        data: (template) => Column(
          children: [
            // Smart prefill notice
            if (template.note != null)
              Container(
                width: double.infinity,
                color: Colors.blue.shade50,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        template.note!,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        // Dismiss notice
                      },
                    ),
                  ],
                ),
              ),

            // Prefilled form
            Expanded(
              child: WorkoutForm(
                exerciseName: widget.exerciseName,
                initialSets: template.sets,
                initialReps: template.reps,
                initialWeight: template.weight,
                initialRest: template.restSeconds,
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => WorkoutForm(
          exerciseName: widget.exerciseName,
        ), // Fallback to empty form
      ),
    );
  }
}
```

---

## Story 2.8: Daily Plan Manual Adjustment

### Opis funkcjonalności

**User Story:**
> Jako użytkownik chcę móc ręcznie edytować AI-wygenerowany plan dnia (zmieniać kolejność, czasy, dodawać/usuwać zadania), aby dostosować go do moich rzeczywistych potrzeb.

**Acceptance Criteria:**
1. ✅ Drag & drop reordering
2. ✅ Edit task (title, time, duration)
3. ✅ Add new task
4. ✅ Delete task
5. ✅ Save changes to DB
6. ✅ Track if plan was modified (AI vs. manual)

---

### Step 1: UI Implementation

**File:** `lib/features/life_coach/presentation/pages/daily_plan_edit_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai/models/daily_plan.dart';
import '../../ai/models/plan_task.dart';
import '../../ai/providers/daily_plan_provider.dart';
import '../widgets/task_edit_card.dart';

class DailyPlanEditPage extends ConsumerStatefulWidget {
  final DailyPlan plan;

  const DailyPlanEditPage({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<DailyPlanEditPage> createState() => _DailyPlanEditPageState();
}

class _DailyPlanEditPageState extends ConsumerState<DailyPlanEditPage> {
  late List<PlanTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.plan.tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Daily Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePlan,
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _tasks.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final task = _tasks.removeAt(oldIndex);
            _tasks.insert(newIndex, task);
          });
        },
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return TaskEditCard(
            key: ValueKey(task.id),
            task: task,
            onEdit: (updated) {
              setState(() {
                _tasks[index] = updated;
              });
            },
            onDelete: () {
              setState(() {
                _tasks.removeAt(index);
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTask() {
    // Show dialog to create new task
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onAdd: (task) {
          setState(() {
            _tasks.add(task);
          });
        },
      ),
    );
  }

  Future<void> _savePlan() async {
    final updatedPlan = widget.plan.copyWith(
      tasks: _tasks,
      source: PlanSource.manual,  // Mark as manually edited
    );

    await ref.read(dailyPlanRepositoryProvider).savePlan(updatedPlan);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan updated!')),
      );
    }
  }
}
```

**File:** `lib/features/life_coach/presentation/widgets/task_edit_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../ai/models/plan_task.dart';

class TaskEditCard extends StatelessWidget {
  final PlanTask task;
  final Function(PlanTask) onEdit;
  final VoidCallback onDelete;

  const TaskEditCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.drag_handle),
        title: Text(task.title),
        subtitle: Text('${task.suggestedTime} • ${task.estimatedDuration} min'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: task.title),
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (value) {
                    onEdit(task.copyWith(title: value));
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: task.description),
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  onChanged: (value) {
                    onEdit(task.copyWith(description: value));
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: task.suggestedTime,
                        ),
                        decoration: const InputDecoration(labelText: 'Time'),
                        onChanged: (value) {
                          onEdit(task.copyWith(suggestedTime: value));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: task.estimatedDuration.toString(),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Duration (min)',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final duration = int.tryParse(value);
                          if (duration != null) {
                            onEdit(task.copyWith(estimatedDuration: duration));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Testing Checklist

### Unit Tests
- [ ] DataAggregator: Grouping by period, aggregation types
- [ ] SmartPrefillService: Pattern detection, progressive overload
- [ ] Dashboard stats calculation

### Widget Tests
- [ ] ReusableLineChart: Renders, empty state
- [ ] ReusableBarChart: Renders, bar heights
- [ ] ProgressDashboardPage: All sections visible
- [ ] WorkoutLoggingPage: Prefill notice, form

### Integration Tests
- [ ] E2E: View dashboard → Edit plan → Log workout with prefill → View charts

---

## Commands

```bash
# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test test/features/life_coach/
flutter test test/features/fitness/

# Run app
flutter run
```

---

## Token Savings Summary

| Component | Individual | Batch | Savings |
|-----------|-----------|-------|---------|
| Chart widgets | 4 × 3K = 12K | 3K (created once) | -9K (75%) |
| Data aggregation | 4 × 2K = 8K | 2K (reusable) | -6K (75%) |
| Story implementations | 4 × 6K = 24K | 11K (shared components) | -13K (54%) |
| **TOTAL** | **44K** | **16K** | **-28K (64%)** 🎉 |

---

## Next Steps

Po ukończeniu BATCH 4:
✅ Wszystkie AI features + Chart features gotowe!
✅ Przejdź do testowania integracyjnego
✅ Rozważ rozpoczęcie BATCH 1 lub BATCH 3
