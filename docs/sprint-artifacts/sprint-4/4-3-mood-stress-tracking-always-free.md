# Story 4.3: Mood & Stress Tracking (Always FREE)
**Epic:** 4 - Mind & Emotion | **P0** | **2 SP** | **drafted**

## User Story
**As a** user monitoring mental health, **I want** to track daily mood and stress, **So that** I identify patterns and triggers.

## Acceptance Criteria
1. ✅ Accessible from Mind tab (Quick Action)
2. ✅ Mood log: Emoji slider (1-5: 😢 😞 😐 😊 😄)
3. ✅ Stress log: Emoji slider (1-5: 😌 😐 😰 😫 😱)
4. ✅ Optional note: "What's causing this?"
5. ✅ Saves with timestamp (multiple per day allowed)
6. ✅ ALWAYS FREE (even free tier users)
7. ✅ Trend charts (7-day, 30-day line graphs)
8. ✅ Data shared with Life Coach and Fitness modules

**FRs:** FR55-FR59

## Tech
```sql
CREATE TABLE mood_logs (
  id UUID PRIMARY KEY,
  user_id UUID,
  timestamp TIMESTAMPTZ,
  mood_score INT CHECK (mood_score BETWEEN 1 AND 5),
  note TEXT
);
CREATE TABLE stress_logs (
  id UUID PRIMARY KEY,
  user_id UUID,
  timestamp TIMESTAMPTZ,
  stress_score INT CHECK (stress_score BETWEEN 1 AND 5),
  note TEXT
);
```
**Dependencies:** Epic 1 | **Enables:** 4.12 (Cross-Module), 3.10 (Fitness stress query)
**Coverage:** 80%+
