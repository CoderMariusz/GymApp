# Epic 2: Life Coach MVP

<!-- AI-INDEX: epic-2, life-coach, daily-plan, goals, ai-chat, check-in, coaching, morning, evening -->

**Epic ID:** EPIC-2
**Status:** 🔄 ~75% Complete
**Priority:** P0 (MVP Critical)
**Stories:** 10

---

## Overview

| Aspect | Value |
|--------|-------|
| **Goal** | Deliver AI-powered daily planning, goal tracking, check-ins, and AI coaching |
| **Value** | Users can plan their day, track goals, complete rituals, chat with AI |
| **FRs Covered** | FR6-FR29 (Life Coach module) |
| **Dependencies** | Epic 1 (auth, data sync) |
| **Sprint** | Sprint 2 |

---

## User Stories

| ID | Story | Points | Status | Sprint |
|----|-------|--------|--------|--------|
| 2.1 | Morning Check-in Flow | 5 | ✅ Done | 2 |
| 2.2 | AI Daily Plan Generation | 8 | ✅ Done | 2 |
| 2.3 | Goal Creation & Tracking | 5 | ✅ Done | 2 |
| 2.4 | AI Conversational Coaching | 8 | ✅ Done | 2 |
| 2.5 | Evening Reflection Flow | 5 | ✅ Done | 2 |
| 2.6 | Streak Tracking (Check-ins) | 5 | ✅ Done | 2 |
| 2.7 | Progress Dashboard | 5 | 🔄 In Progress | 2 |
| 2.8 | Daily Plan Manual Adjustment | 3 | 🔄 In Progress | 2 |
| 2.9 | Goal Suggestions (AI) | 5 | ⏳ Planned | 3 |
| 2.10 | Weekly Summary Report | 5 | ⏳ Planned | 3 |

**Total Points:** 54 | **Completed:** 41

---

## Story Details

### Story 2.1: Morning Check-in Flow

**As a** user starting my day
**I want** to complete a quick morning check-in
**So that** AI can generate a personalized daily plan

**Acceptance Criteria:**
1. Modal appears on first app open (if not done today)
2. Rate mood (1-5 emoji slider)
3. Rate energy (1-5 emoji slider)
4. Rate sleep quality (1-5 emoji slider)
5. Optional note field
6. Haptic feedback on selection
7. "Generate My Plan" CTA triggers AI
8. "Skip for today" option
9. Saves to database
10. Accessible: VoiceOver reads emoji values

**Target:** <60 seconds completion

---

### Story 2.2: AI Daily Plan Generation

**As a** user who completed morning check-in
**I want** AI to generate a personalized daily plan
**So that** I know what to focus on today

**Acceptance Criteria:**
1. AI analyzes: mood, energy, sleep, stress, workouts
2. Generates 5-8 tasks/suggestions
3. Considers user's goals
4. Adapts to mood (high energy = more tasks)
5. Shows insight ("Your sleep was good!")
6. Saves to database
7. Items can be marked complete
8. Model based on tier (Free: Llama, Premium: GPT-4)
9. Timeout handling with fallback plan

---

### Story 2.3: Goal Creation & Tracking

**As a** user with personal goals
**I want** to create and track up to 3 goals (free)
**So that** I can measure progress

**Acceptance Criteria:**
1. Create goals from Goals screen
2. Fields: Title, Category, Target date, Description
3. Free: Max 3, Premium: Unlimited
4. Progress tracked (0-100%)
5. Mark as completed (celebration)
6. Archive or delete
7. Goals shown on Home tab
8. AI daily plan references goals

---

### Story 2.4: AI Conversational Coaching

**As a** user needing motivation
**I want** to chat with AI life coach
**So that** I get personalized guidance

**Acceptance Criteria:**
1. Chat from Home → "Chat with AI"
2. Send text messages
3. AI responds with advice/encouragement
4. AI has context (goals, mood, activity)
5. Personality: Sage (calm) vs Momentum (energetic)
6. Free: 3-5/day, Premium: Unlimited
7. History saved and viewable
8. Delete history (GDPR)
9. Response time: <2s (Llama), <3s (Claude)
10. Timeout handling

---

### Story 2.5: Evening Reflection Flow

**As a** user ending my day
**I want** to complete evening reflection
**So that** I review accomplishments and prepare tomorrow

**Acceptance Criteria:**
1. Prompt at set time (default 8pm)
2. Review daily plan completion
3. Add accomplishments text
4. Note tomorrow priorities
5. Optional gratitude
6. Saves to database
7. "Skip for today" option
8. Data used for next day's plan

**Target:** <2 minutes completion

---

### Story 2.6: Streak Tracking

**As a** user building habits
**I want** to see my check-in streak
**So that** I'm motivated to maintain consistency

**Acceptance Criteria:**
1. Streak counter on Home tab
2. Increments when both check-ins done
3. Breaks if both missed
4. 1 freeze per week (automatic)
5. Freeze availability shown
6. Milestones: Bronze (7d), Silver (30d), Gold (100d)
7. Celebration animation
8. Synced across devices
9. Push notification if about to break

---

## Definition of Done

- [x] Morning check-in implemented
- [x] AI daily plan generation working
- [x] Goals CRUD functional
- [x] AI chat with context
- [x] Evening reflection implemented
- [x] Streaks tracking working
- [ ] Progress charts complete
- [ ] Manual plan adjustment
- [ ] Weekly summary reports
- [ ] 80% test coverage

---

## Technical Architecture

```
lib/features/life_coach/
├── ai/
│   ├── daily_plan_generator.dart
│   ├── prompts/daily_plan_prompt.dart
│   └── providers/daily_plan_provider.dart
├── chat/
│   ├── conversational_coach.dart
│   └── presentation/pages/coach_chat_page.dart
├── goals/
│   └── presentation/pages/goals_list_page.dart
└── presentation/
    ├── pages/daily_plan_page.dart
    ├── pages/morning_check_in_page.dart
    └── pages/evening_reflection_page.dart
```

---

## AI Integration

| Feature | Model (Free) | Model (Premium) |
|---------|--------------|-----------------|
| Daily Plan | Llama 3 | Claude/GPT-4 |
| AI Chat | Llama 3 | Claude/GPT-4 |
| Goal Suggestions | Llama 3 | Claude |

---

**Source:** `docs/ecosystem/epics.md` (lines 267-598)
