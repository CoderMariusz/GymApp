# Story 4.7: Breathing Exercises (5 Techniques)
**Epic:** 4 - Mind & Emotion | **P1** | **2 SP** | **ready-for-dev**

## User Story
**As a** user needing quick stress relief, **I want** guided breathing exercises, **So that** I calm down in 2-5 minutes.

## Acceptance Criteria
1. ✅ Accessible from Mind tab (Quick Action)
2. ✅ 5 techniques: Box Breathing (4-4-4-4), 4-7-8 (sleep), Calm Breathing (5-5), Energizing (quick inhale, slow exhale), Sleep Prep (long exhale)
3. ✅ Visual circle (expands/contracts with rhythm)
4. ✅ Haptic feedback on inhale/exhale cues
5. ✅ Duration: User selects (2, 5, 10 minutes)
6. ✅ Completion tracked
7. ✅ No audio required (visual + haptic only)

**FRs:** FR71, FR72

## Tech
```sql
CREATE TABLE breathing_exercises (
  id UUID PRIMARY KEY,
  name TEXT,
  pattern TEXT, -- "4-4-4-4"
  description TEXT
);
CREATE TABLE breathing_completions (
  user_id UUID,
  exercise_id UUID,
  duration INT,
  completed_at TIMESTAMPTZ
);
```
**Dependencies:** Epic 1 | **Coverage:** 75%+

## Dev Agent Record

- **Status Updated to ready-for-dev:** 2025-11-17
- **Dev Agent:** Claude Haiku 4.5
- **Purpose:** Ready for development phase
