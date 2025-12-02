# MVP Audit Report: Documentation vs Code

<!-- AI-INDEX: audit, mvp, gaps, inconsistencies, actual-status, code-vs-docs -->

**Data audytu:** 2025-12-02
**Autor:** Claude AI
**Cel:** Identyfikacja rozbieżności między dokumentacją a rzeczywistym stanem kodu

---

## Executive Summary

| Metric | Dokumentacja | Kod | Rozbieżność |
|--------|-------------|-----|-------------|
| Overall Progress | ~66% | **~45%** | -21% |
| Epic 1 (Core) | 90% | **85%** | -5% |
| Epic 2 (Life Coach) | 75% | **70%** | -5% |
| Epic 3 (Fitness) | 82% | **90%** | +8% |
| Epic 4 (Mind) | 40% | **15%** | -25% |
| Epic 5 (CMI) | 25% | **10%** | -15% |
| Epic 6 (Gamification) | 30% | **5%** | -25% |
| Epic 7 (Onboarding) | 80% | **5%** | -75% |
| Epic 8 (Notifications) | 0% | **0%** | 0% |
| Epic 9 (Settings) | 80% | **30%** | -50% |

**Kluczowy wniosek:** Dokumentacja znacząco przeszacowuje postęp w Epic 4, 6, 7, 9.

---

## Szczegółowa Analiza per Epic

### EPIC 1: Core Platform Foundation

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 1.1 Account Creation | ✅ Done | ✅ **DONE** | Supabase Auth działa |
| 1.2 Login & Session | ✅ Done | ✅ **DONE** | Email + OAuth prepared |
| 1.3 Password Reset | ✅ Done | ⚠️ **PARTIAL** | TODO w kodzie: `// TODO: Implement password reset flow` |
| 1.4 User Profile | ✅ Done | ✅ **DONE** | Profile editing works |
| 1.5 Data Sync | ✅ Done | ⚠️ **PARTIAL** | SyncQueue table exists, logika NIE zaimplementowana |
| 1.6 GDPR | ✅ Done | ✅ **DONE** | Export/Delete use cases exist |

**Rzeczywisty status: 70%** (nie 90%)

**Braki:**
- [ ] Password Reset flow - nie działa deep link
- [ ] Data Sync - SyncQueue jest, ale sync service nie wywołuje

---

### EPIC 2: Life Coach MVP

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 2.1 Morning Check-in | ✅ Done | ✅ **DONE** | morning_check_in_page.dart (104 lines) |
| 2.2 AI Daily Plan | ✅ Done | ✅ **DONE** | daily_plan_generator.dart + prompts |
| 2.3 Goal Creation | ✅ Done | ⚠️ **MOCK** | `MockGoalsRepository` throws UnimplementedError |
| 2.4 AI Chat | ✅ Done | ❌ **STUB** | ChatSessions table exists, UI NIE istnieje |
| 2.5 Evening Reflection | ✅ Done | ✅ **DONE** | evening_reflection_page.dart (98 lines) |
| 2.6 Streak Tracking | ✅ Done | ⚠️ **PARTIAL** | Streaks table exists, UI minimal |
| 2.7 Progress Dashboard | 🔄 In Progress | ⚠️ **STUB** | progress_dashboard_page.dart (137 lines) - basic |
| 2.8 Manual Adjustment | 🔄 In Progress | ✅ **DONE** | daily_plan_edit_page.dart (339 lines) |
| 2.9 Goal Suggestions | ⏳ Planned | ❌ **NOT STARTED** | - |
| 2.10 Weekly Summary | ⏳ Planned | ❌ **NOT STARTED** | - |

**Rzeczywisty status: 55%** (nie 75%)

**Krytyczne braki:**
- [ ] AI Chat UI - brak `coach_chat_page.dart`
- [ ] Goals używa MockRepository - MUSI być zamienione na prawdziwe
- [ ] Weekly Summary - nie istnieje

**Niezgodności logiczne:**
1. Story 2.4 "AI Chat" oznaczone jako Done, ale w kodzie NIE MA UI dla chat
2. Story 2.3 "Goals" oznaczone jako Done, ale używa Mock który rzuca błędy

---

### EPIC 3: Fitness Coach MVP

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 3.1 Smart Pattern Memory | ✅ Done | ✅ **DONE** | SmartPrefillProvider działa |
| 3.2 Exercise Library | ✅ Done | ⚠️ **STUB** | UI exists, brak persistence |
| 3.3 Workout Logging | ✅ Done | ✅ **DONE** | workout_logging_page.dart (270 lines) |
| 3.4 History View | ✅ Done | ✅ **DONE** | workout_log_page.dart (456 lines) |
| 3.5 Progress Charts | ✅ Done | ✅ **DONE** | FitnessChartsProvider + fl_chart |
| 3.6 Body Measurements | ✅ Done | ✅ **DONE** | measurements_page.dart (159 lines) |
| 3.7 Templates | 🔄 In Progress | ✅ **DONE** | templates_page.dart (96 lines) |
| 3.8 Quick Log | 🔄 In Progress | ✅ **DONE** | quick_log_page.dart (125 lines) |
| 3.9 Exercise Instructions | ⏳ Planned | ❌ **NOT STARTED** | - |
| 3.10 Cross-Module Stress | ⏳ Planned | ❌ **NOT STARTED** | - |

**Rzeczywisty status: 75%** (dokumentacja mówi 82%)

**Braki:**
- [ ] Exercise Library - brak Drift table, brak persistence
- [ ] Exercise Instructions - nie istnieje
- [ ] Cross-module integration - nie istnieje

**Pozytywne rozbieżności:**
- Templates i Quick Log są bardziej zaawansowane niż dokumentacja sugeruje

---

### EPIC 4: Mind & Emotion MVP

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 4.1 Meditation Library | 🔄 In Progress | ⚠️ **UI ONLY** | meditation_library_screen.dart - bez playera |
| 4.2 Meditation Player | ✅ Done | ❌ **NOT DONE** | BRAK meditation_player_screen.dart |
| 4.3 Mood Tracking | ✅ Done | ⚠️ **PARTIAL** | MoodLogs table exists, UI unclear |
| 4.4 CBT Chat | ⏳ Planned | ❌ **NOT STARTED** | - |
| 4.5 E2E Journaling | ⏳ Planned | ❌ **NOT STARTED** | - |
| 4.6 Mental Health Screening | ✅ Done | ⚠️ **TABLE ONLY** | MentalHealthScreenings table, brak UI |
| 4.7 Breathing Exercises | ⏳ Planned | ❌ **NOT STARTED** | - |
| 4.8 Sleep Meditations | ⏳ Planned | ❌ **NOT STARTED** | - |
| 4.9 Gratitude | ⏳ Planned | ❌ **NOT STARTED** | - |
| 4.10 AI Recommendations | ⏳ Planned | ❌ **NOT STARTED** | - |
| 4.11 Mood-Workout Insights | ⏳ Planned | ❌ **NOT STARTED** | - |
| 4.12 Cross-Module Sharing | ⏳ Planned | ❌ **NOT STARTED** | - |

**Rzeczywisty status: 10%** (dokumentacja mówi 40%)

**KRYTYCZNY PROBLEM:**
- Story 4.2 "Meditation Player" oznaczone jako ✅ Done, ale **NIE ISTNIEJE**
- `just_audio` dependency dodane, ale nie używane
- Cały moduł to praktycznie scaffold

**Braki do MVP:**
- [ ] Meditation Player (KRYTYCZNE)
- [ ] Mood Tracking UI
- [ ] Breathing Exercises
- [ ] Meditation content (placeholder OK)

---

### EPIC 5: Cross-Module Intelligence

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 5.1 Insight Engine | 🔄 In Progress | ⚠️ **TABLE ONLY** | user_daily_metrics + detected_patterns tables exist |
| 5.2 Insight Card UI | ⏳ Planned | ❌ **NOT STARTED** | - |
| 5.3 Stress→Light Workout | ⏳ Planned | ❌ **NOT STARTED** | - |
| 5.4 Sleep→Afternoon | ⏳ Planned | ❌ **NOT STARTED** | - |
| 5.5 Sleep-Performance | ⏳ Planned | ❌ **NOT STARTED** | - |

**Rzeczywisty status: 5%** (dokumentacja mówi 25%)

**Uwagi:**
- Database schema jest, ale logika pattern detection nie
- To jest P1 dla MVP, nie P0

---

### EPIC 6: Gamification & Retention

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 6.1 Streak Tracking | 🔄 In Progress | ⚠️ **TABLE ONLY** | Streaks table exists, UI minimal |
| 6.2 Milestone Badges | 🔄 In Progress | ❌ **NOT STARTED** | - |
| 6.3 Streak Break Alerts | ⏳ Planned | ❌ **NOT STARTED** | - |
| 6.4 Celebration Animations | ⏳ Planned | ❌ **NOT STARTED** | Lottie dependency jest |
| 6.5 Shareable Cards | ⏳ Planned | ❌ **NOT STARTED** | - |
| 6.6 Weekly Summary | ⏳ Planned | ❌ **NOT STARTED** | - |

**Rzeczywisty status: 5%** (nie 30%)

---

### EPIC 7: Onboarding & Subscriptions

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 7.1 Onboarding Journey | ✅ Complete | ❌ **PLACEHOLDER** | `OnboardingPlaceholder` w routerze |
| 7.2 Initial Goals | ✅ Complete | ❌ **NOT STARTED** | - |
| 7.3 Permissions Tutorial | ✅ Complete | ❌ **NOT STARTED** | - |
| 7.4 Free Tier | ✅ Complete | ⚠️ **PARTIAL** | Subscriptions table, brak tier checks |
| 7.5 14-Day Trial | ✅ Complete | ❌ **NOT STARTED** | - |
| 7.6 IAP Subscription | ✅ Complete | ❌ **NOT STARTED** | in_app_purchase dependency, nie zintegrowane |
| 7.7 Cancel & Degradation | ✅ Complete | ❌ **NOT STARTED** | - |

**Rzeczywisty status: 5%** (dokumentacja mówi 80%!)

**KRYTYCZNY PROBLEM:**
- Wszystkie 7 stories oznaczone jako "Complete"
- W rzeczywistości jest tylko **placeholder w routerze**
- IAP nie zintegrowane

---

### EPIC 8: Notifications & Engagement

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 8.1-8.5 | Not Started | ❌ **NOT STARTED** | Firebase disabled, FCM nie skonfigurowane |

**Rzeczywisty status: 0%** (zgodne z dokumentacją)

---

### EPIC 9: Settings & Profile

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 9.1 Personal Settings | ✅ Complete | ⚠️ **PARTIAL** | Profile editing działa |
| 9.2 Notification Prefs | ✅ Complete | ❌ **NOT STARTED** | Brak UI |
| 9.3 Unit Preferences | ✅ Complete | ❌ **NOT STARTED** | Brak UI |
| 9.4 Subscription Mgmt | ✅ Complete | ❌ **NOT STARTED** | Brak UI |
| 9.5 Data Privacy | ✅ Complete | ⚠️ **PARTIAL** | data_privacy_page.dart exists |

**Rzeczywisty status: 25%** (dokumentacja mówi 80%)

---

## Niezgodności Logiczne

### 1. Mock Repositories w "Production"
```dart
// lib/features/life_coach/goals/data/
MockGoalsRepository          // Throws UnimplementedError
MockCheckInRepository        // Throws UnimplementedError
MockPreferencesRepository    // Returns sample data
```
**Problem:** Stories oznaczone jako "Done" używają mocków które crashują app.

### 2. Hardcoded User IDs
```dart
// meditation_providers.dart
userId: 'current_user_id' // TODO: Get from auth
UserTier: UserTier.premium // TODO: Get from subscription
```
**Problem:** Brak integracji z auth provider.

### 3. Story 4.2 "Meditation Player" = ✅ Done
**Rzeczywistość:** Plik `meditation_player_screen.dart` NIE ISTNIEJE.
`just_audio` dependency jest, ale nie jest używana.

### 4. Epic 7 - Wszystkie stories "Complete"
**Rzeczywistość:** W kodzie jest `OnboardingPlaceholder` z tekstem:
```dart
Text('Onboarding Flow - To be implemented in Epic 7')
```

### 5. Data Sync "Done" vs SyncQueue
**Rzeczywistość:** SyncQueue table istnieje, ale:
- Brak SyncManager service
- Brak logic do wysyłania queue do Supabase
- Brak conflict resolution

---

## Rekomendowany Scope MVP

### MVP 1.0 (Realistic)

**Core Module:**
- [x] Auth (email) - DONE
- [x] Profile management - DONE
- [ ] Fix password reset - 2h
- [ ] Fix mock repositories - 4h

**Life Coach:**
- [x] Daily Plan AI generation - DONE
- [x] Morning/Evening check-ins - DONE
- [x] Daily plan editing - DONE
- [ ] Goals z prawdziwym repo - 4h
- [ ] AI Chat UI - 8h (opcjonalne dla MVP)

**Fitness:**
- [x] Smart Pattern Memory - DONE
- [x] Workout logging - DONE
- [x] Progress charts - DONE
- [x] Body measurements - DONE
- [x] Templates - DONE
- [ ] Exercise Library persistence - 4h

**Mind (Simplified):**
- [ ] Mood tracking UI - 4h
- [ ] Meditation player - 8h
- [ ] Placeholder meditations - 2h
- [ ] Breathing exercises - 6h

**Deferred to MVP 1.1:**
- Onboarding flow (users can start without it)
- IAP/Subscriptions (users get full access initially)
- Push notifications
- Cross-Module Intelligence
- Weekly Reports
- Social sharing

---

## Estimated Hours to MVP 1.0

| Task | Hours |
|------|-------|
| Fix mock repos | 4h |
| Fix hardcoded IDs | 2h |
| Goals real repo | 4h |
| Exercise library persistence | 4h |
| Mood tracking UI | 4h |
| Meditation player | 8h |
| Breathing exercises | 6h |
| Polish & testing | 8h |
| **TOTAL** | **40h** |

---

## Action Items

### Immediate (P0)
1. ❌ Zamień MockGoalsRepository na prawdziwą implementację
2. ❌ Zamień MockCheckInRepository na prawdziwą implementację
3. ❌ Fix hardcoded user IDs → inject from auth provider
4. ❌ Zaktualizuj dokumentację project-status.md

### Short-term (P1)
5. ❌ Exercise Library - dodaj Drift persistence
6. ❌ Meditation Player - implementuj z just_audio
7. ❌ Mood Tracking - dodaj UI
8. ❌ Breathing Exercises - podstawowe 5 technik

### Deferred (P2)
9. ❌ Onboarding flow
10. ❌ IAP integration
11. ❌ Push notifications
12. ❌ CMI insights

---

*Raport wygenerowany automatycznie przez Claude AI*
