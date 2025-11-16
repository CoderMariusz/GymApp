# Story 2.10: Weekly Summary Report (Life Coach)

**Epic:** Epic 2 - Life Coach MVP
**Priority:** P1 | **Status:** drafted | **Effort:** 3 SP

---

## User Story
**As a** user tracking life progress
**I want** a weekly summary report
**So that** I can see concrete evidence of improvements

---

## Acceptance Criteria
1. ✅ Generated every Monday 6am
2. ✅ Push notification: "Your week in review is ready! 📊"
3. ✅ Report includes:
   - Check-ins completed (6/7 days)
   - Goals progressed (2/3 goals, 67%)
   - Daily plan completion (89% avg)
   - Mood avg (4.2/5, ↑ from 3.8 last week)
   - Energy avg (3.8/5)
   - Sleep avg (4.0/5)
   - Top insight ("Your best days had 8+ hours sleep")
4. ✅ Shareable (generate image, social share)
5. ✅ Saved in history ("View Past Weeks")

**FRs:** FR29, FR90

---

## Technical Implementation

### Cron Job (Monday 6am)
```typescript
Deno.serve(async () => {
  const users = await getAllActiveUsers();

  for (const user of users) {
    const report = await generateWeeklyReport(user.id);
    await saveReport(report);
    await sendNotification(user.id, "📊 Your week in review is ready!");
  }
});

async function generateWeeklyReport(userId: string) {
  const lastWeek = getLastWeekRange();

  return {
    checkins: await countCheckins(userId, lastWeek),
    goalsProgressed: await getGoalProgress(userId, lastWeek),
    planCompletion: await avgPlanCompletion(userId, lastWeek),
    moodAvg: await avgMood(userId, lastWeek),
    energyAvg: await avgEnergy(userId, lastWeek),
    sleepAvg: await avgSleep(userId, lastWeek),
    topInsight: await generateInsight(userId, lastWeek),
  };
}
```

### Database Schema
```sql
CREATE TABLE weekly_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL,
  report_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Dependencies
**Prerequisites:** All Sprint 2 stories (uses data from check-ins, goals, plans)

**Coverage Target:** 75%+

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
