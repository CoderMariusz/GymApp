# Story 4.2: Meditation Player with Breathing Animation
**Epic:** 4 - Mind & Emotion | **P0** | **3 SP** | **drafted**

## User Story
**As a** user during meditation, **I want** a calming player with visual breathing guide, **So that** I stay focused and relaxed.

## Acceptance Criteria
1. ✅ Full-screen player (purple → deep blue gradient)
2. ✅ Breathing circle: Expands on "breathe in", contracts on "breathe out"
3. ✅ Live transcript (optional): Subtitles
4. ✅ Play/pause, scrubber, skip ±15s
5. ✅ Auto-lock prevention (screen stays on)
6. ✅ Haptic pulse during "breathe in" cues (gentle)
7. ✅ Completion: "Meditation complete! 🧘"
8. ✅ Track time toward daily goal

**FRs:** FR51, FR52

## Tech
```dart
// just_audio package for playback
// Lottie for breathing circle animation
// wakelock package to prevent screen lock
```
**Dependencies:** 4.1 | **Coverage:** 80%+
