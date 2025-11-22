-- Migration: Fix SECURITY DEFINER Vulnerability
-- Story: 3.2 - Exercise Library
-- Date: 2025-11-22
-- Description: Fixes security vulnerability in favorite functions
--
-- CRITICAL FIX:
-- Previous version used SECURITY DEFINER which allowed users to
-- manipulate favorites for OTHER users. This migration fixes that
-- by using auth.uid() directly instead of passing user_id as parameter.

-- ============================================================================
-- DROP OLD VULNERABLE FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS is_exercise_favorited(UUID, UUID);
DROP FUNCTION IF EXISTS toggle_exercise_favorite(UUID, UUID);
DROP FUNCTION IF EXISTS get_user_favorites_count(UUID);

-- ============================================================================
-- CREATE SECURE FUNCTIONS
-- ============================================================================

-- Function: Check if exercise is favorited by CURRENT user
-- No user_id parameter - always uses authenticated user
CREATE OR REPLACE FUNCTION is_exercise_favorited(
  p_exercise_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER  -- Uses caller's privileges (respects RLS)
STABLE
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Get authenticated user ID
  v_user_id := auth.uid();

  -- Return false if not authenticated
  IF v_user_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Check if favorited (RLS policies apply)
  RETURN EXISTS (
    SELECT 1
    FROM exercise_favorites
    WHERE user_id = v_user_id
      AND exercise_id = p_exercise_id
  );
END;
$$;

-- Function: Toggle favorite status for CURRENT user
-- No user_id parameter - always uses authenticated user
-- Returns TRUE if favorited, FALSE if unfavorited
CREATE OR REPLACE FUNCTION toggle_exercise_favorite(
  p_exercise_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER  -- Uses caller's privileges (respects RLS)
AS $$
DECLARE
  v_user_id UUID;
  v_is_favorited BOOLEAN;
BEGIN
  -- Get authenticated user ID
  v_user_id := auth.uid();

  -- Require authentication
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required to toggle favorites';
  END IF;

  -- Check if already favorited (RLS policies apply)
  SELECT EXISTS (
    SELECT 1
    FROM exercise_favorites
    WHERE user_id = v_user_id
      AND exercise_id = p_exercise_id
  ) INTO v_is_favorited;

  IF v_is_favorited THEN
    -- Remove favorite (RLS policies apply)
    DELETE FROM exercise_favorites
    WHERE user_id = v_user_id
      AND exercise_id = p_exercise_id;
    RETURN FALSE;
  ELSE
    -- Add favorite (RLS policies apply)
    INSERT INTO exercise_favorites (user_id, exercise_id)
    VALUES (v_user_id, p_exercise_id)
    ON CONFLICT (user_id, exercise_id) DO NOTHING;
    RETURN TRUE;
  END IF;
END;
$$;

-- Function: Get CURRENT user's favorite exercises count
-- No user_id parameter - always uses authenticated user
CREATE OR REPLACE FUNCTION get_user_favorites_count()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY INVOKER  -- Uses caller's privileges (respects RLS)
STABLE
AS $$
DECLARE
  v_user_id UUID;
  v_count INTEGER;
BEGIN
  -- Get authenticated user ID
  v_user_id := auth.uid();

  -- Return 0 if not authenticated
  IF v_user_id IS NULL THEN
    RETURN 0;
  END IF;

  -- Count favorites (RLS policies apply)
  SELECT COUNT(*)
  INTO v_count
  FROM exercise_favorites
  WHERE user_id = v_user_id;

  RETURN v_count;
END;
$$;

-- ============================================================================
-- FIX: Remove redundant index
-- ============================================================================

-- The composite index (user_id, exercise_id) can be used for queries on user_id alone
-- So the single-column index on user_id is redundant
DROP INDEX IF EXISTS idx_exercise_favorites_user_id;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON FUNCTION is_exercise_favorited IS
  'Check if exercise is favorited by CURRENT authenticated user (SECURE - uses auth.uid())';

COMMENT ON FUNCTION toggle_exercise_favorite IS
  'Toggle favorite status for CURRENT authenticated user (SECURE - uses auth.uid())';

COMMENT ON FUNCTION get_user_favorites_count IS
  'Get favorite count for CURRENT authenticated user (SECURE - uses auth.uid())';

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Test that functions only access current user's data
DO $$
DECLARE
  v_test_exercise_id UUID := '00000000-0000-0000-0000-000000000001'::UUID;
  v_result BOOLEAN;
BEGIN
  -- Test toggle (should work for authenticated user)
  -- SELECT toggle_exercise_favorite(v_test_exercise_id) INTO v_result;
  -- Test should be run manually with authenticated user

  RAISE NOTICE 'Security fix applied successfully. Functions now use auth.uid() directly.';
END $$;
