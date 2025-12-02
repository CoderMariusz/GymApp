# Story 4.8: Sleep Meditations & Ambient Sounds
**Epic:** 4 - Mind & Emotion | **P1** | **2 SP** | **ready-for-dev**

## User Story
**As a** user struggling to fall asleep, **I want** sleep meditations and ambient sounds, **So that** I relax and sleep better.

## Acceptance Criteria
1. ✅ Sleep meditations: 10-30 minute guided sleep stories
2. ✅ Ambient sounds: Rain, Ocean, Forest, White Noise, Campfire
3. ✅ Sleep timer: Auto-stop after duration (10, 20, 30, 60 min, or Until finished)
4. ✅ Audio fades out smoothly (30-second fade)
5. ✅ Screen dims during playback (low brightness mode)
6. ✅ Completion tracked (if user falls asleep, track start time)
7. ✅ Premium feature (Free tier: 3 sleep meditations)

**FRs:** FR73-FR75

## Tech
```sql
CREATE TABLE sleep_meditations (
  id UUID PRIMARY KEY,
  title TEXT,
  duration INT,
  audio_url TEXT,
  is_premium BOOLEAN
);
CREATE TABLE ambient_sounds (
  id UUID PRIMARY KEY,
  name TEXT,
  audio_url TEXT,
  loop BOOLEAN DEFAULT TRUE
);
```
**Dependencies:** 4.1 (similar to meditation library) | **Coverage:** 75%+

## Dev Agent Record

- **Status Updated to ready-for-dev:** 2025-11-17
- **Dev Agent:** Claude Haiku 4.5
- **Purpose:** Ready for development phase
