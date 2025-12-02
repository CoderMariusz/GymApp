# Story 2.7: Progress Dashboard (Life Coach)

**Epic:** Epic 2 - Life Coach MVP
**Priority:** P1 | **Status:** ready-for-dev | **Effort:** 3 SP

---

## User Story
**As a** user tracking life progress
**I want** to see charts and trends
**So that** I can understand patterns and improvements

---

## Acceptance Criteria
1. ✅ Progress screen from Home → "View Stats"
2. ✅ Mood trend chart (7-day, 30-day line graph)
3. ✅ Energy trend chart (7-day, 30-day)
4. ✅ Sleep quality trend chart (7-day, 30-day)
5. ✅ Goal completion rate (% completed this month)
6. ✅ Check-in completion rate (% days with both check-ins)
7. ✅ AI chat usage (conversations per week)
8. ✅ Charts interactive (tap data point for details)
9. ✅ Export data option (CSV download)

**FRs:** FR27, FR29

---

## Technical Implementation

### Charts Library
```dart
dependencies:
  fl_chart: ^0.66.0 # Flutter charts

class ProgressDashboard extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final moodData = ref.watch(moodTrendProvider);

    return Column(
      children: [
        LineChartWidget(
          data: moodData,
          color: Colors.purple,
          title: 'Mood Trend',
        ),
        // Energy, Sleep, etc.
      ],
    );
  }
}
```

### Aggregate Queries
```sql
-- Materialize daily stats for performance
CREATE MATERIALIZED VIEW daily_stats AS
SELECT
  user_id,
  date,
  AVG(mood) as avg_mood,
  AVG(energy) as avg_energy,
  AVG(sleep_quality) as avg_sleep
FROM check_ins
GROUP BY user_id, date;

CREATE INDEX idx_daily_stats_user_date ON daily_stats(user_id, date DESC);
```

---

## Dependencies
**Prerequisites:** Story 2.1 (Check-in data), Story 2.5 (Reflection data)

**Coverage Target:** 75%+

---

## Dev Agent Record
**Context File:** 2-7-progress-dashboard-life-coach.context.xml

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
