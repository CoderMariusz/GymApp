# Sprint 3 Summary - Fitness Coach MVP

**Sprint:** 3
**Epic:** Epic 3 - Fitness Coach MVP
**Status:** 🔄 In Progress (65%) - Updated 2025-11-23
**Sprint Duration:** 2-3 weeks
**Team Velocity:** 27 SP (18 SP completed)

---

## Sprint Goal

**"Deliver core Fitness Coach module with Smart Pattern Memory (killer feature), workout logging, progress tracking, and templates."**

By the end of Sprint 3, users should be able to:
- ✅ Log workouts in <2 seconds per set (Smart Pattern Memory pre-fill)
- ✅ Search 500+ exercises
- ✅ Log workouts with automatic rest timer
- ✅ View workout history and details
- ✅ See progress charts (strength, volume, PRs)
- ✅ Track body measurements (weight, body fat %, etc.)
- ✅ Use pre-built or custom workout templates
- ✅ Quick log entire workout in <30 seconds
- ✅ View exercise instructions and form tips
- ✅ Receive cross-module insights (high stress → adjust workout)

---

## Sprint Backlog

| Story ID | Title | Priority | Effort (SP) | Status |
|----------|-------|----------|-------------|--------|
| 3.1 | Smart Pattern Memory - Pre-fill Last Workout | P0 | 5 | ✅ completed |
| 3.2 | Exercise Library (500+ Exercises) | P0 | 3 | ✅ completed |
| 3.3 | Workout Logging with Rest Timer | P0 | 3 | ✅ completed |
| 3.4 | Workout History & Detail View | P0 | 2 | 🔄 partial |
| 3.5 | Progress Charts (Strength, Volume, PRs) | P1 | 3 | ✅ completed |
| 3.6 | Body Measurements Tracking | P1 | 2 | ✅ completed |
| 3.7 | Workout Templates (Pre-built + Custom) | P1 | 3 | ✅ completed |
| 3.8 | Quick Log (Rapid Workout Entry) | P1 | 2 | ✅ completed |
| 3.9 | Exercise Instructions & Form Tips | P2 | 2 | 🔄 partial |
| 3.10 | Cross-Module: Receive Stress Data from Mind | P1 | 2 | ⏸️ not started |
| **TOTAL** | **10 stories** | - | **27 SP** | **~65% complete** |

---

## Story Dependencies

```
3.2 (Exercise Library)
 ├─→ 3.1 (Smart Pattern - needs exercises)
 │    ├─→ 3.3 (Workout Logging - uses Smart Pattern)
 │    └─→ 3.8 (Quick Log - uses Smart Pattern)
 ├─→ 3.7 (Templates - needs exercises)
 └─→ 3.9 (Instructions - exercise details)

3.3 (Workout Logging)
 ├─→ 3.4 (History - displays logged workouts)
 │    └─→ 3.5 (Progress Charts - uses workout data)
 └─→ 3.6 (Body Measurements - parallel, independent)

Epic 4 (Mind module)
 └─→ 3.10 (Cross-Module - receives stress data)
```

**Recommended Order:**
1. Story 3.2 (Exercise Library) - **Foundation (seed 500+ exercises)**
2. Story 3.1 (Smart Pattern Memory) - **Killer Feature! Depends on 3.2**
3. Story 3.3 (Workout Logging) - **Uses 3.1 + 3.2**
4. Story 3.4 (Workout History) - **Requires 3.3**
5. Story 3.5 (Progress Charts) - **Requires 3.3, 3.4**
6. Story 3.6 (Body Measurements) - **Parallel, independent**
7. Story 3.7 (Workout Templates) - **Requires 3.2**
8. Story 3.8 (Quick Log) - **Requires 3.1**
9. Story 3.9 (Exercise Instructions) - **Enhancement, requires 3.2**
10. Story 3.10 (Cross-Module) - **Requires Epic 4 (Mind module)**

---

## Technical Highlights

### Killer Feature: Smart Pattern Memory (Story 3.1)
**Goal:** Log workouts in <2 seconds per set

**How it works:**
1. User taps exercise → App queries last workout for this exercise
2. Pre-fills: Sets, reps, weight from last session
3. User adjusts weight with swipe gesture (up = +5kg, down = -5kg)
4. Tap checkmark → Set logged
5. **Total time: <2 seconds** (vs 15-30s traditional logging)

**Technical:**
```dart
Future<List<WorkoutSet>> getLastWorkout(String exerciseId) async {
  return await db.query(
    'workout_sets',
    where: 'exercise_id = ? AND user_id = ?',
    orderBy: 'created_at DESC',
    limit: 10, // Last session
  );
}
```

### Exercise Library (Story 3.2)
- **500+ exercises** seeded on first launch
- Categories: Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other
- Real-time search (<200ms response)
- Custom exercises + Favorites

### Database Schema (Sprint 3)
```sql
-- Exercises (global, seeded)
CREATE TABLE exercises (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  muscle_groups TEXT[], -- ['chest', 'triceps']
  instructions TEXT,
  form_tips TEXT[],
  mistakes TEXT[]
);

-- Workouts
CREATE TABLE workouts (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  duration INT, -- seconds
  notes TEXT
);

-- Workout Sets
CREATE TABLE workout_sets (
  id UUID PRIMARY KEY,
  workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_id UUID REFERENCES exercises(id),
  set_number INT,
  reps INT,
  weight DECIMAL(5, 2), -- 999.99 kg
  notes TEXT
);

-- Body Measurements
CREATE TABLE body_measurements (
  id UUID PRIMARY KEY,
  user_id UUID,
  date DATE UNIQUE,
  weight DECIMAL(5, 2),
  body_fat_pct DECIMAL(4, 2),
  chest DECIMAL(5, 2),
  waist DECIMAL(5, 2),
  hips DECIMAL(5, 2),
  unit TEXT CHECK (unit IN ('metric', 'imperial'))
);

-- Personal Records (Materialized View)
CREATE MATERIALIZED VIEW personal_records AS
SELECT
  user_id,
  exercise_id,
  MAX(weight) as max_weight,
  MAX(created_at) as achieved_at
FROM workout_sets
GROUP BY user_id, exercise_id;

-- Workout Templates
CREATE TABLE workout_templates (
  id UUID PRIMARY KEY,
  name TEXT,
  description TEXT
);

CREATE TABLE template_exercises (
  template_id UUID REFERENCES workout_templates(id),
  exercise_id UUID REFERENCES exercises(id),
  order_index INT,
  sets INT,
  reps TEXT -- "8-12" or "10"
);

-- User Custom Templates
CREATE TABLE user_workout_templates (
  id UUID PRIMARY KEY,
  user_id UUID,
  name TEXT
);
```

---

## Non-Functional Requirements

- [ ] **NFR-P7:** Smart Pattern Memory: Set logged in <2s
- [ ] **NFR-P8:** Exercise search: Results in <200ms
- [ ] **NFR-P9:** Workout sync: <5s latency across devices
- [ ] **NFR-S8:** Offline-first: All logging works without internet
- [ ] **NFR-UX2:** Haptic feedback on set completion
- [ ] **NFR-UX3:** Confetti animation on PR achievement

---

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Story 3.1 (Smart Pattern) performance issues with large datasets | Low | High | Index workout_sets(user_id, exercise_id, created_at DESC), limit queries to 10 sets |
| 500+ exercise seed data size (Story 3.2) | Low | Low | Compress seed data, lazy load instructions |
| Story 3.5 (Charts) performance with 1000+ workouts | Medium | Medium | Use materialized views, aggregate weekly instead of daily |
| Story 3.10 (Cross-Module) depends on Epic 4 (Mind module) | High | Medium | Implement after Epic 4, or stub stress API for testing |

---

## Testing Strategy

### Critical Scenarios
1. **Smart Pattern Memory:** Log exercise → Pre-fill last workout → Adjust weight → Save (<2s)
2. **Exercise Search:** Search "bench" → 5+ results in <200ms
3. **Workout Logging:** Start workout → Log 3 exercises × 3 sets → Rest timer → Finish
4. **PR Detection:** Log set with weight > previous max → Confetti animation → PR saved
5. **Offline Sync:** Log workout offline → App goes online → Workout synced to Supabase
6. **Cross-Module:** High stress (≥4) → Insight card shown → Load light template

**Coverage Target:** 85%+ unit (Smart Pattern critical!), 75%+ widget, 100% critical flows

---

## Definition of Done

- [ ] All 10 stories implemented
- [ ] Smart Pattern Memory <2s per set
- [ ] 500+ exercises seeded
- [ ] Offline-first logging working
- [ ] PR detection and celebration
- [ ] Cross-module stress query working (after Epic 4)
- [ ] All tests passing (85%+ coverage)
- [ ] Code reviewed and merged to develop

---

## Next Sprint

**Sprint 4: Mind & Emotion MVP (Epic 4)**
- Guided meditation library (20-30 MVP)
- Mood & stress tracking (always FREE)
- CBT chat with AI
- Private journaling (E2E encrypted)
- Mental health screening (GAD-7, PHQ-9)

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
