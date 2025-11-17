# Story 3.7: Workout Templates (Pre-built + Custom)

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P1 | **Status:** ready-for-dev | **Effort:** 3 SP

---

## User Story
**As a** user following a training program
**I want** to use pre-built or custom templates
**So that** I don't plan every workout from scratch

---

## Acceptance Criteria
1. ✅ Templates screen (Fitness tab → "Templates")
2. ✅ 20+ pre-built templates: Push/Pull/Legs, Upper/Lower, Full Body
3. ✅ Template shows: Name, exercises, sets/reps scheme
4. ✅ Start workout from template (exercises pre-loaded)
5. ✅ Create custom templates (name + exercise list)
6. ✅ Edit custom templates
7. ✅ Delete custom templates
8. ✅ Favorite templates (star icon) → Quick access

**FRs:** FR43, FR44

---

## Technical Implementation

### Database Schema
```sql
-- Global templates (read-only, seeded)
CREATE TABLE workout_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Template exercises (junction table)
CREATE TABLE template_exercises (
  template_id UUID NOT NULL REFERENCES workout_templates(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id),
  order_index INT NOT NULL,
  sets INT NOT NULL,
  reps TEXT, -- "8-12" or "10"
  PRIMARY KEY (template_id, exercise_id)
);

-- User custom templates
CREATE TABLE user_workout_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Seed Templates
```sql
INSERT INTO workout_templates (name, description) VALUES
  ('Push Day', '5 exercises: Bench, Overhead Press, Incline DB Press, Lateral Raises, Tricep Extensions'),
  ('Pull Day', '5 exercises: Deadlift, Pull-ups, Rows, Face Pulls, Bicep Curls'),
  ('Leg Day', '5 exercises: Squat, RDL, Lunges, Leg Curls, Calf Raises'),
  -- ... 17 more templates
;
```

---

## Dependencies
**Prerequisites:** Story 3.2 (Exercise Library)

**Coverage Target:** 80%+

---

## Dev Agent Record

### Context Reference

- **Story Context File:** [3-7-workout-templates-pre-built-custom.context.xml](./3-7-workout-templates-pre-built-custom.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
