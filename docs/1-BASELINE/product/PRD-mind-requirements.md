# Mind & Emotion Module - Product Requirements

<!-- AI-INDEX: mind, emotion, meditation, mood-tracking, cbt, journaling, mental-health, breathing, sleep -->

**Moduł:** Mind & Emotion Coach
**Cena:** 2.99 EUR/month
**Status:** ~40% zaimplementowane

---

## Spis Treści

1. [Module Overview](#1-module-overview)
2. [Functional Requirements](#2-functional-requirements)
3. [User Flows](#3-user-flows)
4. [Content Library](#4-content-library)
5. [Cross-Module Integration](#5-cross-module-integration)
6. [Technical Notes](#6-technical-notes)

---

## 1. Module Overview

### Core Value Proposition

**Holistic mental wellness** combining meditation, mood tracking, CBT chat, and journaling in one integrated module that communicates with Fitness and Life Coach.

### Key Features

| Feature | Priority | Free? | Value |
|---------|----------|-------|-------|
| Mood Tracking | P0 (MVP) | ✅ Always FREE | Daily check-in, trends |
| Stress Tracking | P0 (MVP) | ✅ Always FREE | Shared with Fitness |
| Guided Meditations | P0 (MVP) | 3 rotating | 20-30 MVP |
| Breathing Exercises | P0 (MVP) | ✅ | 5 techniques |
| CBT Chat | P0 (MVP) | 1/day | Unlimited (premium) |
| Journaling | P0 (MVP) | Premium | E2E encrypted |
| Mental Health Screening | P0 (MVP) | ✅ | GAD-7, PHQ-9 |
| Sleep Meditations | P0 (MVP) | Premium | 10+ stories |
| Gratitude Exercises | P0 (MVP) | ✅ | "3 Good Things" |

### Mental Health Disclaimer

**IMPORTANT:** LifeOS is NOT a replacement for professional mental health care.
- Crisis resources always visible (UK: 116 123, Poland: 116 123)
- High-risk scores prompt professional help recommendations
- No medical diagnosis or treatment

---

## 2. Functional Requirements

### 2.1 Meditation (FR47-FR54)

**FR47: Guided Meditation Library**
- MVP: 20-30 meditations
- P1: 100+ meditations
- Lengths: 5, 10, 15, 20 minutes
- Themes: Stress, Sleep, Focus, Anxiety, Gratitude
- Professional voice narration

**FR48: Filter Meditations**
- Filter by:
  - Length (5/10/15/20 min)
  - Theme (Stress/Sleep/Focus/Anxiety/Gratitude)
  - Type (Guided/Unguided/Body Scan/Visualization)
  - Favorites only
- Sort by: Popular, Newest, Recommended

**FR49: Free Tier Access**
- 3 rotating meditations available free
- Rotation: Weekly (every Monday)
- Premium preview: 30-second clips of locked content

**FR50: Premium Full Access**
- All meditations unlocked
- New content monthly
- Exclusive premium meditations

**FR51: Offline Playback**
- Downloaded meditations play offline
- Cache up to 100MB total
- Auto-download favorites
- Quality selection (high/medium/low)

**FR52: Completion Tracking**
- Track meditation sessions completed
- Total minutes meditated
- Streaks (consecutive days)
- Calendar view

**FR53: Favorite Meditations**
- User can favorite meditations
- Quick access from favorites tab
- Synced across devices

**FR54: AI Recommendations**
- System recommends based on:
  - Current mood (from check-in)
  - Stress level
  - Time of day
  - Previous preferences
  - Recent sleep quality

### 2.2 Mood & Stress Tracking (FR55-FR60)

**FR55: Daily Mood Tracking (ALWAYS FREE)**
- 1-5 scale with emoji
- Quick tap interface
- Multiple entries per day allowed
- Time-stamped
- No paywall ever

**FR56: Stress Level Tracking**
- 1-5 scale
- Tracked separately from mood
- Shared with Fitness & Life Coach
- Informs cross-module insights

**FR57: Notes and Triggers**
- Optional notes on entries
- Suggested triggers (Work, Relationships, Health, Finance)
- Custom triggers
- Searchable history

**FR58: Trends Visualization**
- Weekly mood chart
- Monthly trends
- Correlations shown:
  - Mood vs Sleep
  - Mood vs Workouts
  - Stress vs Meditation

**FR59: Cross-Module Data Sharing**
- Mood/stress shared with:
  - Life Coach (daily plan adjustments)
  - Fitness (workout intensity suggestions)
- User can disable sharing in settings

**FR60: Correlation Insights**
- System calculates correlations:
  - "Your mood is 40% better on days you exercise"
  - "Stress drops 25% after meditation"
  - "Best sleep quality follows evening meditation"

### 2.3 CBT & Journaling (FR61-FR65)

**FR61: CBT Chat**
- AI-guided cognitive behavioral therapy conversations
- Focus areas: Anxiety, Negative thoughts, Stress, Relationships
- Techniques: Thought challenging, Reframing, Grounding
- Free: 1 conversation/day
- Premium: Unlimited

**FR62: Private Journaling**
- End-to-end encrypted (E2EE)
- Rich text editor
- Daily prompts (optional)
- Photo attachments (encrypted)

**FR63: AI Journal Analysis (Opt-in)**
- Sentiment analysis
- Theme detection
- Coping strategy suggestions
- Requires explicit consent

**FR64: Journal History**
- Searchable by date/keyword
- Calendar view
- Tag filtering
- Mood at time of entry shown

**FR65: Journal Export**
- Export to PDF
- Export to JSON
- GDPR compliance

### 2.4 Mental Health Screening (FR66-FR70)

**FR66: GAD-7 Anxiety Screening**
- 7-question validated questionnaire
- Score interpretation
- Recommended frequency: Every 2 weeks
- Track scores over time

**FR67: PHQ-9 Depression Screening**
- 9-question validated questionnaire
- Score interpretation
- Recommended frequency: Every 2 weeks
- Track scores over time

**FR68: Score History**
- Chart of scores over time
- Trend analysis
- Compare to population norms

**FR69: Crisis Resources**
- Automatically shown for high scores:
  - GAD-7 > 15 (severe anxiety)
  - PHQ-9 > 20 (severe depression)
- Crisis hotlines (UK, Poland, EU)
- "Talk to someone now" button

**FR70: Professional Help Recommendation**
- For moderate-severe scores
- Links to find therapists
- Explanation of what scores mean
- Encouragement to seek help

### 2.5 Breathing & Sleep (FR71-FR76)

**FR71: Breathing Exercises (5 Techniques)**
| Technique | Pattern | Use Case |
|-----------|---------|----------|
| Box Breathing | 4-4-4-4 | Calm anxiety |
| 4-7-8 Breathing | 4-7-8 | Sleep prep |
| Calming Breath | 4-6 | Stress relief |
| Energizing Breath | 2-2-2-2 | Morning energy |
| Sleep Breathing | 4-8 | Fall asleep |

**FR72: Breathing Visual Guides**
- Animated breathing circles
- Haptic feedback
- Audio cues (optional)
- Customizable duration (1-10 min)

**FR73: Sleep Meditations**
- 10-30 minute sleep stories
- Ambient backgrounds
- Voice + music
- Auto-stop at end or fade out

**FR74: Sleep Timer**
- User sets timer (15/30/45/60 min)
- Gradual volume decrease
- Auto-stop playback
- Works with any audio

**FR75: Ambient Sounds**
- Rain, Ocean, Forest, Fire, White noise
- Mixable (rain + fire)
- Loopable
- Download for offline

**FR76: Gratitude Exercises**
- "3 Good Things" daily prompt
- Morning gratitude intention
- Evening gratitude reflection
- Gratitude journal section

---

## 3. User Flows

### 3.1 Quick Mood Entry Flow

```
1. User taps "How are you feeling?"
2. Emoji mood selector (1-5)
3. Optional: Stress level (1-5)
4. Optional: Add note or trigger
5. Tap "Save"
6. Entry added to history
7. If low mood → Suggest meditation
```

### 3.2 Meditation Flow

```
1. User opens Mind tab
2. Sees: "Recommended for you" based on mood
3. Browses library or selects recommendation
4. Taps meditation card
5. Preview screen: duration, description
6. Taps "Start"
7. 3-second countdown with breathing animation
8. Meditation plays (audio + visual guide)
9. Completion screen with streak update
10. Prompt: "How do you feel now?"
```

### 3.3 CBT Chat Flow

```
1. User taps "Talk to AI Therapist"
2. Free tier check: "1 session remaining today"
3. AI greeting: "What's on your mind today?"
4. User describes situation
5. AI uses CBT techniques:
   - Identify thoughts
   - Challenge distortions
   - Reframe perspective
6. Session summary with takeaways
7. Option to save insights
```

### 3.4 Journaling Flow

```
1. User taps "New Journal Entry"
2. Daily prompt shown (optional)
3. User writes freely
4. Mood tag added automatically
5. Optional: Add photo
6. Tap "Save" (encrypted immediately)
7. Entry visible in history
8. AI analysis available (if opted in)
```

---

## 4. Content Library

### 4.1 Meditation Themes

| Theme | MVP Count | P1 Count |
|-------|-----------|----------|
| Stress Relief | 5 | 20 |
| Sleep | 5 | 20 |
| Focus | 3 | 15 |
| Anxiety | 4 | 15 |
| Gratitude | 3 | 15 |
| Body Scan | 2 | 10 |
| Morning | 2 | 10 |
| **Total** | **24** | **105** |

### 4.2 Breathing Techniques

| Technique | Duration Options | Difficulty |
|-----------|-----------------|------------|
| Box Breathing | 2, 5, 10 min | Beginner |
| 4-7-8 | 2, 5, 10 min | Beginner |
| Calming | 2, 5 min | Beginner |
| Energizing | 2 min | Intermediate |
| Sleep | 5, 10 min | Beginner |

### 4.3 Sleep Content

| Type | MVP Count |
|------|-----------|
| Sleep Stories | 5 |
| Sleep Meditations | 5 |
| Ambient Sounds | 6 |

---

## 5. Cross-Module Integration

### 5.1 Sends to Fitness

| Data | Usage |
|------|-------|
| Stress level | Adjust workout intensity |
| Sleep quality | Suggest rest vs workout |
| Recent anxiety | Consider lighter exercise |

### 5.2 Sends to Life Coach

| Data | Usage |
|------|-------|
| Mood | Daily plan adjustments |
| Meditation completed | Update plan |
| Journal sentiment | AI coach context |

### 5.3 Cross-Module Insights

| Trigger | Insight |
|---------|---------|
| High stress detected | "Consider 5-min breathing exercise" |
| Mood trending down | "Your mood improves 40% after workouts" |
| Poor sleep + stress | "Evening meditation may help sleep" |

---

## 6. Technical Notes

### Database Tables

```sql
-- Drift (SQLite) tables
mood_logs (id, user_id, mood, stress, note, triggers_json, created_at)
meditation_sessions (id, user_id, meditation_id, duration, completed_at)
meditation_favorites (id, user_id, meditation_id)
meditation_downloads (id, user_id, meditation_id, file_path, size)
journal_entries (id, user_id, content_encrypted, mood, created_at)
mental_health_screenings (id, user_id, type, score, answers_json, created_at)
breathing_sessions (id, user_id, technique, duration, created_at)
```

### E2E Encryption (Journals)

```dart
// Client-side encryption using user's key
final encryptedContent = AES256GCM.encrypt(
  plaintext: journalContent,
  key: userDerivedKey, // From user password
  nonce: randomNonce,
);
// Server never sees plaintext
```

### Performance Requirements

| Metric | Target |
|--------|--------|
| Meditation Start | <100ms |
| Audio Buffering | <500ms |
| Mood Entry Save | <200ms |
| Journal Encrypt/Save | <500ms |
| Screening Calculate | <100ms |

### Offline Support

| Feature | Offline? |
|---------|----------|
| Mood tracking | ✅ |
| Downloaded meditations | ✅ |
| Breathing exercises | ✅ |
| Journal writing | ✅ |
| CBT chat | ❌ (requires AI) |
| New meditation browse | ❌ |

---

## Powiązane Dokumenty

- [PRD-overview.md](./PRD-overview.md) - Przegląd produktu
- [ARCH-security.md](../architecture/ARCH-security.md) - E2E encryption details
- [epic-4-mind.md](../../2-MANAGEMENT/epics/epic-4-mind.md) - Mind module stories
- [mind-module.md](../../3-ARCHITECTURE/system-design/mind-module.md) - Technical design

---

*FR47-FR76 | 30 Functional Requirements | ~40% implemented*
