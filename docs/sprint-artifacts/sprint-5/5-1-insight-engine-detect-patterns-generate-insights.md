# Story 5.1: Insight Engine - Detect Patterns & Generate Insights
**Epic:** 5 - Cross-Module Intelligence | **P0** | **5 SP** | **drafted**

## User Story
**As the system**, **I want** to detect patterns across modules, **So that** I generate actionable cross-module insights.

## AC
1. ✅ Runs daily (cron 6am)
2. ✅ Analyzes: Mood/stress (Mind), Workout volume/frequency (Fitness), Sleep quality/energy (Life Coach)
3. ✅ Detects patterns: High stress + heavy workout, Poor sleep + morning workout, High volume + elevated stress, Meditation streak + improving mood, 8+ hours sleep → better performance
4. ✅ Generates max 1 high-priority insight/day
5. ✅ Insight stored in insights table (type, title, description, action_cta)
6. ✅ Push notification if critical (overtraining risk)

**FRs:** FR77-FR81

## Tech
```typescript
// Cron job (Supabase Edge Function, daily 6am)
Deno.serve(async () => {
  const users = await getAllActiveUsers();
  for (const user of users) {
    const insight = await detectPatterns(user.id);
    if (insight) {
      await saveInsight(insight);
      if (insight.priority === 'critical') {
        await sendNotification(user.id, insight);
      }
    }
  }
});
```
```sql
CREATE TABLE insights (
  id UUID PRIMARY KEY,
  user_id UUID,
  type TEXT, -- 'stress-workout', 'sleep-workout', etc.
  title TEXT,
  description TEXT,
  cta TEXT,
  priority TEXT CHECK (priority IN ('normal', 'critical')),
  dismissed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ
);
```
**Dependencies:** Epic 2, 3, 4 (ALL modules) | **Coverage:** 75%+
