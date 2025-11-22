-- ============================================================================
-- Migration: 006_mood_logs
-- Sprint: Sprint 0 - Database Schema Completion
-- Story: S0.6 - Add mood_logs Table
-- Blocks: FR55-60 (Mood & Stress Tracking)
-- Priority: MEDIUM
-- ============================================================================

-- Create mood_logs table
-- Purpose: Granular mood tracking (multiple logs per day)
-- UX Reference: Section 6 in ux-design-specification.md (Mood & Stress Tracking)

CREATE TABLE IF NOT EXISTS mood_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,

  -- Mood tracking (1-5 scale)
  mood_score INTEGER NOT NULL CHECK (mood_score BETWEEN 1 AND 5),
  energy_score INTEGER CHECK (energy_score BETWEEN 1 AND 5),
  stress_level INTEGER CHECK (stress_level BETWEEN 1 AND 5),

  -- Optional journal entry
  notes TEXT,

  logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_mood_logs_user ON mood_logs(user_id);
CREATE INDEX idx_mood_logs_user_date ON mood_logs(user_id, logged_at DESC);
CREATE INDEX idx_mood_logs_logged_at ON mood_logs(logged_at DESC);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE mood_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage their own mood logs
CREATE POLICY "Users can manage their own mood logs"
  ON mood_logs FOR ALL
  USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update user_daily_metrics when mood_log inserted
-- Purpose: Keep daily metrics table in sync for analytics and CMI
CREATE OR REPLACE FUNCTION update_daily_metrics_on_mood_log()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_daily_metrics (user_id, date, mood_score, stress_level)
  VALUES (NEW.user_id, NEW.logged_at::DATE, NEW.mood_score, NEW.stress_level)
  ON CONFLICT (user_id, date) DO UPDATE
  SET mood_score = EXCLUDED.mood_score,
      stress_level = EXCLUDED.stress_level,
      aggregated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_daily_metrics_on_mood_log
  AFTER INSERT ON mood_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_daily_metrics_on_mood_log();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE mood_logs IS 'Granular mood tracking (multiple logs per day) with optional journal notes';
COMMENT ON COLUMN mood_logs.mood_score IS 'Mood rating 1-5: 1=Very Bad, 2=Bad, 3=Neutral, 4=Good, 5=Great';
COMMENT ON COLUMN mood_logs.energy_score IS 'Energy rating 1-5: 1=Exhausted, 2=Tired, 3=Okay, 4=Energized, 5=Pumped';
COMMENT ON COLUMN mood_logs.stress_level IS 'Stress rating 1-5: 1=Calm, 2=Relaxed, 3=Moderate, 4=Stressed, 5=Overwhelmed';
COMMENT ON COLUMN mood_logs.notes IS 'Optional journal entry for mood context';
COMMENT ON COLUMN mood_logs.logged_at IS 'When the mood was logged (defaults to NOW())';

-- ============================================================================
-- VALIDATION QUERIES (Run these after applying migration)
-- ============================================================================

-- Expected: Table exists with check constraints
-- SELECT column_name, data_type FROM information_schema.columns
-- WHERE table_name = 'mood_logs';

-- Expected: Check constraints on scores (1-5 range)
-- SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint
-- WHERE conrelid = 'mood_logs'::regclass AND contype = 'c';

-- Expected: RLS policies exist
-- SELECT * FROM pg_policies WHERE tablename = 'mood_logs';

-- Expected: Trigger exists
-- SELECT tgname FROM pg_trigger WHERE tgrelid = 'mood_logs'::regclass;

-- ============================================================================
-- NOTES FOR DEVELOPERS
-- ============================================================================

-- MOOD SCALE (1-5):
-- 1 = Very Bad (😢)
-- 2 = Bad (😕)
-- 3 = Neutral (😐)
-- 4 = Good (🙂)
-- 5 = Great (😄)

-- ENERGY SCALE (1-5):
-- 1 = Exhausted (🔋 0%)
-- 2 = Tired (🔋 25%)
-- 3 = Okay (🔋 50%)
-- 4 = Energized (🔋 75%)
-- 5 = Pumped (🔋 100%)

-- STRESS SCALE (1-5):
-- 1 = Calm (💚)
-- 2 = Relaxed (💛)
-- 3 = Moderate (🧡)
-- 4 = Stressed (❤️)
-- 5 = Overwhelmed (💔)

-- USAGE PATTERNS:
-- 1. Quick Check-in: User logs mood_score + energy_score (no notes)
-- 2. Journal Entry: User logs mood + detailed notes explaining why
-- 3. Multiple Logs: User can log multiple times per day (morning/afternoon/evening)

-- TRIGGER BEHAVIOR:
-- When mood_log inserted → auto-update user_daily_metrics table
-- This enables:
-- - CMI pattern detection (correlate mood with workouts/sleep)
-- - Daily trend visualization
-- - Weekly/monthly aggregations

-- ANALYTICS QUERIES:
-- Average mood last 7 days:
-- SELECT AVG(mood_score) FROM mood_logs
-- WHERE user_id = ? AND logged_at >= NOW() - INTERVAL '7 days';

-- Mood trend (daily averages):
-- SELECT logged_at::DATE, AVG(mood_score), AVG(energy_score), AVG(stress_level)
-- FROM mood_logs
-- WHERE user_id = ?
-- GROUP BY logged_at::DATE
-- ORDER BY logged_at::DATE DESC
-- LIMIT 30;

-- PRIVACY:
-- - Notes field may contain sensitive information
-- - Consider E2EE for notes in future (similar to mental health screenings)
-- - RLS ensures user isolation

-- CROSS-MODULE INTELLIGENCE (CMI):
-- mood_logs enables powerful correlations:
-- - "Your mood drops after skipping workouts" (Fitness → Mind)
-- - "Your energy increases on meditation days" (Mind → Life Coach)
-- - "Your stress spikes before deadlines" (Life Coach → Mind)
