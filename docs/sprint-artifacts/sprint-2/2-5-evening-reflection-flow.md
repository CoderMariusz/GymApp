# Story 2.5: Evening Reflection Flow

**Epic:** Epic 2 - Life Coach MVP
**Priority:** P0 | **Status:** drafted | **Effort:** 2 SP

---

## User Story
**As a** user ending my day
**I want** to complete an evening reflection
**So that** I can review accomplishments and prepare for tomorrow

---

## Acceptance Criteria
1. ✅ Prompt appears at set time (default 8pm, customizable)
2. ✅ User reviews daily plan completion (auto-filled checkboxes)
3. ✅ User adds accomplishments ("What went well today?")
4. ✅ User notes tomorrow priorities ("What's important tomorrow?")
5. ✅ Optional gratitude prompt ("3 good things today")
6. ✅ Reflection saves to DB (completion %, accomplishments, tomorrow, gratitude)
7. ✅ "Skip for today" option
8. ✅ Data used by AI for next day's plan
9. ✅ Target completion time: <2 minutes

**FRs:** FR26, FR28

---

## Technical Implementation

### Database Schema
```sql
CREATE TABLE reflections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  completion_rate INT, -- % of daily plan completed
  accomplishments TEXT,
  tomorrow_priorities TEXT,
  gratitude TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);
```

### Notification Trigger
```dart
class EveningReflectionScheduler {
  void scheduleNotification() {
    final time = ref.read(userSettingsProvider).eveningReflectionTime;
    NotificationService.schedule(
      time: time,
      title: "Evening reflection 📝",
      body: "Review your day in 2 minutes",
    );
  }
}
```

---

## Dependencies
**Prerequisites:** Story 2.2 (Daily Plan for completion review)
**Enables:** Story 2.6 (Streak Tracking)

**Coverage Target:** 80%+

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
