# Story 4.14: Meditation Completion Tracking Integration
**Epic:** 4 - Mind & Emotion | **P1** | **1 SP** | **backlog**

## User Story
**As a** user, **I want** my meditation completions automatically tracked, **So that** I can see my meditation history and progress.

## Context
Extracted from Story 4.1 code review findings (AC9 - Medium Priority).
Database schema and display logic exist - only playback integration missing.

## Acceptance Criteria
1. ✅ Completion tracked when meditation finishes playing
2. ✅ Duration listened recorded in meditation_sessions table
3. ✅ Completion count increments on MeditationCard
4. ✅ Partial sessions tracked (didn't finish full meditation)
5. ✅ Sync between Drift and Supabase

## Tech
```dart
// Integrate with MeditationAudioService (Story 4.2)
// Call trackSession() on audio completion
// Update completionCount on MeditationCard
```

**Dependencies:** Story 4.2 (Meditation Player) | **Coverage:** 80%+

## Existing Implementation
- ✅ meditation_sessions table in Drift and Supabase
- ✅ trackSession method in repository
- ✅ completionCount display on MeditationCard (line 247)
- ✅ RLS policies for user data isolation
- ❌ Missing: Integration with audio playback to trigger tracking

## Tasks
- [ ] Listen to audio player completion events
- [ ] Call trackSession when meditation completes
- [ ] Track partial completions (user stops early)
- [ ] Update completionCount in real-time
- [ ] Add completion animation on MeditationCard
- [ ] Write integration tests for tracking flow

**MVP:** Optional - analytics feature, not core functionality
**Estimated Effort:** 1 SP (integration only, infrastructure done)
**Blocker:** Depends on Story 4.2 (audio player)
