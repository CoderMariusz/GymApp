# Story 3.4: Workout History & Detail View

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P0 | **Status:** drafted | **Effort:** 2 SP

---

## User Story
**As a** user reviewing past workouts
**I want** to see workout history
**So that** I can track consistency and progress

---

## Acceptance Criteria
1. ✅ Workout history screen (from Fitness tab)
2. ✅ Workouts sorted by date (most recent first)
3. ✅ Cards show: Date, duration, exercises count, total volume (kg lifted)
4. ✅ Tap workout → Detail view (all sets, reps, weight)
5. ✅ Detail view: Edit button (modify past workouts)
6. ✅ Detail view: Delete button (confirmation required)
7. ✅ Filter by date range (7d, 30d, 3m, 1y, All)
8. ✅ Search by exercise name

**FRs:** FR37, FR40

---

## Technical Implementation

### Query with Pagination
```dart
Future<List<Workout>> getWorkoutHistory({
  int limit = 20,
  int offset = 0,
  DateRange? dateRange,
}) async {
  var query = db.select(workouts)
    ..where((w) => w.userId.equals(userId))
    ..orderBy([(w) => OrderingTerm.desc(w.startTime)])
    ..limit(limit, offset: offset);

  if (dateRange != null) {
    query.where((w) =>
      w.startTime.isBiggerOrEqualValue(dateRange.start) &
      w.startTime.isSmallerOrEqualValue(dateRange.end)
    );
  }

  return await query.get();
}
```

### Total Volume Calculation
```sql
SELECT
  w.id,
  w.start_time,
  w.duration,
  COUNT(DISTINCT ws.exercise_id) as exercise_count,
  SUM(ws.reps * ws.weight) as total_volume
FROM workouts w
LEFT JOIN workout_sets ws ON ws.workout_id = w.id
WHERE w.user_id = $1
GROUP BY w.id
ORDER BY w.start_time DESC;
```

---

## Dependencies
**Prerequisites:** Story 3.3 (Workout Logging)

**Coverage Target:** 80%+

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
