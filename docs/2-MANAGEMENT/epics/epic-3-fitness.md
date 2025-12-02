# Epic 3: Fitness Coach MVP

<!-- AI-INDEX: epic-3, fitness, workout, logging, smart-pattern-memory, exercise, library, progress, templates -->

**Epic ID:** EPIC-3
**Status:** 🔄 ~82% Complete
**Priority:** P0 (MVP Critical)
**Stories:** 10

---

## Overview

| Aspect | Value |
|--------|-------|
| **Goal** | Deliver Smart Pattern Memory workout logging + exercise library + progress tracking |
| **Value** | Users save 17h/year with instant workout pre-fill, 3x retention vs competitors |
| **FRs Covered** | FR30-FR46 (Fitness module) |
| **Dependencies** | Epic 1 (auth, offline sync) |
| **Sprints** | Sprint 1 (30%), Sprint 2 (35%), Sprint 3 (25%) |

**KILLER FEATURE:** Smart Pattern Memory - pre-fills last workout in <2 seconds

---

## User Stories

| ID | Story | Points | Status | Sprint |
|----|-------|--------|--------|--------|
| 3.1 | Smart Pattern Memory Pre-fill | 8 | ✅ Done | 1 |
| 3.2 | Exercise Library (500+ exercises) | 5 | ✅ Done | 1 |
| 3.3 | Workout Logging with Rest Timer | 8 | ✅ Done | 1 |
| 3.4 | Workout History Detail View | 5 | ✅ Done | 2 |
| 3.5 | Progress Charts (1RM, Volume, PRs) | 8 | ✅ Done | 2 |
| 3.6 | Body Measurements Tracking | 5 | ✅ Done | 2 |
| 3.7 | Workout Templates (Pre-built + Custom) | 5 | 🔄 In Progress | 3 |
| 3.8 | Quick Log (Rapid Entry) | 3 | 🔄 In Progress | 3 |
| 3.9 | Exercise Instructions & Form Tips | 5 | ⏳ Planned | 3 |
| 3.10 | Cross-Module: Receive Stress from Mind | 5 | ⏳ Planned | 3 |

**Total Points:** 57 | **Completed:** 47

---

## Story Details

### Story 3.1: Smart Pattern Memory Pre-fill (KILLER FEATURE)

**As a** user logging workouts
**I want** last workout data auto-filled
**So that** I can log in <2 seconds per exercise

**Acceptance Criteria:**
1. Select exercise → Auto-fill last sets/reps/weight
2. Shows: "Last: 3×8×80kg (Nov 28)"
3. User can confirm with 1 tap
4. User can adjust if needed
5. Works offline (Drift query)
6. Query time <500ms p95
7. Falls back to empty if no history
8. Remembers last 3 workouts per exercise

**User Flow:**
```
1. Tap exercise name
2. Smart Pattern Memory shows last data
3. Tap checkmark → All sets logged
4. Total time: <2 seconds
```

---

### Story 3.2: Exercise Library

**As a** user starting workouts
**I want** to search 500+ exercises
**So that** I can find the right exercises

**Acceptance Criteria:**
1. Search by name (fuzzy matching)
2. Filter by muscle group
3. Filter by equipment
4. Filter by difficulty
5. Results <200ms after typing
6. Show primary/secondary muscles
7. Add to favorites
8. Add custom exercises
9. Synced across devices
10. Works offline (cached)

---

### Story 3.3: Workout Logging with Rest Timer

**As a** user in the gym
**I want** to log sets and use rest timer
**So that** I track my workouts accurately

**Acceptance Criteria:**
1. Log sets with reps + weight
2. Support bodyweight exercises
3. Optional: RPE, notes per set
4. Rest timer after each set
5. Configurable defaults (30s, 60s, 90s, 120s)
6. Visual + haptic notification
7. Works 100% offline
8. Sync when online

---

### Story 3.4: Workout History Detail View

**As a** user reviewing progress
**I want** to view workout history
**So that** I can see what I did before

**Acceptance Criteria:**
1. List workouts by date
2. Calendar view option
3. Tap workout → Detail view
4. Shows: exercises, sets, reps, weight, duration
5. Edit past workouts
6. Delete workouts (soft delete)
7. Search/filter by exercise

---

### Story 3.5: Progress Charts (FREE)

**As a** user tracking strength gains
**I want** to see progress charts
**So that** I can visualize improvements

**Acceptance Criteria:**
1. 1RM estimation chart (Epley formula)
2. Volume chart (sets × reps × weight)
3. PR history
4. Time filters: 30d, 90d, 6mo, 1yr, All
5. Tap data point → See details
6. Trendline (linear regression)
7. **Always FREE** (competitive advantage)
8. Export to CSV

---

### Story 3.6: Body Measurements

**As a** user tracking physique
**I want** to log body measurements
**So that** I monitor body composition

**Acceptance Criteria:**
1. Track: weight, body fat %, measurements
2. Progress photos (encrypted storage)
3. Charts over time
4. Support kg/lbs toggle
5. Unit conversion automatic
6. Synced across devices

---

### Story 3.7: Workout Templates

**As a** user with routine workouts
**I want** to use templates
**So that** I don't recreate workouts each time

**Acceptance Criteria:**
1. 20+ pre-built templates (PPL, Upper/Lower, etc.)
2. Create custom templates
3. Save workout as template
4. Start workout from template
5. Edit, duplicate, delete templates

---

## Definition of Done

- [x] Smart Pattern Memory <500ms
- [x] 500+ exercises loaded
- [x] Workout logging works offline
- [x] Progress charts render correctly
- [x] Body measurements tracking
- [ ] Templates CRUD complete
- [ ] Exercise instructions added
- [ ] Cross-module integration
- [ ] 80% test coverage

---

## Technical Architecture

```
lib/features/fitness/
├── data/
│   ├── repositories/
│   │   └── fitness_repository.dart
│   └── datasources/
│       ├── local_fitness_datasource.dart
│       └── remote_fitness_datasource.dart
├── domain/
│   ├── models/
│   │   ├── workout.dart
│   │   ├── exercise.dart
│   │   └── workout_set.dart
│   └── usecases/
│       ├── smart_pattern_memory_usecase.dart
│       └── log_workout_usecase.dart
└── presentation/
    ├── pages/
    │   ├── workout_log_page.dart
    │   ├── exercise_library_page.dart
    │   └── progress_charts_page.dart
    └── providers/
        └── fitness_providers.dart
```

---

## Database Tables

```sql
workout_sessions (id, user_id, started_at, ended_at, notes, synced)
workout_exercises (id, session_id, exercise_id, order, notes)
workout_sets (id, workout_exercise_id, set_number, reps, weight, rpe)
exercises (id, name, muscle_group, equipment, instructions)
exercise_favorites (id, user_id, exercise_id)
workout_templates (id, user_id, name, exercises_json)
body_measurements (id, user_id, date, weight, body_fat, photos_json)
```

---

## Performance Requirements

| Metric | Target |
|--------|--------|
| Smart Pattern Query | <500ms p95 |
| Exercise Search | <200ms |
| Set Logging | <100ms response |
| History Load (90d) | <1s |
| Offline | 100% functional |

---

**Source:** `docs/modules/module-fitness/epics.md` (lines 140-2580)
