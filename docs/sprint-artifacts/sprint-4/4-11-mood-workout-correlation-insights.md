# Story 4.11: Mood & Workout Correlation Insights
**Epic:** 4 - Mind & Emotion | **P1** | **2 SP** | **ready-for-dev**

## User Story
**As a** user tracking mood and workouts, **I want** to see correlations, **So that** I understand how exercise affects mental health.

## Acceptance Criteria
1. ✅ Insights screen (Mind tab → "Insights")
2. ✅ Correlation analysis: Mood vs Workout frequency
3. ✅ Examples: "Your mood is 20% higher on workout days", "After leg day, mood drops (soreness?)", "7-day workout streaks correlate with better sleep"
4. ✅ Insights as cards (swipeable)
5. ✅ Data visualization: Scatter plot or bar chart
6. ✅ Minimum 14 days of data required

**FRs:** FR60 (correlations)

## Tech
```sql
-- Aggregate query: JOIN mood_logs + workouts by date
SELECT
  m.date,
  AVG(m.mood_score) as avg_mood,
  COUNT(w.id) as workout_count
FROM mood_logs m
LEFT JOIN workouts w ON w.user_id = m.user_id AND DATE(w.start_time) = m.date
GROUP BY m.date;

-- Pearson correlation coefficient
```
**Dependencies:** 4.3 (Mood), Epic 3 (Fitness) | **Coverage:** 75%+

## Dev Agent Record

- **Status Updated to ready-for-dev:** 2025-11-17
- **Dev Agent:** Claude Haiku 4.5
- **Purpose:** Ready for development phase
