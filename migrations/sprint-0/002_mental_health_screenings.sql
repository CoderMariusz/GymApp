-- ============================================================================
-- Migration: 002_mental_health_screenings
-- Sprint: Sprint 0 - Database Schema Completion
-- Story: S0.2 - Add mental_health_screenings Table
-- Blocks: FR66-70 (Mental Health Screening Results UX)
-- Priority: CRITICAL (SAFETY-CRITICAL FEATURE)
-- ============================================================================

-- Create mental_health_screenings table
-- Purpose: Store GAD-7 and PHQ-9 screening results with E2EE encryption
-- UX Reference: Section 16 in ux-design-specification.md (lines 1764-2112)

-- CRITICAL SAFETY REQUIREMENTS:
-- 1. Auto-detect crisis threshold (GAD-7 ≥15, PHQ-9 ≥20, Q9 ≥2)
-- 2. E2EE for answers field (sensitive health data)
-- 3. DO NOT log crisis modal trigger to analytics
-- 4. Offline-first (results cached locally)

CREATE TABLE IF NOT EXISTS mental_health_screenings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,

  screening_type TEXT NOT NULL CHECK (screening_type IN ('GAD-7', 'PHQ-9')),
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 27),
  severity TEXT NOT NULL CHECK (severity IN ('minimal', 'mild', 'moderate', 'moderately_severe', 'severe')),

  -- Individual question responses (E2EE encrypted, stored as TEXT not JSONB)
  -- Client-side encryption before insert (AES-256-GCM)
  -- See: lib/core/encryption/screening_encryption.dart
  encrypted_answers TEXT NOT NULL,
  encryption_iv TEXT NOT NULL,  -- Initialization vector for AES-256-GCM

  -- Crisis tracking (FR69)
  crisis_threshold_reached BOOLEAN DEFAULT FALSE,
  crisis_modal_shown BOOLEAN DEFAULT FALSE,  -- Set by client after showing modal

  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_screenings_user_type ON mental_health_screenings(user_id, screening_type);
CREATE INDEX idx_screenings_user_date ON mental_health_screenings(user_id, completed_at DESC);
CREATE INDEX idx_screenings_crisis ON mental_health_screenings(crisis_threshold_reached)
  WHERE crisis_threshold_reached = TRUE;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE mental_health_screenings ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access their own screening results
-- CRITICAL: This ensures HIPAA/GDPR compliance - no user can see another's mental health data
CREATE POLICY "Users can only access their own screenings"
  ON mental_health_screenings FOR ALL
  USING (auth.uid() = user_id);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE mental_health_screenings IS 'Stores GAD-7 and PHQ-9 mental health screening results with E2EE encryption';
COMMENT ON COLUMN mental_health_screenings.encrypted_answers IS 'AES-256-GCM encrypted array of question answers. Encrypted client-side before insert.';
COMMENT ON COLUMN mental_health_screenings.encryption_iv IS 'Initialization vector for AES-256-GCM decryption. Required to decrypt answers.';
COMMENT ON COLUMN mental_health_screenings.crisis_threshold_reached IS 'TRUE if GAD-7 ≥15, PHQ-9 ≥20, or PHQ-9 Q9 ≥2. Calculated by Edge Function.';
COMMENT ON COLUMN mental_health_screenings.crisis_modal_shown IS 'TRUE after crisis resources modal shown to user. Prevents duplicate modals.';

-- ============================================================================
-- VALIDATION QUERIES (Run these after applying migration)
-- ============================================================================

-- Expected: Table exists with E2EE fields
-- SELECT column_name, data_type FROM information_schema.columns
-- WHERE table_name = 'mental_health_screenings';

-- Expected: RLS policies exist
-- SELECT * FROM pg_policies WHERE tablename = 'mental_health_screenings';

-- Expected: Check constraints exist
-- SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint
-- WHERE conrelid = 'mental_health_screenings'::regclass;

-- ============================================================================
-- NOTES FOR DEVELOPERS
-- ============================================================================

-- ENCRYPTION IMPLEMENTATION:
-- 1. Client-side encryption helper: lib/core/encryption/screening_encryption.dart
-- 2. Encryption key stored in FlutterSecureStorage (device keychain)
-- 3. Edge Function validates score and sets crisis_threshold_reached
-- 4. Crisis modal auto-triggers if crisis_threshold_reached = TRUE

-- CRISIS THRESHOLDS:
-- GAD-7:  0-4 minimal, 5-9 mild, 10-14 moderate, 15-21 severe
-- PHQ-9:  0-4 minimal, 5-9 mild, 10-14 moderate, 15-19 moderately severe, 20-27 severe
-- PHQ-9 Q9 (self-harm): 0 not at all, 1 several days, 2 more than half the days, 3 nearly every day

-- PRIVACY & COMPLIANCE:
-- - Answers are E2EE (client-side only)
-- - RLS ensures user isolation
-- - Crisis modal trigger NOT logged to analytics (privacy)
-- - Compliant with HIPAA (US) and GDPR (EU)
