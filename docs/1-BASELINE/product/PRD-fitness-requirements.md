# Fitness Module - Product Requirements

<!-- AI-INDEX: fitness, requirements, workout-logging, smart-pattern-memory, progress-tracking, templates, exercise-library -->

**Moduł:** Fitness Coach
**Cena:** 2.99 EUR/month
**Status:** ~82% zaimplementowane

---

## Spis Treści

1. [Module Overview](#1-module-overview)
2. [Functional Requirements](#2-functional-requirements)
3. [User Flows](#3-user-flows)
4. [Cross-Module Integration](#4-cross-module-integration)
5. [Technical Notes](#5-technical-notes)

---

## 1. Module Overview

### Core Value Proposition

**Smart Pattern Memory** - first fitness tracker saving users **17 hours/year** through intelligent workout pre-fill, achieving **3x industry retention**.

### Key Features

| Feature | Priority | Value |
|---------|----------|-------|
| **Smart Pattern Memory** | P0 (MVP) | Killer feature - pre-fills last workout |
| Workout Logging | P0 (MVP) | Fast UX, <2s per set |
| Exercise Library | P0 (MVP) | 500+ exercises |
| Progress Charts | P0 (MVP) | FREE for all users |
| Workout Templates | P0 (MVP) | 20+ pre-built |
| Body Measurements | P0 (MVP) | Weight, body fat, photos |
| Form Videos | P1 | Exercise instructions |
| Cross-Module Intel | P0 (MVP) | Stress data from Mind |

### Competitive Advantage

| Feature | GymApp | Strong | FitBod |
|---------|--------|--------|--------|
| Progress Charts | FREE | Paid | Paid |
| Smart Pre-fill | Yes | Limited | Yes |
| Price | 2.99 EUR | 9.99 EUR | 12.99 EUR |

---

## 2. Functional Requirements

### 2.1 Workout Logging (FR30-FR37)

**FR30: Log Workouts with Sets, Reps, Weight**
- User can log exercise sets with:
  - Reps (1-999)
  - Weight (0-999 kg/lbs)
  - Optional: RPE (1-10), notes
- Supports bodyweight exercises (weight = 0)
- Supports supersets and circuits

**FR31: Smart Pattern Memory (KILLER FEATURE)**
- System automatically pre-fills last workout data when user selects exercise:
  - Last sets count
  - Last reps per set
  - Last weight per set
  - Date of last performance
- User can accept or modify in <2 seconds
- Works offline (Drift/SQLite)

**FR32: Exercise Library Search**
- User can search 500+ exercises by:
  - Name (fuzzy search)
  - Muscle group (primary, secondary)
  - Equipment type
  - Difficulty level
- Results appear <200ms after typing stops

**FR33: Custom Exercises**
- User can add custom exercises with:
  - Name (required)
  - Muscle group (required)
  - Equipment (optional)
  - Instructions (optional)
- Custom exercises synced across devices

**FR34: Workout Duration & Rest**
- System tracks total workout duration automatically
- Rest timer between sets:
  - Configurable defaults (30s, 60s, 90s, 120s)
  - Auto-start after completing set
  - Visual + haptic notification

**FR35: Workout Notes**
- User can add notes to:
  - Individual sets
  - Workout sessions
- Notes searchable in history

**FR36: Offline Logging**
- ALL workout logging works 100% offline
- Sync when internet available
- No data loss guarantee

**FR37: Edit/Delete Workouts**
- User can edit past workouts:
  - Change sets, reps, weight
  - Add/remove exercises
  - Change date
- User can delete workouts (soft delete, recoverable 30 days)

### 2.2 Progress Tracking (FR38-FR42)

**FR38: Progress Charts (FREE)**
- User can view:
  - Weight lifted over time (1RM estimation)
  - Volume per exercise (sets × reps × weight)
  - Personal Records (PRs)
- Time filters: 30d, 90d, 6mo, 1yr, All Time
- **Always FREE - competitive advantage**

**FR39: Body Measurements**
- User can track:
  - Body weight (kg/lbs)
  - Body fat % (optional)
  - Measurements: chest, waist, arms, legs
  - Progress photos (encrypted storage)
- Charts for all measurements

**FR40: Workout History**
- User can view history by:
  - Date (calendar view)
  - Exercise (all sessions for specific exercise)
- Details: duration, volume, exercises, notes

**FR41: Personal Records (PRs)**
- System automatically calculates PRs:
  - 1RM (Epley formula: weight × (1 + reps/30))
  - Max weight for any rep range
  - Volume PRs
- PR badges and celebrations

**FR42: Data Export**
- Export workout data to CSV:
  - Date, exercise, sets, reps, weight, duration
  - Compatible with Excel, Google Sheets
- GDPR compliance

### 2.3 Templates & Library (FR43-FR46)

**FR43: Pre-built Templates (20+)**
- Push/Pull/Legs
- Upper/Lower Split
- Full Body
- Strength Focus
- Hypertrophy Focus
- Beginner programs
- Advanced programs

**FR44: Custom Templates**
- User can create templates from:
  - Current workout (save as template)
  - Scratch (add exercises)
- Edit, duplicate, delete templates

**FR45: Favorite Exercises**
- User can mark exercises as favorites
- Quick access from workout screen
- Synced across devices

**FR46: Exercise Instructions (P1)**
- Text instructions for form
- Visual diagrams
- Video tutorials (P2)
- Form tips and common mistakes

---

## 3. User Flows

### 3.1 Start Workout Flow

```
1. User taps "Start Workout"
2. Options:
   a. Empty workout → Add exercises
   b. From template → Select template
   c. Continue last → Resume previous workout pattern
3. Timer starts
4. User adds exercises from library
5. Smart Pattern Memory pre-fills last data
6. User logs sets (tap to confirm or adjust)
7. Rest timer auto-starts
8. User completes workout
9. Summary screen with PRs highlighted
10. Data synced (or queued for offline)
```

### 3.2 Quick Log Flow (2-Second Goal)

```
1. User taps exercise name
2. Smart Pattern Memory shows: "Last: 3×8×80kg (Nov 28)"
3. User taps checkmark → All 3 sets logged with same data
4. OR User adjusts one value → Tap checkmark
5. Total time: <2 seconds per exercise
```

### 3.3 View Progress Flow

```
1. User navigates to Progress tab
2. Selects exercise (e.g., Bench Press)
3. Views:
   - 1RM chart over time
   - Volume chart
   - PR history
4. Filters: Last 30d / 90d / 6mo / Year / All
5. Optional: Export to CSV
```

---

## 4. Cross-Module Integration

### 4.1 Receives from Mind Module

| Data | Usage |
|------|-------|
| Stress Level (1-5) | Adjust workout intensity suggestions |
| Sleep Quality (1-5) | Suggest rest day or lighter workout |
| Mood | Adapt motivation messaging |

### 4.2 Sends to Life Coach

| Data | Usage |
|------|-------|
| Workout Completed | Update daily plan status |
| Volume/Duration | Feed Cross-Module Intelligence |
| PRs Achieved | Celebrate in weekly summary |

### 4.3 Cross-Module Insights (FR77-FR84)

| Trigger | Insight |
|---------|---------|
| High stress + heavy workout planned | "Consider light session today" |
| Poor sleep + morning workout | "Suggest afternoon instead" |
| High volume week + elevated stress | "Recovery day recommended" |

---

## 5. Technical Notes

### Database Tables

```sql
-- Drift (SQLite) tables for offline-first
workout_sessions (id, user_id, started_at, ended_at, notes, synced)
workout_exercises (id, session_id, exercise_id, order, notes)
workout_sets (id, workout_exercise_id, set_number, reps, weight, rpe, completed)
exercises (id, name, muscle_group, equipment, instructions, is_custom)
exercise_favorites (id, user_id, exercise_id)
workout_templates (id, user_id, name, exercises_json, is_preset)
body_measurements (id, user_id, date, weight, body_fat, photos_json)
```

### Smart Pattern Memory Query

```sql
-- Get last workout data for exercise
SELECT wset.reps, wset.weight, wset.set_number, ws.started_at
FROM workout_sets wset
JOIN workout_exercises we ON wset.workout_exercise_id = we.id
JOIN workout_sessions ws ON we.session_id = ws.id
WHERE we.exercise_id = ? AND ws.user_id = ?
ORDER BY ws.started_at DESC
LIMIT 10
```

### 1RM Calculation (Epley Formula)

```dart
double calculate1RM(double weight, int reps) {
  if (reps == 1) return weight;
  return weight * (1 + reps / 30.0);
}
```

### Performance Requirements

| Metric | Target |
|--------|--------|
| Smart Pattern Query | <500ms p95 |
| Exercise Search | <200ms after typing |
| Set Logging | <100ms response |
| History Load (90 days) | <1s |

---

## Powiązane Dokumenty

- [PRD-overview.md](./PRD-overview.md) - Przegląd produktu
- [ARCH-overview.md](../architecture/ARCH-overview.md) - Architektura
- [epic-3-fitness.md](../../2-MANAGEMENT/epics/epic-3-fitness.md) - Fitness epic stories
- [fitness-module.md](../../3-ARCHITECTURE/system-design/fitness-module.md) - Technical design

---

*FR30-FR46 | 17 Functional Requirements | ~82% implemented*
