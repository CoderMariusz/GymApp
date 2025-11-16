# Story 5.5: Sleep Quality + Workout Performance Correlation
**Epic:** 5 - Cross-Module Intelligence | **P1** | **3 SP** | **drafted**

## AC
1. ✅ Triggered when: 30+ days of data available (sleep + workouts)
2. ✅ Correlation analysis: Sleep quality vs Weight lifted (PRs)
3. ✅ Examples: "Your best lifts happen after 8+ hours sleep", "When you sleep <6 hours, strength drops 15%", "7-day good sleep streak → 10% higher workout volume"
4. ✅ Recommendation: "Tonight's goal: Sleep meditation + 8 hours rest"
5. ✅ CTA: "Start Sleep Meditation" → Opens Mind
6. ✅ Data visualization: Scatter plot (sleep vs performance)

**FRs:** FR80

## Tech
```sql
-- Pearson correlation
SELECT
  CORR(c.sleep_quality, ws.weight) as correlation
FROM check_ins c
JOIN workouts w ON w.user_id = c.user_id AND DATE(w.start_time) = c.date
JOIN workout_sets ws ON ws.workout_id = w.id
WHERE c.user_id = $1
  AND c.date >= NOW() - INTERVAL '30 days';
```
**Dependencies:** 5.1, 5.2, Epic 2, Epic 3 (30+ days data) | **Coverage:** 75%+
