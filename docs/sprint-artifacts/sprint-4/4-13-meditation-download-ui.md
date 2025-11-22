# Story 4.13: Meditation Download UI
**Epic:** 4 - Mind & Emotion | **P1** | **1 SP** | **backlog**

## User Story
**As a** premium user, **I want** a download button on meditation cards, **So that** I can download meditations for offline use.

## Context
Extracted from Story 4.1 code review findings (AC8 - Medium Priority).
Backend infrastructure already exists - only UI missing.

## Acceptance Criteria
1. ✅ Download button visible on MeditationCard for premium users
2. ✅ Progress indicator shows download percentage (0-100%)
3. ✅ Free users see premium upsell on download tap
4. ✅ Downloaded badge shows on completed downloads
5. ✅ Download queue manages max 3 concurrent downloads

## Tech
```dart
// UI components in meditation_card.dart
// Use existing DownloadMeditationUseCase
// Add CircularProgressIndicator for download progress
```

**Dependencies:** Story 4.1 ✓ | **Coverage:** 80%+

## Existing Implementation
- ✅ DownloadMeditationUseCase (lib/features/mind_emotion/domain/usecases/download_meditation_usecase.dart)
- ✅ Repository.downloadAudio method
- ✅ Tier check logic
- ✅ Local storage in app documents directory
- ❌ Missing: Download button UI in MeditationCard

## Tasks
- [ ] Add download IconButton to MeditationCard widget
- [ ] Implement download progress indicator (CircularProgressIndicator)
- [ ] Add premium upsell dialog for free users
- [ ] Show "Downloaded" badge on completed downloads
- [ ] Add download queue UI (max 3 concurrent)
- [ ] Handle download cancellation
- [ ] Write widget tests for download UI

**MVP:** Optional - nice to have but not critical for launch
**Estimated Effort:** 1 SP (UI only, backend done)
