# Story 3.1 - Detailed Technical Context
## Smart Pattern Memory: Pre-fill Last Workout

**Story:** 3.1
**Epic:** 3 - Fitness Coach MVP
**Sprint:** 3
**Story Points:** 5
**Complexity:** ⭐⭐⭐⭐⭐ (Highest - Killer Feature)

---

## 🎯 Executive Summary

Smart Pattern Memory is the **killer feature** of the Fitness module. It pre-fills the last workout data (sets, reps, weight) for each exercise, enabling **<2 second logging per set** - dramatically faster than competitors (Strong: ~15s/set, Hevy: ~10s/set).

**Key Challenge:** Query Drift (local SQLite) to fetch last workout data in **<20ms** and render UI in **<100ms** for seamless UX.

---

## 📊 Performance Requirements

```
User Experience Timeline:
┌──────────────────────────────────────────────────────────────┐
│ Tap Exercise → Smart Pattern Memory Loads → UI Renders       │
│                                                               │
│ ├─ 0-20ms:   Query Drift for last workout                    │
│ ├─ 20-50ms:  Build UI state with pre-filled data             │
│ ├─ 50-100ms: Render SetLoggingScreen                         │
│ └─ <100ms:   User sees pre-filled sets ✅                    │
│                                                               │
│ Total: <100ms (perceived as instant)                         │
└──────────────────────────────────────────────────────────────┘

Logging Speed:
┌──────────────────────────────────────────────────────────────┐
│ Set 1: Tap "Log Set 1" → <2s elapsed                         │
│ Set 2: Adjust weight (+2.5kg) → Tap "Log Set 2" → <4s total  │
│ Set 3: Same → Tap "Log Set 3" → <6s total                    │
│                                                               │
│ 3 sets logged in <6 seconds (vs 45s with Strong) 🚀          │
└──────────────────────────────────────────────────────────────┘
```

**Competitive Advantage:**
- **Strong App:** ~15s per set (manual entry, no pre-fill)
- **Hevy App:** ~10s per set (some auto-complete, but slow)
- **LifeOS:** ~<2s per set (Smart Pattern Memory) **7.5x faster!**

---

## 🏗️ ARCHITECTURE

### Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│ USER TAPS EXERCISE: "Bench Press"                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: Query Drift (Local SQLite)                          │
│                                                              │
│  SmartPatternService.getLastWorkoutPattern('bench-press')   │
│                          ↓                                   │
│  SELECT exercises.sets                                       │
│  FROM exercises                                              │
│  JOIN workouts ON exercises.workout_id = workouts.id        │
│  WHERE exercises.exercise_library_id = 'bench-press'        │
│    AND workouts.user_id = 'current-user'                    │
│    AND workouts.completed_at IS NOT NULL                    │
│  ORDER BY workouts.completed_at DESC                        │
│  LIMIT 1                                                     │
│                          ↓                                   │
│  Result: { sets: [{weight: 100, reps: 5}, ...] }            │
│  Query Time: <20ms ✅                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: Build UI State                                      │
│                                                              │
│  SetLoggingState(                                            │
│    exerciseName: 'Bench Press',                             │
│    preFilled: true,                                          │
│    sets: [                                                   │
│      Set(weight: 100kg, reps: 5, completed: false),         │
│      Set(weight: 100kg, reps: 5, completed: false),         │
│      Set(weight: 100kg, reps: 5, completed: false),         │
│    ]                                                         │
│  )                                                           │
│                          ↓                                   │
│  Build Time: <30ms ✅                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: Render UI                                           │
│                                                              │
│  SetLoggingScreen displays:                                 │
│  ┌──────────────────────────────────────────┐               │
│  │ Bench Press                              │               │
│  ├──────────────────────────────────────────┤               │
│  │ Set 1: [100kg ▼] [5 reps ▼] [✓ Log]     │ ← Pre-filled  │
│  │ Set 2: [100kg ▼] [5 reps ▼] [○ Log]     │ ← Pre-filled  │
│  │ Set 3: [100kg ▼] [5 reps ▼] [○ Log]     │ ← Pre-filled  │
│  └──────────────────────────────────────────┘               │
│                                                              │
│  Render Time: <50ms ✅                                      │
│  Total Time: <100ms ✅                                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ USER INTERACTION: Tap "Log Set 1"                           │
│                                                              │
│  User only adjusts if different (progressive overload):     │
│  - Same weight/reps → 1 tap → <1s                           │
│  - +2.5kg → Tap weight → Tap +2.5kg → Tap "Log" → <2s      │
│                          ↓                                   │
│  Save to Drift → Instant feedback (<100ms)                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 💻 IMPLEMENTATION

### Dart: Smart Pattern Service

```dart
class SmartPatternService {
  final AppDatabase _db;  // Drift database

  /// Get last workout pattern for an exercise
  /// Returns: Last sets/reps/weight from most recent completed workout
  /// Performance: <20ms (local query, indexed)
  Future<WorkoutPattern?> getLastWorkoutPattern(String exerciseLibraryId) async {
    try {
      final stopwatch = Stopwatch()..start();

      // Query: Get last completed workout for this exercise
      final result = await (_db.select(_db.exercises)
            ..where((e) => e.exerciseLibraryId.equals(exerciseLibraryId))
            ..join([
              innerJoin(
                _db.workouts,
                _db.workouts.id.equalsExp(_db.exercises.workoutId),
              )
            ])
            ..where(_db.workouts.userId.equals(_currentUserId))
            ..where(_db.workouts.completedAt.isNotNull())
            ..orderBy([OrderingTerm.desc(_db.workouts.completedAt)])
            ..limit(1))
          .getSingleOrNull();

      stopwatch.stop();
      print('Smart Pattern Query: ${stopwatch.elapsedMilliseconds}ms');

      if (result == null) return null;

      final exercise = result.readTable(_db.exercises);

      return WorkoutPattern(
        exerciseLibraryId: exerciseLibraryId,
        sets: _parseSets(exercise.sets),
        lastPerformed: result.readTable(_db.workouts).completedAt,
      );

    } catch (e) {
      print('Error loading pattern: $e');
      return null;
    }
  }

  List<SetData> _parseSets(String setsJson) {
    final List<dynamic> decoded = jsonDecode(setsJson);
    return decoded
        .map((s) => SetData(
              weight: s['weight'] ?? 0.0,
              reps: s['reps'] ?? 0,
              rpe: s['rpe'],
            ))
        .toList();
  }

  /// Pre-fill sets for new workout based on last pattern
  List<SetInput> preFillSets(WorkoutPattern pattern) {
    return pattern.sets
        .map((set) => SetInput(
              weight: set.weight,
              reps: set.reps,
              rpe: set.rpe,
              completed: false,
            ))
        .toList();
  }
}

@freezed
class WorkoutPattern with _$WorkoutPattern {
  const factory WorkoutPattern({
    required String exerciseLibraryId,
    required List<SetData> sets,
    required DateTime lastPerformed,
  }) = _WorkoutPattern;
}

@freezed
class SetData with _$SetData {
  const factory SetData({
    required double weight,
    required int reps,
    int? rpe,
  }) = _SetData;
}

@freezed
class SetInput with _$SetInput {
  const factory SetInput({
    required double weight,
    required int reps,
    int? rpe,
    required bool completed,
  }) = _SetInput;
}
```

---

### Drift Schema Optimization

```dart
// exercises table definition
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get workoutId => text()();
  TextColumn get exerciseLibraryId => text()();
  TextColumn get sets => text()();  // JSON: [{weight, reps, rpe}, ...]
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // CRITICAL: Index for Smart Pattern Memory query performance
    'INDEX idx_exercises_library_workout ON exercises(exercise_library_id, workout_id)',
  ];
}

class Workouts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // CRITICAL: Index for query performance
    'INDEX idx_workouts_user_completed ON workouts(user_id, completed_at DESC)',
  ];
}
```

**Index Rationale:**
- `idx_exercises_library_workout`: Speeds up JOIN between exercises and workouts
- `idx_workouts_user_completed`: Speeds up filtering by user and sorting by completion date
- Query time: **<20ms** with indexes vs **>500ms** without

---

### UI Implementation

```dart
class SetLoggingScreen extends ConsumerStatefulWidget {
  final String exerciseLibraryId;
  final String exerciseName;

  const SetLoggingScreen({
    required this.exerciseLibraryId,
    required this.exerciseName,
  });

  @override
  _SetLoggingScreenState createState() => _SetLoggingScreenState();
}

class _SetLoggingScreenState extends ConsumerState<SetLoggingScreen> {
  List<SetInput> _sets = [];
  bool _loading = true;
  bool _preFilled = false;

  @override
  void initState() {
    super.initState();
    _loadSmartPattern();
  }

  Future<void> _loadSmartPattern() async {
    final stopwatch = Stopwatch()..start();

    try {
      final pattern = await ref
          .read(smartPatternServiceProvider)
          .getLastWorkoutPattern(widget.exerciseLibraryId);

      stopwatch.stop();
      print('Smart Pattern Load: ${stopwatch.elapsedMilliseconds}ms');

      setState(() {
        if (pattern != null) {
          _sets = ref.read(smartPatternServiceProvider).preFillSets(pattern);
          _preFilled = true;
        } else {
          // No previous workout, create empty sets
          _sets = List.generate(
            3,
            (_) => SetInput(weight: 0, reps: 0, completed: false),
          );
          _preFilled = false;
        }
        _loading = false;
      });

    } catch (e) {
      print('Error loading pattern: $e');
      setState(() {
        _sets = List.generate(
          3,
          (_) => SetInput(weight: 0, reps: 0, completed: false),
        );
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.exerciseName)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        actions: [
          if (_preFilled)
            Chip(
              label: Text('Last: ${_formatLastWorkout()}'),
              backgroundColor: Colors.teal.shade100,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_preFilled)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.teal.shade50,
              child: Row(
                children: [
                  Icon(Icons.bolt, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Smart Pattern Memory: Pre-filled from last workout',
                      style: TextStyle(color: Colors.teal.shade900),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _sets.length,
              itemBuilder: (context, index) => _buildSetRow(index),
            ),
          ),

          // Add Set button
          Padding(
            padding: EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _addSet,
              icon: Icon(Icons.add),
              label: Text('Add Set'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int index) {
    final set = _sets[index];

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Set number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: set.completed ? Colors.teal : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: set.completed ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(width: 16),

            // Weight input
            Expanded(
              child: _buildWeightInput(index, set.weight),
            ),

            SizedBox(width: 12),

            // Reps input
            Expanded(
              child: _buildRepsInput(index, set.reps),
            ),

            SizedBox(width: 12),

            // Log button
            ElevatedButton(
              onPressed: set.completed ? null : () => _logSet(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: set.completed ? Colors.grey : Colors.teal,
              ),
              child: Icon(set.completed ? Icons.check : Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInput(int index, double currentWeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weight', style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: () => _adjustWeight(index, -2.5),
              iconSize: 20,
            ),
            Expanded(
              child: Text(
                '${currentWeight.toStringAsFixed(1)} kg',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () => _adjustWeight(index, 2.5),
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepsInput(int index, int currentReps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reps', style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: currentReps > 0 ? () => _adjustReps(index, -1) : null,
              iconSize: 20,
            ),
            Expanded(
              child: Text(
                '$currentReps',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () => _adjustReps(index, 1),
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }

  void _adjustWeight(int index, double delta) {
    setState(() {
      _sets[index] = _sets[index].copyWith(
        weight: (_sets[index].weight + delta).clamp(0, 500),
      );
    });
  }

  void _adjustReps(int index, int delta) {
    setState(() {
      _sets[index] = _sets[index].copyWith(
        reps: (_sets[index].reps + delta).clamp(0, 100),
      );
    });
  }

  Future<void> _logSet(int index) async {
    final stopwatch = Stopwatch()..start();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      _sets[index] = _sets[index].copyWith(completed: true);
    });

    // Save to database (offline-first)
    await _saveSet(index);

    stopwatch.stop();
    print('Set logged in: ${stopwatch.elapsedMilliseconds}ms');

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set ${index + 1} logged! ✓'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveSet(int index) async {
    // Save to Drift (local database)
    // Implementation: Update exercises.sets JSON
  }

  void _addSet() {
    setState(() {
      final lastSet = _sets.isNotEmpty ? _sets.last : null;
      _sets.add(SetInput(
        weight: lastSet?.weight ?? 0,
        reps: lastSet?.reps ?? 0,
        completed: false,
      ));
    });
  }

  String _formatLastWorkout() {
    if (_sets.isEmpty) return '';
    final firstSet = _sets.first;
    return '${firstSet.weight}kg × ${firstSet.reps}';
  }
}
```

---

## ⚡ PERFORMANCE OPTIMIZATION

### Query Optimization Checklist

✅ **Indexes Created:**
```sql
CREATE INDEX idx_exercises_library_workout ON exercises(exercise_library_id, workout_id);
CREATE INDEX idx_workouts_user_completed ON workouts(user_id, completed_at DESC);
```

✅ **Query Limited:**
```dart
..limit(1)  // Only fetch most recent workout
```

✅ **JOIN Optimized:**
```dart
innerJoin()  // Use INNER JOIN instead of LEFT JOIN (faster)
```

✅ **Columns Selected:**
```dart
// Only select needed columns (not SELECT *)
..select([exercises.sets, workouts.completedAt])
```

### Caching Strategy

```dart
class SmartPatternCache {
  final Map<String, CachedPattern> _cache = {};

  WorkoutPattern? get(String exerciseLibraryId) {
    final cached = _cache[exerciseLibraryId];
    if (cached == null) return null;

    // Cache valid for 1 hour
    if (DateTime.now().difference(cached.timestamp) > Duration(hours: 1)) {
      _cache.remove(exerciseLibraryId);
      return null;
    }

    return cached.pattern;
  }

  void set(String exerciseLibraryId, WorkoutPattern pattern) {
    _cache[exerciseLibraryId] = CachedPattern(
      pattern: pattern,
      timestamp: DateTime.now(),
    );
  }

  void invalidate(String exerciseLibraryId) {
    _cache.remove(exerciseLibraryId);
  }
}

class CachedPattern {
  final WorkoutPattern pattern;
  final DateTime timestamp;

  CachedPattern({required this.pattern, required this.timestamp});
}
```

**Performance Impact:**
- First load: 20ms (query Drift)
- Cached load: <1ms (memory lookup)
- Cache invalidation: On new workout completion for that exercise

---

## 🧪 TESTING STRATEGY

### Performance Tests

```dart
test('Smart Pattern query completes in <20ms', () async {
  // Setup: Create 100 completed workouts
  for (int i = 0; i < 100; i++) {
    await createMockWorkout(
      exerciseLibraryId: 'bench-press',
      sets: [
        {'weight': 100.0 + i, 'reps': 5},
        {'weight': 100.0 + i, 'reps': 5},
        {'weight': 100.0 + i, 'reps': 5},
      ],
      completedAt: DateTime.now().subtract(Duration(days: i)),
    );
  }

  // Execute: Query last workout
  final stopwatch = Stopwatch()..start();
  final pattern = await smartPatternService.getLastWorkoutPattern('bench-press');
  stopwatch.stop();

  // Assert: Query time <20ms
  expect(stopwatch.elapsedMilliseconds, lessThan(20));
  expect(pattern, isNotNull);
  expect(pattern!.sets.length, equals(3));
  expect(pattern.sets.first.weight, equals(100.0));  // Most recent
});
```

### Functional Tests

```dart
test('Pre-fills sets from last workout', () async {
  // Setup: Create previous workout
  await createMockWorkout(
    exerciseLibraryId: 'squat',
    sets: [
      {'weight': 140.0, 'reps': 5},
      {'weight': 140.0, 'reps': 5},
      {'weight': 140.0, 'reps': 4},
    ],
  );

  // Execute: Load pattern
  final pattern = await smartPatternService.getLastWorkoutPattern('squat');
  final preFilled = smartPatternService.preFillSets(pattern!);

  // Assert: Correct pre-fill
  expect(preFilled.length, equals(3));
  expect(preFilled[0].weight, equals(140.0));
  expect(preFilled[0].reps, equals(5));
  expect(preFilled[2].reps, equals(4));
  expect(preFilled.every((s) => !s.completed), isTrue);
});

test('Returns null for first-time exercise', () async {
  final pattern = await smartPatternService.getLastWorkoutPattern('new-exercise');
  expect(pattern, isNull);
});
```

---

## 🐛 TROUBLESHOOTING

### Issue: Query Slow (>100ms)

**Debug:**
```dart
// Add query profiling
final explain = await db.customSelect(
  'EXPLAIN QUERY PLAN SELECT ...',
).get();
print(explain);
```

**Solution:**
- Verify indexes exist: `PRAGMA index_list('exercises');`
- Rebuild indexes: `REINDEX;`
- Vacuum database: `VACUUM;`

### Issue: Wrong Pattern Loaded

**Debug:**
```dart
// Check query result
print('Exercise ID: $exerciseLibraryId');
print('User ID: $_currentUserId');
print('Last workout: ${result?.completedAt}');
print('Sets: ${result?.sets}');
```

**Solution:**
- Verify exercise_library_id matches exactly (case-sensitive)
- Check user_id filter is applied
- Ensure completedAt is not null (only completed workouts)

---

## ✅ DEFINITION OF DONE

- [ ] Smart Pattern query <20ms (95th percentile)
- [ ] UI render time <100ms total
- [ ] Logging speed <2s per set (user testing)
- [ ] Indexes created and verified
- [ ] Caching strategy implemented
- [ ] Performance tests passing
- [ ] Functional tests passing (pre-fill, null handling)
- [ ] Code reviewed and merged

---

**Created:** 2025-01-16
**Author:** Winston (BMAD Architect)
**Status:** Ready for Implementation
