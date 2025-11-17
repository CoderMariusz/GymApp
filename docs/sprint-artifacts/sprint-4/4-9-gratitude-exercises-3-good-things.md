# Story 4.9: Gratitude Exercises ("3 Good Things")
**Epic:** 4 - Mind & Emotion | **P2** | **1 SP** | **ready-for-dev**

## User Story
**As a** user cultivating gratitude, **I want** to log 3 good things daily, **So that** I improve mental wellbeing.

## Acceptance Criteria
1. ✅ Accessible from Mind tab
2. ✅ Daily prompt: "What are 3 good things from today?"
3. ✅ 3 text inputs (short)
4. ✅ Entries saved with timestamp
5. ✅ History viewable (past entries)
6. ✅ Streak tracking (consecutive days)
7. ✅ Incorporated into Evening Reflection (Life Coach module)

**FRs:** FR76

## Tech
```sql
CREATE TABLE gratitude_logs (
  id UUID PRIMARY KEY,
  user_id UUID,
  date DATE,
  item_1 TEXT,
  item_2 TEXT,
  item_3 TEXT,
  timestamp TIMESTAMPTZ
);
```
**Dependencies:** Epic 1 | **Integration:** Story 2.5 (Evening Reflection)
**Coverage:** 75%+

## Dev Agent Record

- **Status Updated to ready-for-dev:** 2025-11-17
- **Dev Agent:** Claude Haiku 4.5
- **Purpose:** Ready for development phase
