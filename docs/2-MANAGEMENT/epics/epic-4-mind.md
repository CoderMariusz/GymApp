# Epic 4: Mind & Emotion MVP

<!-- AI-INDEX: epic-4, mind, emotion, meditation, mood-tracking, cbt, journaling, mental-health, breathing -->

**Epic ID:** EPIC-4
**Status:** 🔄 ~40% Complete
**Priority:** P0 (MVP Critical)
**Stories:** 12

---

## Overview

| Aspect | Value |
|--------|-------|
| **Goal** | Deliver meditation library, mood tracking, CBT chat, and mental health support |
| **Value** | Holistic mental wellness integrated with Fitness and Life Coach |
| **FRs Covered** | FR47-FR76 (Mind module) |
| **Dependencies** | Epic 1 (auth, E2E encryption for journals) |
| **Sprint** | Sprint 4 |

---

## User Stories

| ID | Story | Points | Status | Sprint |
|----|-------|--------|--------|--------|
| 4.1 | Guided Meditation Library (20-30 MVP) | 8 | 🔄 In Progress | 4 |
| 4.2 | Meditation Player with Breathing Animation | 5 | ✅ Done | 4 |
| 4.3 | Mood & Stress Tracking (Always FREE) | 5 | ✅ Done | 4 |
| 4.4 | CBT Chat with AI | 8 | ⏳ Planned | 4 |
| 4.5 | Private Journaling (E2E Encrypted) | 8 | ⏳ Planned | 4 |
| 4.6 | Mental Health Screening (GAD-7, PHQ-9) | 5 | ✅ Done | 4 |
| 4.7 | Breathing Exercises (5 Techniques) | 5 | ⏳ Planned | 4 |
| 4.8 | Sleep Meditations & Ambient Sounds | 5 | ⏳ Planned | 4 |
| 4.9 | Gratitude Exercises | 3 | ⏳ Planned | 4 |
| 4.10 | AI Meditation Recommendations | 5 | ⏳ Planned | 4 |
| 4.11 | Mood-Workout Correlation Insights | 5 | ⏳ Planned | 4 |
| 4.12 | Cross-Module: Share Mood/Stress | 5 | ⏳ Planned | 4 |

**Total Points:** 67 | **Completed:** 27

---

## Story Details

### Story 4.1: Guided Meditation Library

**As a** user seeking meditation
**I want** to browse guided meditations
**So that** I can find the right meditation for my needs

**Acceptance Criteria:**
1. Library with 20-30 meditations (MVP)
2. Filter by length: 5, 10, 15, 20 min
3. Filter by theme: Stress, Sleep, Focus, Anxiety, Gratitude
4. Free tier: 3 rotating meditations
5. Premium: Full access
6. Preview: 30-second clips for locked
7. Favorites list
8. Download for offline (up to 100MB cache)
9. New content monthly (P1)

---

### Story 4.2: Meditation Player

**As a** user starting meditation
**I want** a calming player with visual guides
**So that** I can follow along easily

**Acceptance Criteria:**
1. Full-screen player
2. Audio playback with progress bar
3. Breathing animation (optional)
4. Background playback supported
5. Sleep timer
6. Play offline (downloaded)
7. Volume control
8. Track completion → Update streaks

---

### Story 4.3: Mood & Stress Tracking (ALWAYS FREE)

**As a** user tracking mental state
**I want** to log mood and stress daily
**So that** I can see trends over time

**Acceptance Criteria:**
1. Mood (1-5 with emoji) - Always FREE
2. Stress level (1-5)
3. Optional notes/triggers
4. Multiple entries per day
5. Weekly/monthly trend charts
6. Shared with Fitness & Life Coach (cross-module)
7. Works offline
8. No paywall ever for mood tracking

---

### Story 4.4: CBT Chat with AI

**As a** user dealing with negative thoughts
**I want** to chat with AI therapist
**So that** I can challenge and reframe thoughts

**Acceptance Criteria:**
1. CBT-guided conversations
2. Techniques: Thought challenging, Reframing, Grounding
3. Free: 1 conversation/day
4. Premium: Unlimited
5. Save insights from sessions
6. Crisis resources shown when needed
7. Clear disclaimer: Not replacement for therapy

---

### Story 4.5: Private Journaling (E2EE)

**As a** user journaling thoughts
**I want** my entries encrypted
**So that** no one can read them except me

**Acceptance Criteria:**
1. End-to-end encrypted (AES-256-GCM)
2. Server never sees plaintext
3. Rich text editor
4. Daily prompts (optional)
5. Photo attachments (encrypted)
6. AI analysis (opt-in only)
7. Search by date/keyword
8. Export to PDF/JSON

---

### Story 4.6: Mental Health Screening

**As a** user monitoring mental health
**I want** validated screening tools
**So that** I can track anxiety/depression symptoms

**Acceptance Criteria:**
1. GAD-7 (anxiety) - 7 questions
2. PHQ-9 (depression) - 9 questions
3. Score interpretation
4. Track scores over time
5. Crisis resources for high scores (GAD-7 >15, PHQ-9 >20)
6. Recommend professional help
7. Clear disclaimer

---

### Story 4.7: Breathing Exercises

**As a** user managing stress
**I want** guided breathing exercises
**So that** I can calm down quickly

**Techniques:**
| Name | Pattern | Use Case |
|------|---------|----------|
| Box Breathing | 4-4-4-4 | Calm anxiety |
| 4-7-8 | 4-7-8 | Sleep prep |
| Calming | 4-6 | Stress relief |
| Energizing | 2-2-2-2 | Morning energy |
| Sleep | 4-8 | Fall asleep |

**Acceptance Criteria:**
1. 5 techniques available
2. Animated visual guide
3. Haptic feedback
4. Duration: 1-10 min
5. Works offline

---

## Definition of Done

- [x] Meditation player working
- [x] Mood tracking implemented
- [x] GAD-7/PHQ-9 functional
- [ ] Full meditation library loaded
- [ ] CBT chat implemented
- [ ] E2E encrypted journaling
- [ ] Breathing exercises
- [ ] Sleep meditations
- [ ] Cross-module sharing
- [ ] 80% test coverage

---

## Technical Architecture

```
lib/features/mind_emotion/
├── data/
│   ├── repositories/
│   │   ├── meditation_repository.dart
│   │   └── mood_repository.dart
│   └── datasources/
│       └── local_mind_datasource.dart
├── domain/
│   ├── models/
│   │   ├── meditation.dart
│   │   ├── mood_log.dart
│   │   └── journal_entry.dart
│   └── usecases/
│       └── encrypt_journal_usecase.dart
└── presentation/
    ├── pages/
    │   ├── meditation_library_page.dart
    │   ├── mood_tracking_page.dart
    │   └── journal_page.dart
    └── providers/
        └── mind_providers.dart
```

---

## Database Tables

```sql
meditation_sessions (id, user_id, meditation_id, duration, completed_at)
meditation_favorites (id, user_id, meditation_id)
meditation_downloads (id, user_id, meditation_id, file_path)
mood_logs (id, user_id, mood, stress, triggers, note, created_at)
journal_entries (id, user_id, encrypted_content, iv, created_at)
mental_health_screenings (id, user_id, type, score, answers, created_at)
```

---

## Security Requirements

| Data | Protection |
|------|------------|
| Journal entries | E2EE (AES-256-GCM) |
| Mental health notes | E2EE |
| Mood score | RLS (numeric only for CMI) |
| Stress level | RLS (numeric only for CMI) |

---

**Source:** `docs/ecosystem/epics.md` + `docs/modules/module-fitness/epics.md`
