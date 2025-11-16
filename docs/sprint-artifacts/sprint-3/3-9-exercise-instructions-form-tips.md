# Story 3.9: Exercise Instructions & Form Tips

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P2 | **Status:** drafted | **Effort:** 2 SP

---

## User Story
**As a** beginner lifter
**I want** to see exercise instructions
**So that** I can perform exercises with proper form

---

## Acceptance Criteria
1. ✅ Exercise detail screen (tap exercise in library)
2. ✅ Instructions: Text description (300-500 words)
3. ✅ Muscle groups highlighted (visual diagram, P1)
4. ✅ Form tips: Bullet points (3-5 key tips)
5. ✅ Common mistakes to avoid (bullet points)
6. ✅ Video tutorial link (P1: embedded video player)
7. ✅ "Start Workout with This Exercise" CTA

**FRs:** FR46 (P1 feature, basic MVP)

---

## Technical Implementation

### Database Schema
```sql
ALTER TABLE exercises ADD COLUMN instructions TEXT;
ALTER TABLE exercises ADD COLUMN form_tips TEXT[];
ALTER TABLE exercises ADD COLUMN mistakes TEXT[];
ALTER TABLE exercises ADD COLUMN video_url TEXT;
```

### Seed Instructions
```sql
UPDATE exercises
SET
  instructions = 'Lie on bench with feet flat on floor. Grip bar slightly wider than shoulders. Lower bar to mid-chest. Press up explosively.',
  form_tips = ARRAY[
    'Keep shoulder blades retracted',
    'Feet flat on floor for stability',
    'Lower bar to mid-chest, not neck'
  ],
  mistakes = ARRAY[
    'Bouncing bar off chest',
    'Flaring elbows too wide',
    'Lifting butt off bench'
  ]
WHERE name = 'Bench Press';
```

---

## Dependencies
**Prerequisites:** Story 3.2 (Exercise Library)

**Coverage Target:** 75%+

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
