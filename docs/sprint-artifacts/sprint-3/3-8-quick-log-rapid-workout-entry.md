# Story 3.8: Quick Log (Rapid Workout Entry)

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P1 | **Status:** ready-for-dev | **Effort:** 2 SP

---

## User Story
**As a** user wanting ultra-fast logging
**I want** a quick log mode
**So that** I can log entire workout in <30 seconds

---

## Acceptance Criteria
1. ✅ "Quick Log" button on Fitness home
2. ✅ Quick log modal: List of recent exercises
3. ✅ Tap exercise → Pre-fill last workout → Tap check → Done
4. ✅ No rest timer (ultra-fast mode)
5. ✅ Add new exercise: Search → Select → Log
6. ✅ Quick log saves as regular workout (visible in history)
7. ✅ Duration auto-calculated based on log timestamps

**FRs:** FR30, FR31

---

## Technical Implementation

### Quick Log Modal
```dart
class QuickLogModal extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final recentExercises = ref.watch(recentExercisesProvider);

    return Column(
      children: [
        Text('Recent Exercises', style: heading),
        ...recentExercises.map((ex) {
          return ExerciseTile(
            exercise: ex,
            onTap: () async {
              final lastSets = await getLastWorkout(ex.id);
              await logSets(lastSets); // Pre-filled, 1-tap to confirm
            },
          );
        }),
        TextButton(
          onPressed: () => showExerciseSearch(),
          child: Text('+ Add New Exercise'),
        ),
      ],
    );
  }
}
```

### Recent Exercises Query
```sql
SELECT DISTINCT exercise_id
FROM workout_sets
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT 5;
```

---

## Dependencies
**Prerequisites:** Story 3.1 (Smart Pattern Memory)

**Coverage Target:** 80%+

---

## Dev Agent Record

### Context Reference

- **Story Context File:** [3-8-quick-log-rapid-workout-entry.context.xml](./3-8-quick-log-rapid-workout-entry.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
