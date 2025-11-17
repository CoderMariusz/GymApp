# Story 3.1: Smart Pattern Memory - Pre-fill Last Workout

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P0 | **Status:** ready-for-dev | **Effort:** 5 SP (Killer Feature!)

---

## User Story
**As a** user logging a workout
**I want** the app to pre-fill my last sets/reps/weight
**So that** I can log workouts in <2 seconds per set

---

## Acceptance Criteria
1. ✅ User opens "Log Workout" modal
2. ✅ If exercise logged before → Pre-fill last session's data (exercise, sets, reps, weight)
3. ✅ If first time → Show empty form
4. ✅ Swipe up/down on weight to increment/decrement (5kg/10lbs)
5. ✅ Tap reps to edit (number picker)
6. ✅ Tap checkmark → Set logged (<2s target!)
7. ✅ Haptic feedback on check (light tap)
8. ✅ Offline-first (works without internet)
9. ✅ Data synced when online

**FRs:** FR30, FR31

---

## Technical Implementation

### Query Last Workout
```dart
class SmartPatternMemory {
  Future<List<WorkoutSet>> getLastWorkout(String exerciseId) async {
    final lastSets = await db.query(
      'workout_sets',
      where: 'exercise_id = ? AND user_id = ?',
      whereArgs: [exerciseId, userId],
      orderBy: 'created_at DESC',
      limit: 10, // Last session (max 10 sets)
    );

    return lastSets.map((e) => WorkoutSet.fromMap(e)).toList();
  }
}
```

### Pre-fill UI
```dart
class QuickLogWidget extends ConsumerStatefulWidget {
  @override
  State<QuickLogWidget> createState() => _QuickLogWidgetState();
}

class _QuickLogWidgetState extends ConsumerState<QuickLogWidget> {
  @override
  void initState() {
    super.initState();
    _loadLastWorkout();
  }

  Future<void> _loadLastWorkout() async {
    final lastSets = await ref.read(smartPatternProvider).getLastWorkout(exerciseId);
    setState(() {
      preFillData = lastSets;
    });
  }
}
```

### Swipe Gesture for Weight
```dart
GestureDetector(
  onVerticalDragUpdate: (details) {
    if (details.delta.dy < 0) {
      // Swipe up = increase
      setState(() => weight += 5);
    } else {
      // Swipe down = decrease
      setState(() => weight -= 5);
    }
    HapticFeedback.selectionClick();
  },
  child: Text('$weight kg', style: TextStyle(fontSize: 32)),
)
```

---

## Dependencies
**Prerequisites:** Epic 1 (Data Sync)
**Blocks:** Story 3.3 (Workout Logging), 3.8 (Quick Log)

**Coverage Target:** 85%+ (Critical feature)

---

## Dev Agent Record

### Context Reference

- **Story Context File:** [3-1-smart-pattern-memory-pre-fill-last-workout.context.xml](./3-1-smart-pattern-memory-pre-fill-last-workout.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
