# 🚀 BATCH 1: Foundation - Forms & Input Flows

## 📊 Overview

**Stories:** 4
**Estimated Time:** 2-3 days
**Token Savings:** ~60% (12K tokens saved)
**Dependencies:** Shared widgets (already created)

### Stories Included:
1. **2.1** Morning Check-In Flow (Life Coach)
2. **2.5** Evening Reflection Flow (Life Coach)
3. **3.3** Workout Logging with Rest Timer (Fitness)
4. **3.8** Quick Log (Rapid Entry) (Fitness)

---

## 🎯 Implementation Strategy

**Key Pattern:** All 4 stories share the same UI pattern:
- Form input with multiple fields
- Time picker
- Mood/energy slider
- Tag selection
- Validation + Submit

**Reusable Components (Already Created):**
- ✅ `lib/core/widgets/daily_input_form.dart`
- ✅ `lib/core/widgets/time_picker_widget.dart`
- ✅ `lib/core/widgets/submit_button_widget.dart`

---

## 📁 File Structure

```
lib/features/
├── life_coach/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── check_in_local_datasource.dart       # Drift operations
│   │   ├── models/
│   │   │   ├── check_in_model.dart                  # Freezed model
│   │   │   └── reflection_model.dart                # Freezed model
│   │   └── repositories/
│   │       └── check_in_repository_impl.dart        # Repository implementation
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── check_in_entity.dart                 # Freezed entity
│   │   │   └── reflection_entity.dart               # Freezed entity
│   │   ├── repositories/
│   │   │   └── check_in_repository.dart             # Repository interface
│   │   └── usecases/
│   │       ├── create_morning_checkin_usecase.dart
│   │       ├── create_evening_reflection_usecase.dart
│   │       └── get_todays_checkin_usecase.dart
│   └── presentation/
│       ├── pages/
│       │   ├── morning_check_in_page.dart           # Story 2.1
│       │   └── evening_reflection_page.dart         # Story 2.5
│       ├── providers/
│       │   └── check_in_provider.dart               # Riverpod state
│       └── widgets/
│           └── check_in_card.dart                   # Display widget
│
└── fitness/
    ├── data/
    │   ├── datasources/
    │   │   └── workout_local_datasource.dart        # Drift operations
    │   ├── models/
    │   │   ├── workout_log_model.dart               # Freezed model
    │   │   └── exercise_set_model.dart              # Freezed model
    │   └── repositories/
    │       └── workout_log_repository_impl.dart     # Repository implementation
    ├── domain/
    │   ├── entities/
    │   │   ├── workout_log_entity.dart              # Freezed entity
    │   │   └── exercise_set_entity.dart             # Freezed entity
    │   ├── repositories/
    │   │   └── workout_log_repository.dart          # Repository interface
    │   └── usecases/
    │       ├── create_workout_log_usecase.dart
    │       ├── quick_log_workout_usecase.dart
    │       └── get_workout_history_usecase.dart
    └── presentation/
        ├── pages/
        │   ├── workout_logging_page.dart            # Story 3.3
        │   └── quick_log_page.dart                  # Story 3.8
        ├── providers/
        │   └── workout_log_provider.dart            # Riverpod state
        └── widgets/
            ├── rest_timer_widget.dart               # Rest timer
            ├── exercise_set_input.dart              # Set input
            └── workout_summary_card.dart            # Summary
```

---

## 🗄️ Database Schema (Drift)

### CheckIns Table
```dart
class CheckIns extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get type => text()(); // 'morning' | 'evening'

  // Morning Check-In fields
  IntColumn get energyLevel => integer().nullable()();
  IntColumn get mood => integer().nullable()();
  TextColumn get intentions => text().nullable()();
  TextColumn get gratitude => text().nullable()();

  // Evening Reflection fields
  IntColumn get productivityRating => integer().nullable()();
  TextColumn get wins => text().nullable()();
  TextColumn get improvements => text().nullable()();
  TextColumn get tomorrowFocus => text().nullable()();

  // Common
  TextColumn get tags => text().nullable()(); // JSON array
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### WorkoutLogs Table
```dart
class WorkoutLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get workoutName => text()();
  IntColumn get duration => integer()(); // seconds
  TextColumn get notes => text().nullable()();
  BoolColumn get isQuickLog => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ExerciseSets extends Table {
  TextColumn get id => text()();
  TextColumn get workoutLogId => text()();
  TextColumn get exerciseName => text()();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real().nullable()();
  IntColumn get reps => integer().nullable()();
  IntColumn get duration => integer().nullable()(); // for timed exercises
  IntColumn get restTime => integer().nullable()(); // seconds
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 🔧 Implementation Steps

### Phase 1: Database Setup (30 min)

1. **Update Drift tables**
   ```dart
   // lib/core/database/tables/batch1_tables.dart
   ```

2. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Test database access**
   - Create test for CheckIns insertion
   - Create test for WorkoutLogs insertion

---

### Phase 2: Life Coach - Check-Ins (2 hours)

#### 2.1 Morning Check-In Flow

**Files to create:**
1. `lib/features/life_coach/domain/entities/check_in_entity.dart`
2. `lib/features/life_coach/data/models/check_in_model.dart`
3. `lib/features/life_coach/domain/repositories/check_in_repository.dart`
4. `lib/features/life_coach/data/repositories/check_in_repository_impl.dart`
5. `lib/features/life_coach/domain/usecases/create_morning_checkin_usecase.dart`
6. `lib/features/life_coach/presentation/providers/check_in_provider.dart`
7. `lib/features/life_coach/presentation/pages/morning_check_in_page.dart`

**Implementation:**

```dart
// morning_check_in_page.dart
class MorningCheckInPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Morning Check-In')),
      body: DailyInputForm(
        fields: [
          FormFieldConfig(
            label: 'Today\'s Intentions',
            hint: 'What are your top 3 goals for today?',
            maxLines: 3,
            validator: (value) => value?.isEmpty == true
                ? 'Please enter your intentions'
                : null,
          ),
          FormFieldConfig(
            label: 'Gratitude',
            hint: 'What are you grateful for?',
            maxLines: 2,
          ),
        ],
        showTimePicker: true,
        showMoodSlider: true,
        moodLabel: 'Energy Level',
        showTags: true,
        availableTags: ['Work', 'Exercise', 'Learning', 'Family', 'Rest'],
        submitText: 'Save Check-In',
        onSubmit: (data) async {
          final checkIn = CheckInEntity(
            id: uuid.v4(),
            type: CheckInType.morning,
            timestamp: DateTime.now(),
            energyLevel: data['mood'],
            intentions: data['Today\'s Intentions'],
            gratitude: data['Gratitude'],
            tags: data['tags'],
          );

          await ref.read(checkInProvider.notifier).createMorningCheckIn(checkIn);
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

**Testing:**
- [ ] Can create morning check-in
- [ ] Data saved to local database
- [ ] Validation works
- [ ] Time picker works
- [ ] Mood slider works
- [ ] Tags selection works

---

#### 2.5 Evening Reflection Flow

**Files to create:**
1. `lib/features/life_coach/domain/usecases/create_evening_reflection_usecase.dart`
2. `lib/features/life_coach/presentation/pages/evening_reflection_page.dart`

**Implementation:**

```dart
// evening_reflection_page.dart
class EveningReflectionPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Evening Reflection')),
      body: DailyInputForm(
        fields: [
          FormFieldConfig(
            label: 'Today\'s Wins',
            hint: 'What went well today?',
            maxLines: 3,
          ),
          FormFieldConfig(
            label: 'Areas to Improve',
            hint: 'What could you do better tomorrow?',
            maxLines: 2,
          ),
          FormFieldConfig(
            label: 'Tomorrow\'s Focus',
            hint: 'What\'s your main priority for tomorrow?',
            maxLines: 2,
          ),
        ],
        showMoodSlider: true,
        moodLabel: 'Productivity Rating',
        submitText: 'Save Reflection',
        onSubmit: (data) async {
          final reflection = CheckInEntity(
            id: uuid.v4(),
            type: CheckInType.evening,
            timestamp: DateTime.now(),
            productivityRating: data['mood'],
            wins: data['Today\'s Wins'],
            improvements: data['Areas to Improve'],
            tomorrowFocus: data['Tomorrow\'s Focus'],
          );

          await ref.read(checkInProvider.notifier).createEveningReflection(reflection);
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

**Testing:**
- [ ] Can create evening reflection
- [ ] Data saved to local database
- [ ] Validation works
- [ ] Productivity slider works

---

### Phase 3: Fitness - Workout Logging (3 hours)

#### 3.3 Workout Logging with Rest Timer

**Files to create:**
1. `lib/features/fitness/domain/entities/workout_log_entity.dart`
2. `lib/features/fitness/domain/entities/exercise_set_entity.dart`
3. `lib/features/fitness/data/models/workout_log_model.dart`
4. `lib/features/fitness/data/models/exercise_set_model.dart`
5. `lib/features/fitness/domain/repositories/workout_log_repository.dart`
6. `lib/features/fitness/data/repositories/workout_log_repository_impl.dart`
7. `lib/features/fitness/domain/usecases/create_workout_log_usecase.dart`
8. `lib/features/fitness/presentation/providers/workout_log_provider.dart`
9. `lib/features/fitness/presentation/pages/workout_logging_page.dart`
10. `lib/features/fitness/presentation/widgets/rest_timer_widget.dart`
11. `lib/features/fitness/presentation/widgets/exercise_set_input.dart`

**Implementation:**

```dart
// workout_logging_page.dart
class WorkoutLoggingPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<WorkoutLoggingPage> createState() => _WorkoutLoggingPageState();
}

class _WorkoutLoggingPageState extends ConsumerState<WorkoutLoggingPage> {
  final List<ExerciseSetEntity> _sets = [];
  Duration? _restTime;
  bool _restTimerActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Workout'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Rest Timer
          if (_restTimerActive)
            RestTimerWidget(
              duration: _restTime!,
              onComplete: () => setState(() => _restTimerActive = false),
            ),

          // Exercise Sets List
          Expanded(
            child: ListView.builder(
              itemCount: _sets.length,
              itemBuilder: (context, index) {
                return ExerciseSetInput(
                  set: _sets[index],
                  setNumber: index + 1,
                  onChanged: (updatedSet) {
                    setState(() {
                      _sets[index] = updatedSet;
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _sets.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),

          // Add Set Button
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add Set'),
                    onPressed: _addSet,
                  ),
                ),
                SizedBox(width: 8),
                FilledButton.icon(
                  icon: Icon(Icons.timer),
                  label: Text('Start Rest'),
                  onPressed: _startRestTimer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addSet() {
    setState(() {
      _sets.add(ExerciseSetEntity(
        id: uuid.v4(),
        workoutLogId: '',
        exerciseName: '',
        setNumber: _sets.length + 1,
        createdAt: DateTime.now(),
      ));
    });
  }

  void _startRestTimer() {
    setState(() {
      _restTime = Duration(seconds: 90);
      _restTimerActive = true;
    });
  }

  Future<void> _saveWorkout() async {
    final workoutLog = WorkoutLogEntity(
      id: uuid.v4(),
      userId: ref.read(authProvider).user!.id,
      timestamp: DateTime.now(),
      workoutName: 'Workout ${DateTime.now().toString()}',
      duration: 0,
      sets: _sets,
      createdAt: DateTime.now(),
    );

    await ref.read(workoutLogProvider.notifier).createWorkoutLog(workoutLog);
    Navigator.pop(context);
  }
}
```

**Rest Timer Widget:**

```dart
// rest_timer_widget.dart
class RestTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;

  const RestTimerWidget({
    required this.duration,
    required this.onComplete,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remaining = Duration(
          seconds: (widget.duration.inSeconds * (1 - _controller.value)).round(),
        );

        return Container(
          padding: EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              CircularProgressIndicator(
                value: _controller.value,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rest Timer', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}'),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: () {
                  _controller.stop();
                  widget.onComplete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Testing:**
- [ ] Can log workout with multiple sets
- [ ] Rest timer works correctly
- [ ] Can add/remove sets
- [ ] Data saved to local database
- [ ] Can edit set details (weight, reps)

---

#### 3.8 Quick Log (Rapid Entry)

**Files to create:**
1. `lib/features/fitness/domain/usecases/quick_log_workout_usecase.dart`
2. `lib/features/fitness/presentation/pages/quick_log_page.dart`

**Implementation:**

```dart
// quick_log_page.dart
class QuickLogPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Quick Log')),
      body: DailyInputForm(
        fields: [
          FormFieldConfig(
            label: 'Exercise Name',
            hint: 'e.g., Bench Press',
            validator: (value) => value?.isEmpty == true
                ? 'Required'
                : null,
          ),
          FormFieldConfig(
            label: 'Sets',
            hint: 'Number of sets',
            keyboardType: TextInputType.number,
          ),
          FormFieldConfig(
            label: 'Reps',
            hint: 'Reps per set',
            keyboardType: TextInputType.number,
          ),
          FormFieldConfig(
            label: 'Weight (kg)',
            hint: 'Weight used',
            keyboardType: TextInputType.number,
          ),
        ],
        showTimePicker: true,
        submitText: 'Log Exercise',
        onSubmit: (data) async {
          final quickLog = WorkoutLogEntity(
            id: uuid.v4(),
            userId: ref.read(authProvider).user!.id,
            timestamp: data['time'],
            workoutName: data['Exercise Name'],
            isQuickLog: true,
            sets: [
              ExerciseSetEntity(
                id: uuid.v4(),
                exerciseName: data['Exercise Name'],
                weight: double.tryParse(data['Weight (kg)'] ?? '0'),
                reps: int.tryParse(data['Reps'] ?? '0'),
                setNumber: 1,
              ),
            ],
            createdAt: DateTime.now(),
          );

          await ref.read(workoutLogProvider.notifier).quickLogWorkout(quickLog);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Workout logged!')),
          );
        },
      ),
    );
  }
}
```

**Testing:**
- [ ] Can quickly log single exercise
- [ ] Data saved correctly
- [ ] Validation works
- [ ] Success message shown

---

## 🧪 Testing Checklist

### Unit Tests
- [ ] CheckIn entity tests
- [ ] WorkoutLog entity tests
- [ ] Repository tests (mock Drift)
- [ ] UseCase tests

### Widget Tests
- [ ] MorningCheckInPage renders
- [ ] EveningReflectionPage renders
- [ ] WorkoutLoggingPage renders
- [ ] QuickLogPage renders
- [ ] RestTimerWidget countdown works

### Integration Tests
- [ ] E2E: Create morning check-in and verify in database
- [ ] E2E: Create evening reflection and verify in database
- [ ] E2E: Log workout and verify in database
- [ ] E2E: Quick log and verify in database

---

## 📈 Success Metrics

- [ ] All 4 pages functional
- [ ] Data persists to local database
- [ ] Forms validate correctly
- [ ] Reusable widgets used (no duplication)
- [ ] Tests passing (75%+ coverage)
- [ ] No lint errors
- [ ] Clean Architecture maintained

---

## 🚨 Potential Issues & Solutions

### Issue 1: Drift Table Conflicts
**Solution:** Use separate table for CheckIns vs Reflections, or use single table with `type` discriminator

### Issue 2: Rest Timer Performance
**Solution:** Use AnimationController for smooth countdown, pause/resume capability

### Issue 3: Form State Management
**Solution:** DailyInputForm handles its own state, parent only needs to handle submission

### Issue 4: Validation Complexity
**Solution:** Pass validators as FormFieldConfig, keep validation logic close to field definition

---

## 📦 Dependencies

Already in `pubspec.yaml`:
- freezed
- freezed_annotation
- drift
- riverpod
- uuid

Additional needed:
- intl (for date formatting)

```yaml
dependencies:
  intl: ^0.19.0
```

---

## ⏱️ Time Breakdown

| Task | Time |
|------|------|
| Database setup | 30 min |
| Morning Check-In (2.1) | 1 hour |
| Evening Reflection (2.5) | 45 min |
| Workout Logging (3.3) | 2 hours |
| Quick Log (3.8) | 45 min |
| Testing | 2 hours |
| **TOTAL** | **7 hours** |

Spread across 2-3 days with breaks and reviews.

---

## 🎯 Next Steps After Batch 1

After completing Batch 1, we'll have:
- ✅ Solid foundation for form-based features
- ✅ Reusable widgets validated
- ✅ Database patterns established
- ✅ Testing patterns proven

This sets us up perfectly for **Batch 3** (CRUD operations).
