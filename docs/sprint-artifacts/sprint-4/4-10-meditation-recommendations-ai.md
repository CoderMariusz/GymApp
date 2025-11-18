# Story 4.10: Meditation Recommendations (AI)
**Epic:** 4 - Mind & Emotion | **P1** | **2 SP** | **ready-for-dev**

## User Story
**As a** user unsure which meditation to choose, **I want** personalized recommendations, **So that** I start meditating quickly.

## Acceptance Criteria
1. ✅ "Today's Meditation" card on Mind home (AI-recommended)
2. ✅ AI considers: Mood (from mood log), stress level, time of day, past preferences
3. ✅ Examples: High stress + morning → "Stress Relief (10 min)", Low energy + evening → "Sleep Meditation (20 min)"
4. ✅ User can tap "Start" → Meditation player opens
5. ✅ User can dismiss → Browse library instead
6. ✅ Recommendations refresh daily

**FRs:** FR54

## Tech
```typescript
// AI prompt: Analyze mood/stress → recommend meditation
const prompt = `
User context:
- Mood: ${mood}/5
- Stress: ${stress}/5
- Time: ${timeOfDay}
- Past preferences: ${favorites}
Recommend 1 meditation.
`;
```
**Dependencies:** 4.1 (Library), 4.3 (Mood/Stress data) | **Coverage:** 75%+

## Dev Agent Record

- **Status Updated to ready-for-dev:** 2025-11-17
- **Dev Agent:** Claude Haiku 4.5
- **Purpose:** Ready for development phase
