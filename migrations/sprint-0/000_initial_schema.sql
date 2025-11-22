-- ============================================================================
-- Migration: 000_initial_schema (REQUIRED FIRST)
-- Purpose: Create base tables required by Sprint 0 migrations
-- Dependency: None (run this FIRST before 001-006)
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- Core Table: user_daily_metrics
-- ============================================================================

-- Purpose: Aggregated daily metrics for Cross-Module Intelligence (CMI)
-- Required by: Migration 006 (mood_logs table has trigger that updates this table)

CREATE TABLE IF NOT EXISTS user_daily_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  date DATE NOT NULL,

  -- Fitness metrics
  workout_completed BOOLEAN DEFAULT FALSE,
  workout_duration_minutes INTEGER DEFAULT 0,
  calories_burned INTEGER DEFAULT 0,
  sets_completed INTEGER DEFAULT 0,
  workout_intensity DECIMAL(3,2),

  -- Mind metrics
  meditation_completed BOOLEAN DEFAULT FALSE,
  meditation_duration_minutes INTEGER DEFAULT 0,
  mood_score INTEGER,
  stress_level INTEGER,
  journal_entries_count INTEGER DEFAULT 0,

  -- Life Coach metrics
  daily_plan_generated BOOLEAN DEFAULT FALSE,
  tasks_completed INTEGER DEFAULT 0,
  tasks_total INTEGER DEFAULT 0,
  completion_rate DECIMAL(3,2),
  ai_conversations_count INTEGER DEFAULT 0,

  aggregated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, date)
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_user_daily_metrics_user_date ON user_daily_metrics(user_id, date DESC);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE user_daily_metrics ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access their own data
CREATE POLICY "Users can only access their own metrics"
  ON user_daily_metrics FOR ALL
  USING (auth.uid() = user_id);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE user_daily_metrics IS 'Aggregated daily metrics for Cross-Module Intelligence (CMI) pattern detection';
COMMENT ON COLUMN user_daily_metrics.mood_score IS 'Average mood score for the day (1-5). Auto-updated by mood_logs trigger.';
COMMENT ON COLUMN user_daily_metrics.stress_level IS 'Average stress level for the day (1-5). Auto-updated by mood_logs trigger.';

-- ============================================================================
-- VALIDATION QUERY
-- ============================================================================

-- Expected: Table created successfully
-- SELECT COUNT(*) FROM information_schema.tables
-- WHERE table_name = 'user_daily_metrics';
