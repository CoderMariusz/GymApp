# Story 2.6: Streak Tracking (Check-ins)

**Epic:** Epic 2 - Life Coach MVP
**Priority:** P1 | **Status:** ready-for-dev | **Effort:** 3 SP

---

## User Story
**As a** user building daily habits
**I want** to see my check-in streak
**So that** I'm motivated to maintain consistency

---

## Acceptance Criteria
1. ✅ Streak counter on Home tab ("7-day streak! 🔥")
2. ✅ Streak increments when BOTH morning + evening completed
3. ✅ Breaks if both missed in a day
4. ✅ 1 streak freeze per week (automatic on first miss)
5. ✅ Freeze availability shown ("Freeze available: 1 this week")
6. ✅ Milestone badges: Bronze (7d), Silver (30d), Gold (100d)
7. ✅ Milestone celebration: Confetti + badge unlock
8. ✅ Synced across devices
9. ✅ Push notification if about to break ("Complete reflection to keep streak!")

**FRs:** FR29, FR85-FR87

---

## Technical Implementation

### Database Schema
```sql
CREATE TABLE streaks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('check-in', 'workout', 'meditation')),
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  freeze_used_this_week BOOLEAN DEFAULT FALSE,
  last_activity_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, type)
);
```

### Cron Job (Daily Streak Check)
```typescript
// Runs every day at 11:59pm
Deno.serve(async () => {
  const users = await getAllActiveUsers();

  for (const user of users) {
    const todayCheckin = await hasCheckinToday(user.id);
    const todayReflection = await hasReflectionToday(user.id);

    if (todayCheckin && todayReflection) {
      await incrementStreak(user.id, 'check-in');
    } else {
      await handleStreakBreak(user.id, 'check-in'); // Use freeze or reset
    }
  }
});
```

---

## Dependencies
**Prerequisites:** Story 2.1 (Morning Check-in), Story 2.5 (Evening Reflection)

**Coverage Target:** 80%+

---

## Dev Agent Record
**Context File:** 2-6-streak-tracking-check-ins.context.xml

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
