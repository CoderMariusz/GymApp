# Story 3.5: Progress Charts (Strength, Volume, PRs)

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P1 | **Status:** ready-for-dev | **Effort:** 3 SP

---

## User Story
**As a** user tracking strength progress
**I want** to see charts of improvements
**So that** I can visualize gains and stay motivated

---

## Acceptance Criteria
1. ✅ Progress screen (Fitness tab → "Progress")
2. ✅ Weight lifted chart per exercise (line graph, 30-day)
3. ✅ Total volume chart (bar graph, weekly totals)
4. ✅ Personal records (PRs) list (heaviest weight per exercise)
5. ✅ PR celebrations when new PR achieved (confetti + badge)
6. ✅ Chart filtering: Select exercise, date range
7. ✅ Export data button (CSV download)

**FRs:** FR38, FR41

---

## Technical Implementation

### PR Detection
```sql
-- Materialized view for performance
CREATE MATERIALIZED VIEW personal_records AS
SELECT
  user_id,
  exercise_id,
  MAX(weight) as max_weight,
  MAX(created_at) as achieved_at
FROM workout_sets
GROUP BY user_id, exercise_id;

REFRESH MATERIALIZED VIEW personal_records;
```

### PR Check (After Set Logged)
```dart
Future<bool> isNewPR(WorkoutSet set) async {
  final currentPR = await db.query(
    'personal_records',
    where: 'user_id = ? AND exercise_id = ?',
    whereArgs: [userId, set.exerciseId],
  );

  if (currentPR.isEmpty || set.weight > currentPR.first['max_weight']) {
    await _showPRCelebration(set);
    return true;
  }
  return false;
}
```

### Charts (fl_chart)
```dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: chartData.map((d) => FlSpot(d.date, d.weight)).toList(),
        color: Colors.orange,
      ),
    ],
  ),
)
```

---

## Dependencies
**Prerequisites:** Story 3.3 (Workout data), Story 3.4 (History)

**Coverage Target:** 75%+

---

## Dev Agent Record

### Context Reference

- **Story Context File:** [3-5-progress-charts-strength-volume-prs.context.xml](./3-5-progress-charts-strength-volume-prs.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
