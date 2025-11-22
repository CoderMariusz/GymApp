-- ============================================================================
-- Migration: 001_workout_templates
-- Sprint: Sprint 0 - Database Schema Completion
-- Story: S0.1 - Add workout_templates Table
-- Blocks: FR43-46 (Templates & Workout Library UX)
-- Priority: HIGH
-- ============================================================================

-- Create workout_templates table
-- Purpose: Enable users to create, save, and reuse custom workout templates
-- UX Reference: Section 14 in ux-design-specification.md (lines 1296-1435)

CREATE TABLE IF NOT EXISTS workout_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT FALSE,
  created_by TEXT DEFAULT 'user',  -- 'user' | 'system'

  -- Exercise list stored as JSONB
  -- Structure: [{ exercise_library_id: UUID, name: TEXT, sets: INT, reps: INT, rest_seconds: INT }]
  exercises JSONB NOT NULL DEFAULT '[]'::JSONB,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_workout_templates_user ON workout_templates(user_id);
CREATE INDEX idx_workout_templates_public ON workout_templates(is_public) WHERE is_public = TRUE;
CREATE INDEX idx_workout_templates_created ON workout_templates(created_at DESC);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE workout_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own templates + public templates
CREATE POLICY "Users can view own and public templates"
  ON workout_templates FOR SELECT
  USING (
    auth.uid() = user_id OR is_public = TRUE
  );

-- RLS Policy: Users can insert their own templates
CREATE POLICY "Users can create their own templates"
  ON workout_templates FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own templates
CREATE POLICY "Users can update their own templates"
  ON workout_templates FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own templates
CREATE POLICY "Users can delete their own templates"
  ON workout_templates FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Auto-update updated_at on UPDATE
CREATE OR REPLACE FUNCTION update_workout_templates_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_workout_templates_updated_at
  BEFORE UPDATE ON workout_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_workout_templates_updated_at();

-- ============================================================================
-- SEED DATA (System Templates)
-- ============================================================================

-- Insert 3 pre-built system templates for users to start with
INSERT INTO workout_templates (user_id, name, description, is_public, created_by, exercises)
VALUES
  (
    '00000000-0000-0000-0000-000000000000',  -- System user ID
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
    '00000000-0000-0000-0000-000000000000',
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
    '00000000-0000-0000-0000-000000000000',
    'Leg Day (Beginner)',
    'Classic leg workout: quads, hamstrings, glutes',
    TRUE,
    'system',
    '[
      {"exercise_library_id": null, "name": "Squats", "sets": 4, "reps": 10, "rest_seconds": 120},
      {"exercise_library_id": null, "name": "Romanian Deadlifts", "sets": 3, "reps": 10, "rest_seconds": 90},
      {"exercise_library_id": null, "name": "Leg Press", "sets": 3, "reps": 12, "rest_seconds": 90}
    ]'::JSONB
  );

-- ============================================================================
-- VALIDATION QUERIES (Run these after applying migration)
-- ============================================================================

-- Expected: 3 system templates
-- SELECT COUNT(*) FROM workout_templates WHERE created_by = 'system';

-- Expected: All templates are public
-- SELECT * FROM workout_templates WHERE is_public = TRUE;

-- Expected: RLS policies exist
-- SELECT * FROM pg_policies WHERE tablename = 'workout_templates';
