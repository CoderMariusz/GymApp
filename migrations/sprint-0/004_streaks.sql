-- ============================================================================
-- Migration: 004_streaks
-- Sprint: Sprint 0 - Database Schema Completion
-- Story: S0.4 - Add streaks Table
-- Blocks: FR85-90 (Gamification UX)
-- Priority: MEDIUM
-- ============================================================================

-- Create streaks table
-- Purpose: Track daily streaks for workout, meditation, and check-in activities
-- UX Reference: Section 9 in ux-design-specification.md (Gamification)

CREATE TABLE IF NOT EXISTS streaks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,

  -- Streak type
  -- 'workout' = Completed workout
  -- 'meditation' = Completed meditation
  -- 'check_in' = Completed daily check-in (mood + energy)
  streak_type TEXT NOT NULL CHECK (streak_type IN ('workout', 'meditation', 'check_in')),

  -- Streak counters
  current_streak INTEGER NOT NULL DEFAULT 0 CHECK (current_streak >= 0),
  longest_streak INTEGER NOT NULL DEFAULT 0 CHECK (longest_streak >= 0),

  -- Tracking
  last_completed_date DATE,
  freeze_used BOOLEAN DEFAULT FALSE,  -- One-time streak saver (prevents streak break)

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Ensure only one streak record per user per type
  UNIQUE(user_id, streak_type)
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_streaks_user ON streaks(user_id);
CREATE INDEX idx_streaks_user_type ON streaks(user_id, streak_type);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE streaks ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage their own streaks
CREATE POLICY "Users can manage their own streaks"
  ON streaks FOR ALL
  USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Auto-update updated_at on UPDATE
CREATE OR REPLACE FUNCTION update_streaks_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_streaks_updated_at
  BEFORE UPDATE ON streaks
  FOR EACH ROW
  EXECUTE FUNCTION update_streaks_updated_at();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE streaks IS 'Tracks daily streaks for workout, meditation, and check-in activities';
COMMENT ON COLUMN streaks.streak_type IS 'Type of streak: workout, meditation, check_in';
COMMENT ON COLUMN streaks.current_streak IS 'Current consecutive days streak (resets to 0 if broken)';
COMMENT ON COLUMN streaks.longest_streak IS 'Longest streak ever achieved (never resets)';
COMMENT ON COLUMN streaks.last_completed_date IS 'Last date the activity was completed (used to detect streak breaks)';
COMMENT ON COLUMN streaks.freeze_used IS 'TRUE if user used one-time streak freeze (prevents one streak break)';

-- ============================================================================
-- VALIDATION QUERIES (Run these after applying migration)
-- ============================================================================

-- Expected: Table exists with check constraints
-- SELECT column_name, data_type FROM information_schema.columns
-- WHERE table_name = 'streaks';

-- Expected: UNIQUE constraint on (user_id, streak_type)
-- SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint
-- WHERE conrelid = 'streaks'::regclass AND contype = 'u';

-- Expected: RLS policies exist
-- SELECT * FROM pg_policies WHERE tablename = 'streaks';

-- ============================================================================
-- NOTES FOR DEVELOPERS
-- ============================================================================

-- STREAK LOGIC:
-- 1. When user completes activity today:
--    - If last_completed_date = yesterday → increment current_streak
--    - If last_completed_date = today → do nothing (already counted)
--    - If last_completed_date < yesterday → reset to 1 (streak broken)
-- 2. Update longest_streak if current_streak > longest_streak
-- 3. Update last_completed_date to today

-- STREAK FREEZE FEATURE (FR88):
-- - User can activate "freeze" once per streak type
-- - Prevents streak break for 1 missed day
-- - freeze_used flag prevents multiple uses
-- - Example: 7-day streak → miss day → freeze activates → streak remains 7

-- EXAMPLE USAGE:
-- User completes workout on Monday, Tuesday, Wednesday (3-day streak)
-- Misses Thursday → streak breaks → current_streak = 0
-- Completes Friday → current_streak = 1 (new streak starts)

-- STREAK NOTIFICATION:
-- - Show streak count in HomeScreen (FR85)
-- - Celebrate milestones: 7 days, 30 days, 100 days
-- - Send push notification if streak at risk (missed yesterday)

-- INITIALIZATION:
-- When user completes activity for first time, create streak record:
-- INSERT INTO streaks (user_id, streak_type, current_streak, last_completed_date)
-- VALUES (user_id, 'workout', 1, CURRENT_DATE)
-- ON CONFLICT (user_id, streak_type) DO UPDATE ...
