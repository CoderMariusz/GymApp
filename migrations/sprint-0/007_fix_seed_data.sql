-- ============================================================================
-- Migration: 007_fix_seed_data
-- Purpose: Fix system workout templates seed data
-- Issue: Original INSERT used non-existent user_id '00000000-0000-0000-0000-000000000000'
-- Solution: Make user_id nullable for system templates and update RLS policy
-- ============================================================================

-- Step 1: Alter workout_templates to allow NULL user_id for system templates
ALTER TABLE workout_templates
ALTER COLUMN user_id DROP NOT NULL;

-- Step 2: Update RLS policy to handle NULL user_id for system templates
DROP POLICY IF EXISTS "Users can view own and public templates" ON workout_templates;

CREATE POLICY "Users can view own and public templates"
  ON workout_templates FOR SELECT
  USING (
    auth.uid() = user_id
    OR is_public = TRUE
    OR (user_id IS NULL AND created_by = 'system')
  );

-- Step 3: Delete any failed inserts (if any exist with invalid user_id)
DELETE FROM workout_templates WHERE created_by = 'system';

-- Step 4: Insert system templates with NULL user_id
INSERT INTO workout_templates (user_id, name, description, is_public, created_by, exercises)
VALUES
  (
    NULL,  -- System templates have no user
    'Push Day (Beginner)',
    'Classic push workout: chest, shoulders, triceps',
    TRUE,
    'system',
    '[
      {"exercise_library_id": null, "name": "Bench Press", "sets": 3, "reps": 10, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Shoulder Press", "sets": 3, "reps": 10, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Tricep Dips", "sets": 3, "reps": 12, "rest_seconds": 60}
    ]'::JSONB
  ),
  (
    NULL,
    'Pull Day (Beginner)',
    'Classic pull workout: back, biceps',
    TRUE,
    'system',
    '[
      {"exercise_library_id": null, "name": "Pull-ups", "sets": 3, "reps": 8, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Barbell Rows", "sets": 3, "reps": 10, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Bicep Curls", "sets": 3, "reps": 12, "rest_seconds": 60}
    ]'::JSONB
  ),
  (
    NULL,
    'Leg Day (Beginner)',
    'Classic leg workout: quads, hamstrings, glutes',
    TRUE,
    'system',
    '[
      {"exercise_library_id": null, "name": "Squats", "sets": 4, "reps": 10, "rest_seconds": 120},
      {"exercise_library_id": null, "name": "Romanian Deadlifts", "sets": 3, "reps": 10, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Leg Press", "sets": 3, "reps": 12, "rest_seconds": 90}
    ]'::JSONB
  ),
  (
    NULL,
    'Full Body (Beginner)',
    'Complete full body workout for beginners',
    TRUE,
    'system',
    '[
      {"exercise_library_id": null, "name": "Squats", "sets": 3, "reps": 10, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Bench Press", "sets": 3, "reps": 10, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Barbell Rows", "sets": 3, "reps": 10, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Shoulder Press", "sets": 3, "reps": 10, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Plank", "sets": 3, "reps": 30, "rest_seconds": 60}
    ]'::JSONB
  ),
  (
    NULL,
    'HIIT Cardio (Intermediate)',
    'High-intensity interval training for cardio',
    TRUE,
    'system',
    '[
      {"exercise_library_id": null, "name": "Burpees", "sets": 4, "reps": 10, "rest_seconds": 30},
      {"exercise_library_id": null, "name": "Mountain Climbers", "sets": 4, "reps": 20, "rest_seconds": 30},
      {"exercise_library_id": null, "name": "Jump Squats", "sets": 4, "reps": 15, "rest_seconds": 30},
      {"exercise_library_id": null, "name": "High Knees", "sets": 4, "reps": 30, "rest_seconds": 30}
    ]'::JSONB
  );

-- ============================================================================
-- VALIDATION QUERIES
-- ============================================================================

-- Check system templates count (Expected: 5)
-- SELECT COUNT(*) FROM workout_templates WHERE created_by = 'system';

-- Check templates are public and accessible
-- SELECT name, description, is_public, created_by FROM workout_templates WHERE created_by = 'system';

-- Verify RLS policy works for anonymous access
-- SELECT name FROM workout_templates WHERE is_public = TRUE;

-- ============================================================================
-- NOTES
-- ============================================================================
--
-- This migration:
-- 1. Makes user_id nullable (system templates don't belong to any user)
-- 2. Updates RLS to allow viewing system templates
-- 3. Inserts 5 system templates (Push, Pull, Leg, Full Body, HIIT)
--
-- Run this in Supabase Dashboard → SQL Editor
-- Or via: psql -f migrations/sprint-0/007_fix_seed_data.sql
--
