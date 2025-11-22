-- Story 4.1: Guided Meditation Library Tables
-- Created: 2025-11-22
-- Epic: 4 - Mind & Emotion

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Meditation Content Table (Public Read Access)
CREATE TABLE meditations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  duration_seconds INT NOT NULL CHECK (duration_seconds > 0),
  category TEXT NOT NULL CHECK (category IN ('stress_relief', 'sleep', 'focus', 'anxiety', 'gratitude')),
  audio_url TEXT NOT NULL,
  thumbnail_url TEXT NOT NULL,
  is_premium BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_meditations_category ON meditations(category);
CREATE INDEX idx_meditations_duration ON meditations(duration_seconds);
CREATE INDEX idx_meditations_is_premium ON meditations(is_premium);

-- Meditation Favorites Table (User-specific with RLS)
CREATE TABLE meditation_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  meditation_id UUID NOT NULL REFERENCES meditations(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, meditation_id)
);

-- Index for user favorites lookup
CREATE INDEX idx_favorites_user ON meditation_favorites(user_id);
CREATE INDEX idx_favorites_meditation ON meditation_favorites(meditation_id);

-- Enable RLS on meditation_favorites
ALTER TABLE meditation_favorites ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only read/write their own favorites
CREATE POLICY "Users can view own favorites"
  ON meditation_favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites"
  ON meditation_favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
  ON meditation_favorites FOR DELETE
  USING (auth.uid() = user_id);

-- Meditation Sessions Table (Completion Tracking with RLS)
CREATE TABLE meditation_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  meditation_id UUID NOT NULL REFERENCES meditations(id) ON DELETE CASCADE,
  duration_listened_seconds INT NOT NULL CHECK (duration_listened_seconds >= 0),
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for session queries
CREATE INDEX idx_sessions_user_meditation ON meditation_sessions(user_id, meditation_id);
CREATE INDEX idx_sessions_completed ON meditation_sessions(completed);
CREATE INDEX idx_sessions_completed_at ON meditation_sessions(completed_at);

-- Enable RLS on meditation_sessions
ALTER TABLE meditation_sessions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only read/write their own sessions
CREATE POLICY "Users can view own sessions"
  ON meditation_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions"
  ON meditation_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions"
  ON meditation_sessions FOR UPDATE
  USING (auth.uid() = user_id);

-- Public read access for meditations table (no RLS)
-- Meditations are public content, accessible to all authenticated users
GRANT SELECT ON meditations TO authenticated;
GRANT SELECT ON meditations TO anon;

-- Updated_at trigger for meditations
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_meditations_updated_at BEFORE UPDATE ON meditations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
