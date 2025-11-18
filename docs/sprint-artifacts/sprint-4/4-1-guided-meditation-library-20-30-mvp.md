# Story 4.1: Guided Meditation Library (20-30 MVP)
**Epic:** 4 - Mind & Emotion | **P0** | **3 SP** | **ready-for-dev**

## User Story
**As a** user wanting to meditate, **I want** access to guided meditations, **So that** I can reduce stress and improve focus.

## Acceptance Criteria
1. ✅ Library with 20-30 meditations (MVP)
2. ✅ Categories: Stress Relief, Sleep, Focus, Anxiety, Gratitude
3. ✅ Lengths: 5, 10, 15, 20 minutes
4. ✅ Free tier: 3 rotating meditations (weekly), Premium: Full library
5. ✅ Audio cached for offline playback
6. ✅ Player: Play/pause, scrubber, skip ±15s
7. ✅ Completion tracked (meditation_id, duration, completed)

**FRs:** FR47-FR51

## Tech
```sql
CREATE TABLE meditations (
  id UUID PRIMARY KEY,
  title TEXT,
  category TEXT,
  duration INT, -- seconds
  audio_url TEXT,
  is_premium BOOLEAN DEFAULT TRUE
);
CREATE TABLE meditation_completions (
  user_id UUID,
  meditation_id UUID,
  completed_at TIMESTAMPTZ,
  duration_seconds INT
);
```
**Dependencies:** Epic 1 | **Coverage:** 80%+

## Dev Agent Record

- **Status Updated to ready-for-dev:** 2025-11-17
- **Dev Agent:** Claude Haiku 4.5
- **Purpose:** Ready for development phase
