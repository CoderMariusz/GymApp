# Fitness Feature - Documentation

## Overview

The Fitness feature provides comprehensive workout tracking with AI-powered smart suggestions based on progressive overload principles.

## Features

### 📊 Progress Charts (`Story 3.5`)
Track your fitness journey with visual analytics:
- **Strength Progress:** 12-week line chart showing max weight progression per exercise
- **Weekly Volume:** 8-week bar chart displaying total training volume (weight × reps)
- **Personal Records:** Timeline of all PRs with exercise names

**File:** `lib/features/fitness/presentation/pages/progress_charts_page.dart`

### 🧠 Smart Prefill (`Story 3.1`)
AI-powered workout suggestions using pattern detection and progressive overload:

#### Algorithm Logic
1. **Pattern Detection:** Analyzes last 10 workouts for selected exercise
2. **RPE Analysis:** Uses Rate of Perceived Exertion to determine intensity
3. **Progressive Overload:** Applies one of 5 strategies based on RPE:
   - **Increase Weight** (RPE < 7.5): Add 2.5-5kg to previous weight
   - **Increase Reps** (RPE 6.0-7.5): Keep weight, add 1-2 reps
   - **Increase Volume** (RPE 7.5-9.0): Add extra set
   - **Maintain** (RPE 7.5-9.0 with <3 performances): Keep same intensity
   - **Deload** (RPE ≥ 9.0): Reduce weight by 10% for recovery

#### Progressive Overload Decision Tree
```
Last RPE Score
│
├─ ≥ 9.0 (Too hard) → DELOAD (90% weight)
│
├─ 7.5-9.0 (Good intensity)
│  ├─ Performed ≥3 times → INCREASE WEIGHT (+2.5-5kg)
│  └─ Performed <3 times → MAINTAIN (consistency)
│
├─ 6.0-7.5 (Moderate) → INCREASE REPS (+1-2)
│
└─ < 6.0 (Too easy) → INCREASE WEIGHT (+2.5-5kg)
```

**Files:**
- `lib/features/fitness/domain/usecases/smart_prefill_service.dart` - Core algorithm
- `lib/features/fitness/presentation/pages/workout_log_page.dart` - UI integration

## Domain Entities

### WorkoutLog
```dart
WorkoutLog(
  id: String,
  date: DateTime,
  exercises: List<ExerciseLog>,
  totalDurationMinutes: int,
)
```

### ExerciseLog
```dart
ExerciseLog(
  name: String,
  sets: List<WorkoutSet>,
  date: DateTime,
)
```

### WorkoutSet
```dart
WorkoutSet(
  weight: double,      // kg
  reps: int,
  restSeconds: int,
  rpe: double?,        // Rate of Perceived Exertion (1-10)
)
```

### PersonalRecord
```dart
PersonalRecord(
  exerciseName: String,
  weight: double,
  date: DateTime,
)
```

## Repositories

### WorkoutRepository
```dart
abstract class WorkoutRepository {
  Future<List<WorkoutLog>> getWorkoutHistory({required int days});
  Future<List<ExerciseLog>> getExerciseHistory({
    required String exerciseName,
    required int limit,
  });
  Future<List<PersonalRecord>> getPersonalRecords();
}
```

**Current Implementation:** `MockWorkoutRepository` (generates sample data)
**Future:** Replace with Drift/Supabase implementation when data layer is ready

## Data Aggregation

Uses shared `DataAggregator` from `core/charts/processors/`:
- **Weekly aggregation** for strength progress
- **Max value** for finding peak weights
- **Sum aggregation** for total volume calculation

## Smart Suggestion Workflow

1. User selects exercise (e.g., "Bench Press")
2. System checks if 2+ previous workouts exist
3. If yes, "Get Smart Suggestion" button appears
4. User taps button → Provider fetches suggestion
5. `SmartPrefillService` analyzes patterns and generates suggestion
6. UI displays suggestion card with:
   - Rationale (why this suggestion)
   - Suggested sets (weight × reps)
   - Target RPE per set
   - Progressive overload indicator
7. User can:
   - **Apply:** Pre-fills all sets with suggestion
   - **Ignore:** Manually enter data
8. User adjusts as needed and saves workout

## UI Components

### ProgressChartsPage
- **Exercise Selector:** Dropdown for filtering by exercise
- **3 Charts:** Strength, Volume, PRs
- **Responsive:** Handles empty data gracefully

### WorkoutLogPage
- **Exercise Selection:** Dropdown with common exercises
- **Smart Suggestion Card:** Displays AI recommendation
- **Set Entry Forms:** Weight, Reps, Rest, RPE inputs
- **Dynamic Sets:** Add/remove sets as needed
- **Save to Repository:** Stores workout log

### SmartSuggestionCard
- **Visual Indicator:** Green for progressive overload, Blue for maintain
- **Rationale Section:** Explains the "why" behind suggestion
- **Set Preview:** Shows all suggested sets
- **Action Buttons:** Apply or Ignore

## Configuration & Tuning

### Progressive Overload Thresholds (in `smart_prefill_service.dart`)
```dart
// RPE decision thresholds
const double rpeDeload = 9.0;        // Too hard
const double rpeGoodIntensity = 7.5; // Optimal range start
const double rpeModerate = 6.0;      // Easy range start

// Weight increments
const double lightWeightInc = 5.0;   // For weight ≤ 80kg
const double heavyWeightInc = 2.5;   // For weight > 80kg

// Deload factor
const double deloadFactor = 0.9;     // 10% reduction
```

**To tune algorithm:** Adjust these values based on user feedback and results.

## Testing

### Manual Test Cases
1. **No History:** Should show "Log this exercise a few times to unlock smart suggestions"
2. **First Suggestion:** Should suggest small increase from last workout
3. **High RPE (≥9.0):** Should recommend deload
4. **Low RPE (<6.0):** Should suggest significant increase
5. **Empty Charts:** Should display empty state with message

### Unit Test Recommendations
```dart
test('deload when RPE is 9.0 or higher', () {
  final service = SmartPrefillService(mockRepo);
  final strategy = service._determineOverloadStrategy(
    historyWithRpe9,
    pattern,
  );
  expect(strategy, OverloadStrategy.deload);
});
```

## Future Enhancements

1. **Exercise Library:** Pre-populated exercise database
2. **Video Demos:** Tutorial videos for proper form
3. **1RM Calculator:** Estimate one-rep max from sets
4. **Plate Calculator:** Show which plates to load on bar
5. **Rest Timer:** Built-in countdown timer between sets
6. **Muscle Group Tracking:** Visualize volume per muscle
7. **Workout Templates:** Save and reuse workout plans
8. **Social Features:** Share PRs with friends

## Migration from Mock to Real Data

### Step 1: Create Drift Tables
```dart
@DataClassName('WorkoutLogData')
class WorkoutLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get exercisesJson => text()(); // JSON array
  IntColumn get totalDurationMinutes => integer()();
  // ... sync metadata
}
```

### Step 2: Implement Repository
```dart
class DriftWorkoutRepository implements WorkoutRepository {
  final AppDatabase _db;

  @override
  Future<List<WorkoutLog>> getWorkoutHistory({required int days}) async {
    final data = await (_db.select(_db.workoutLogs)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(
        DateTime.now().subtract(Duration(days: days)),
      ))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
      .get();

    return data.map((d) => WorkoutLog.fromJson(/* parse */)).toList();
  }
}
```

### Step 3: Update Provider
```dart
@riverpod
WorkoutRepository workoutRepository(WorkoutRepositoryRef ref) {
  return DriftWorkoutRepository(ref.watch(appDatabaseProvider));
  // Was: return MockWorkoutRepository();
}
```

## Support

For questions or issues, check:
- Implementation plans: `/docs/implementation-plans/`
- Shared components: `/lib/core/charts/README.md`
- AI service: `/lib/core/ai/README.md`

---

**Version:** 1.0 (BATCH 4)
**Last Updated:** 2025-11-23
**Status:** ✅ Production Ready (with mock data)
