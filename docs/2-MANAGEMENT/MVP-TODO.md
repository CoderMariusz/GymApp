# MVP TODO List - Master Backlog

<!-- AI-INDEX: todo, backlog, tasks, implementation, mvp, checklist -->

**Utworzono:** 2025-12-02
**Cel:** MVP 1.0 - działająca aplikacja bez płatności
**Szacowany czas:** ~48h

---

## Legenda

- ❌ Not Started
- 🔄 In Progress
- ✅ Done
- 🚫 Blocked
- ⏸️ Deferred

---

## PHASE 1: Critical Fixes (P0)

### 1.1 Replace Mock Repositories
**Priority:** P0 | **Est:** 6h | **Status:** ❌

| Task | File | Status |
|------|------|--------|
| Replace MockGoalsRepository | `lib/features/life_coach/goals/data/` | ❌ |
| Replace MockCheckInRepository | `lib/features/life_coach/check_in/data/` | ❌ |
| Replace MockPreferencesRepository | `lib/features/life_coach/` | ❌ |

**Acceptance Criteria:**
- [ ] GoalsRepository queries Drift database
- [ ] CheckInRepository queries Drift database
- [ ] PreferencesRepository queries user_settings table
- [ ] No `UnimplementedError` thrown

---

### 1.2 Fix Hardcoded User IDs
**Priority:** P0 | **Est:** 2h | **Status:** ❌

| Task | File | Status |
|------|------|--------|
| Inject userId from auth | `meditation_providers.dart` | ❌ |
| Inject UserTier from subscription | `meditation_providers.dart` | ❌ |
| Review all providers for hardcoding | `lib/features/**/*_provider*.dart` | ❌ |

**Pattern to apply:**
```dart
// BEFORE
userId: 'current_user_id' // TODO

// AFTER
final authState = ref.watch(authStateProvider);
final userId = authState.user?.id ?? '';
```

---

### 1.3 Exercise Library Persistence
**Priority:** P0 | **Est:** 4h | **Status:** ❌

| Task | Status |
|------|--------|
| Create Exercises Drift table | ❌ |
| Create ExerciseFavorites Drift table | ❌ |
| Implement ExerciseRepository with Drift | ❌ |
| Connect UI to repository | ❌ |
| Save custom exercises to DB | ❌ |
| Toggle favorites with persistence | ❌ |

---

## PHASE 2: Life Coach Completion (P1)

### 2.1 Goals Real Implementation
**Priority:** P1 | **Est:** 4h | **Status:** ❌

| Task | Status |
|------|--------|
| GoalsRepositoryImpl with Drift | ❌ |
| CRUD operations | ❌ |
| Progress tracking | ❌ |
| Goals limit (3 free, unlimited premium) | ❌ |
| Archive/complete goals | ❌ |

---

### 2.2 AI Chat UI (Optional for MVP)
**Priority:** P1 | **Est:** 8h | **Status:** ❌

| Task | Status |
|------|--------|
| Create `coach_chat_page.dart` | ❌ |
| Message input widget | ❌ |
| Message list widget | ❌ |
| AI response integration | ❌ |
| Chat history persistence | ❌ |
| Typing indicator | ❌ |

**Note:** Można pominąć dla MVP 1.0, Daily Plan wystarczy.

---

### 2.3 Streak UI Enhancement
**Priority:** P1 | **Est:** 3h | **Status:** ❌

| Task | Status |
|------|--------|
| Streak card na Home | ❌ |
| Progress bar to milestone | ❌ |
| Current/longest streak display | ❌ |

---

## PHASE 3: Mind Module (P1)

### 3.1 Meditation Player
**Priority:** P1 | **Est:** 8h | **Status:** ❌

| Task | Status |
|------|--------|
| Create `meditation_player_screen.dart` | ❌ |
| Integrate `just_audio` package | ❌ |
| Play/pause/seek controls | ❌ |
| Progress bar | ❌ |
| Background playback | ❌ |
| Session completion tracking | ❌ |
| Breathing animation (optional) | ❌ |

**Dependencies:**
- `just_audio: ^0.9.36` (already in pubspec)

---

### 3.2 Mood Tracking UI
**Priority:** P1 | **Est:** 4h | **Status:** ❌

| Task | Status |
|------|--------|
| Create `mood_tracking_page.dart` | ❌ |
| Mood slider (1-5 with emojis) | ❌ |
| Stress slider (1-5) | ❌ |
| Notes field | ❌ |
| Save to MoodLogs table | ❌ |
| History view | ❌ |
| Simple trend chart | ❌ |

---

### 3.3 Breathing Exercises
**Priority:** P1 | **Est:** 6h | **Status:** ❌

| Task | Status |
|------|--------|
| Create `breathing_exercise_page.dart` | ❌ |
| Breathing animation (circle expand/contract) | ❌ |
| 5 techniques: Box, 4-7-8, Calming, Energizing, Sleep | ❌ |
| Timer with phases | ❌ |
| Haptic feedback | ❌ |
| Duration selector (1-10 min) | ❌ |

---

### 3.4 Placeholder Meditations
**Priority:** P1 | **Est:** 2h | **Status:** ❌

| Task | Status |
|------|--------|
| Create 5 placeholder meditation entries | ❌ |
| Use free ambient sounds (URL or local) | ❌ |
| Categories: Stress, Sleep, Focus, Anxiety, Gratitude | ❌ |
| 5min, 10min, 15min durations | ❌ |

---

## PHASE 4: Polish & Testing (P1)

### 4.1 Core Fixes
**Priority:** P1 | **Est:** 4h | **Status:** ❌

| Task | Status |
|------|--------|
| Password reset deep link | ❌ |
| Error handling improvements | ❌ |
| Loading states consistency | ❌ |
| Empty states design | ❌ |

---

### 4.2 Navigation & UX
**Priority:** P1 | **Est:** 3h | **Status:** ❌

| Task | Status |
|------|--------|
| Bottom navigation consistency | ❌ |
| Back button handling | ❌ |
| Deep links testing | ❌ |
| Splash screen | ❌ |

---

### 4.3 Testing
**Priority:** P1 | **Est:** 8h | **Status:** ❌

| Task | Status |
|------|--------|
| Unit tests for repositories | ❌ |
| Widget tests for critical screens | ❌ |
| Integration test: Auth flow | ❌ |
| Integration test: Workout logging | ❌ |
| Integration test: Daily plan | ❌ |

---

## DEFERRED TO MVP 1.1 (P2)

### Onboarding Flow
| Task | Status |
|------|--------|
| Welcome screen | ⏸️ |
| Journey selection | ⏸️ |
| Initial goals | ⏸️ |
| AI personality choice | ⏸️ |
| Permissions | ⏸️ |
| Tutorial | ⏸️ |

---

### In-App Purchases
| Task | Status |
|------|--------|
| RevenueCat/Stripe integration | ⏸️ |
| Subscription tiers | ⏸️ |
| Trial logic | ⏸️ |
| Graceful degradation | ⏸️ |

---

### Push Notifications
| Task | Status |
|------|--------|
| Firebase re-enable | ⏸️ |
| FCM setup | ⏸️ |
| Device token storage | ⏸️ |
| Daily reminders | ⏸️ |
| Streak alerts | ⏸️ |

---

### Cross-Module Intelligence
| Task | Status |
|------|--------|
| Pattern detection algorithm | ⏸️ |
| AI insight generation | ⏸️ |
| Insight cards UI | ⏸️ |
| CMI Dashboard | ⏸️ |

---

### Advanced Features
| Task | Status |
|------|--------|
| CBT Chat | ⏸️ |
| E2E Encrypted Journaling | ⏸️ |
| Mental Health Screenings UI | ⏸️ |
| Weekly Summary Reports | ⏸️ |
| Social Sharing | ⏸️ |
| Badge System | ⏸️ |

---

## Implementation Order

```
Week 1: PHASE 1 (Critical Fixes)
├── 1.1 Replace Mock Repositories
├── 1.2 Fix Hardcoded IDs
└── 1.3 Exercise Library Persistence

Week 2: PHASE 2 + 3 (Features)
├── 2.1 Goals Real Implementation
├── 3.1 Meditation Player
├── 3.2 Mood Tracking UI
└── 3.3 Breathing Exercises

Week 3: PHASE 4 (Polish)
├── 3.4 Placeholder Meditations
├── 4.1 Core Fixes
├── 4.2 Navigation & UX
└── 4.3 Testing
```

---

## Definition of Done (MVP 1.0)

- [ ] User can register/login with email
- [ ] User can log workouts with Smart Pattern Memory
- [ ] User can view progress charts
- [ ] User can generate AI daily plans
- [ ] User can complete morning/evening check-ins
- [ ] User can create/track goals (real DB)
- [ ] User can track mood/stress
- [ ] User can play meditation (placeholder content)
- [ ] User can do breathing exercises
- [ ] No crashes from Mock repositories
- [ ] All hardcoded IDs replaced
- [ ] Basic test coverage (>50%)

---

## Notes

### Gdy zaczynasz task:
1. Zmień status na 🔄
2. Stwórz branch: `feature/task-name`
3. Po zakończeniu: PR + merge

### Gdy kończysz task:
1. Zmień status na ✅
2. Zaktualizuj ten plik
3. Commit z referencją do task ID

---

*Master TODO utworzone: 2025-12-02*
*Następna aktualizacja: Po każdym zakończonym PHASE*
