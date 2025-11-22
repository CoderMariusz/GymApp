-- Migration: Add Exercise Favorites Table
-- Story: 3.2 - Exercise Library (500+ Exercises)
-- Date: 2025-11-22
-- Description: Adds exercise_favorites table for users to favorite exercises

-- ============================================================================
-- EXERCISE FAVORITES TABLE
-- ============================================================================

-- Story 3.2 AC7: Favorite exercises (star icon) → Quick access
CREATE TABLE IF NOT EXISTS exercise_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure a user can only favorite an exercise once
  UNIQUE(user_id, exercise_id)
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Index for faster lookup of user's favorite exercises
CREATE INDEX IF NOT EXISTS idx_exercise_favorites_user_id
  ON exercise_favorites(user_id);

-- Index for faster lookup of which users favorited an exercise
CREATE INDEX IF NOT EXISTS idx_exercise_favorites_exercise_id
  ON exercise_favorites(exercise_id);

-- Composite index for checking if specific exercise is favorited by user
CREATE INDEX IF NOT EXISTS idx_exercise_favorites_user_exercise
  ON exercise_favorites(user_id, exercise_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS
ALTER TABLE exercise_favorites ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own favorites
CREATE POLICY "Users can view their own favorite exercises"
  ON exercise_favorites
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can favorite exercises
CREATE POLICY "Users can favorite exercises"
  ON exercise_favorites
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can unfavorite exercises
CREATE POLICY "Users can unfavorite exercises"
  ON exercise_favorites
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Check if exercise is favorited by user
CREATE OR REPLACE FUNCTION is_exercise_favorited(
  p_user_id UUID,
  p_exercise_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM exercise_favorites
    WHERE user_id = p_user_id
      AND exercise_id = p_exercise_id
  );
END;
$$;

-- Function: Toggle favorite status
CREATE OR REPLACE FUNCTION toggle_exercise_favorite(
  p_user_id UUID,
  p_exercise_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_is_favorited BOOLEAN;
BEGIN
  -- Check if already favorited
  v_is_favorited := is_exercise_favorited(p_user_id, p_exercise_id);

  IF v_is_favorited THEN
    -- Remove favorite
    DELETE FROM exercise_favorites
    WHERE user_id = p_user_id
      AND exercise_id = p_exercise_id;
    RETURN FALSE;
  ELSE
    -- Add favorite
    INSERT INTO exercise_favorites (user_id, exercise_id)
    VALUES (p_user_id, p_exercise_id)
    ON CONFLICT (user_id, exercise_id) DO NOTHING;
    RETURN TRUE;
  END IF;
END;
$$;

-- Function: Get user's favorite exercises count
CREATE OR REPLACE FUNCTION get_user_favorites_count(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM exercise_favorites
  WHERE user_id = p_user_id;

  RETURN v_count;
END;
$$;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_exercise_favorites_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_update_exercise_favorites_updated_at
  BEFORE UPDATE ON exercise_favorites
  FOR EACH ROW
  EXECUTE FUNCTION update_exercise_favorites_updated_at();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE exercise_favorites IS 'User favorite exercises for quick access (Story 3.2 AC7)';
COMMENT ON COLUMN exercise_favorites.user_id IS 'User who favorited the exercise';
COMMENT ON COLUMN exercise_favorites.exercise_id IS 'Exercise that was favorited';
COMMENT ON FUNCTION is_exercise_favorited IS 'Check if user has favorited a specific exercise';
COMMENT ON FUNCTION toggle_exercise_favorite IS 'Toggle favorite status (add or remove)';
COMMENT ON FUNCTION get_user_favorites_count IS 'Get count of user favorite exercises';
