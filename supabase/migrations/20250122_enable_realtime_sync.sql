-- Migration: Enable Realtime for Data Sync (Story 1.5)
-- Description: Enables Supabase Realtime on key tables and adds automatic timestamp triggers
-- Created: 2025-01-22

-- =============================================================================
-- 1. Enable Realtime on All User Tables
-- =============================================================================

-- Enable Realtime publication for workout_templates
ALTER PUBLICATION supabase_realtime ADD TABLE workout_templates;

-- Enable Realtime publication for mood_logs
ALTER PUBLICATION supabase_realtime ADD TABLE mood_logs;

-- Enable Realtime publication for mental_health_screenings
ALTER PUBLICATION supabase_realtime ADD TABLE mental_health_screenings;

-- Enable Realtime publication for streaks
ALTER PUBLICATION supabase_realtime ADD TABLE streaks;

-- Enable Realtime publication for ai_conversations
ALTER PUBLICATION supabase_realtime ADD TABLE ai_conversations;

-- Enable Realtime publication for meditation tables (if they exist)
DO $$
BEGIN
  IF EXISTS (
    SELECT FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = 'meditation_sessions'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE meditation_sessions;
  END IF;
END $$;

-- =============================================================================
-- 2. Add Automatic Updated At Triggers
-- =============================================================================

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers to tables that have this column

-- Workout Templates
DROP TRIGGER IF EXISTS update_workout_templates_updated_at ON workout_templates;
CREATE TRIGGER update_workout_templates_updated_at
  BEFORE UPDATE ON workout_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Subscriptions
DROP TRIGGER IF EXISTS update_subscriptions_updated_at ON subscriptions;
CREATE TRIGGER update_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Streaks
DROP TRIGGER IF EXISTS update_streaks_updated_at ON streaks;
CREATE TRIGGER update_streaks_updated_at
  BEFORE UPDATE ON streaks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- AI Conversations
DROP TRIGGER IF EXISTS update_ai_conversations_updated_at ON ai_conversations;
CREATE TRIGGER update_ai_conversations_updated_at
  BEFORE UPDATE ON ai_conversations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- 3. Add Indexes for Sync Performance
-- =============================================================================

-- Index on user_id and updated_at for efficient sync queries
CREATE INDEX IF NOT EXISTS idx_workout_templates_user_updated
  ON workout_templates(user_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_mood_logs_user_created
  ON mood_logs(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_mental_health_screenings_user_created
  ON mental_health_screenings(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_streaks_user_updated
  ON streaks(user_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_updated
  ON ai_conversations(user_id, updated_at DESC);

-- =============================================================================
-- 4. Row Level Security for Realtime
-- =============================================================================

-- Ensure RLS is enabled on all tables (should already be enabled from previous migrations)
ALTER TABLE workout_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE mood_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE mental_health_screenings ENABLE ROW LEVEL SECURITY;
ALTER TABLE streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;

-- Grant Realtime access (users can only see their own data via RLS policies)
GRANT SELECT ON workout_templates TO authenticated;
GRANT SELECT ON mood_logs TO authenticated;
GRANT SELECT ON mental_health_screenings TO authenticated;
GRANT SELECT ON streaks TO authenticated;
GRANT SELECT ON ai_conversations TO authenticated;

-- =============================================================================
-- 5. Comments for Documentation
-- =============================================================================

COMMENT ON FUNCTION update_updated_at_column() IS 'Automatically updates the updated_at column on row updates';
COMMENT ON TRIGGER update_workout_templates_updated_at ON workout_templates IS 'Auto-update updated_at for workout_templates';
COMMENT ON TRIGGER update_subscriptions_updated_at ON subscriptions IS 'Auto-update updated_at for subscriptions';
COMMENT ON TRIGGER update_streaks_updated_at ON streaks IS 'Auto-update updated_at for streaks';
COMMENT ON TRIGGER update_ai_conversations_updated_at ON ai_conversations IS 'Auto-update updated_at for ai_conversations';
