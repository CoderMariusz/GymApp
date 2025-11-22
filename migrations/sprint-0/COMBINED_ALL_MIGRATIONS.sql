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
-- ============================================================================
-- Migration: 003_subscriptions
-- Sprint: Sprint 0 - Database Schema Completion
-- Story: S0.3 - Add subscriptions Table
-- Blocks: FR91-97 (Subscription & Paywall UX)
-- Priority: HIGH
-- ============================================================================

-- Create subscriptions table
-- Purpose: Track user subscription tiers and Stripe integration
-- UX Reference: Section 15 in ux-design-specification.md (lines 1438-1762)

CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL UNIQUE,

  -- Subscription tier
  -- 'free' = Life Coach (basic) only
  -- 'mind' = Mind & Emotion module (€2.99/mo)
  -- 'fitness' = Fitness Coach AI module (€2.99/mo)
  -- 'three_pack' = All 3 modules (€5.00/mo)
  -- 'plus' = LifeOS Plus (all modules + future releases) (€7.00/mo)
  tier TEXT NOT NULL DEFAULT 'free' CHECK (tier IN ('free', 'mind', 'fitness', 'three_pack', 'plus')),

  -- Stripe integration
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,

  -- Subscription status
  -- 'active' = Paid and active
  -- 'trial' = 14-day trial active
  -- 'canceled' = Canceled but still active until period_end
  -- 'past_due' = Payment failed
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'trial', 'canceled', 'past_due')),

  -- Billing cycle
  trial_ends_at TIMESTAMPTZ,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_stripe ON subscriptions(stripe_subscription_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own subscription
CREATE POLICY "Users can view their own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policy: Service role can manage all subscriptions (for Stripe webhooks)
CREATE POLICY "Service role can manage subscriptions"
  ON subscriptions FOR ALL
  USING (auth.role() = 'service_role');

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Auto-update updated_at on UPDATE
CREATE OR REPLACE FUNCTION update_subscriptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_subscriptions_updated_at();

-- Trigger: Auto-create free tier subscription for new users
CREATE OR REPLACE FUNCTION create_subscription_for_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO subscriptions (user_id, tier, status)
  VALUES (NEW.id, 'free', 'active');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_subscription_for_new_user
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_subscription_for_new_user();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE subscriptions IS 'Tracks user subscription tiers and Stripe billing integration';
COMMENT ON COLUMN subscriptions.tier IS 'Subscription tier: free, mind (€2.99), fitness (€2.99), three_pack (€5.00), plus (€7.00)';
COMMENT ON COLUMN subscriptions.status IS 'Subscription status: active, trial (14 days), canceled, past_due';
COMMENT ON COLUMN subscriptions.stripe_customer_id IS 'Stripe Customer ID (cus_xxx). Updated by Stripe webhook.';
COMMENT ON COLUMN subscriptions.stripe_subscription_id IS 'Stripe Subscription ID (sub_xxx). Updated by Stripe webhook.';

-- ============================================================================
-- VALIDATION QUERIES (Run these after applying migration)
-- ============================================================================

-- Expected: Table exists with tier check constraint
-- SELECT column_name, data_type FROM information_schema.columns
-- WHERE table_name = 'subscriptions';

-- Expected: RLS policies exist
-- SELECT * FROM pg_policies WHERE tablename = 'subscriptions';

-- Expected: Triggers exist
-- SELECT tgname FROM pg_trigger WHERE tgrelid = 'subscriptions'::regclass;

-- ============================================================================
-- NOTES FOR DEVELOPERS
-- ============================================================================

-- STRIPE INTEGRATION:
-- 1. Stripe webhook handler: supabase/functions/stripe-webhook
-- 2. Webhook events: customer.subscription.created, updated, deleted
-- 3. Webhook updates: tier, status, current_period_end, canceled_at
-- 4. Test mode: Use Stripe test keys during development

-- PRICING TIERS:
-- free:       Life Coach (basic) - FREE
-- mind:       Mind & Emotion - €2.99/month
-- fitness:    Fitness Coach AI - €2.99/month
-- three_pack: All 3 modules - €5.00/month (save €0.97/mo)
-- plus:       LifeOS Plus (all current + future modules) - €7.00/month

-- TRIAL PERIOD:
-- - All paid tiers include 14-day free trial
-- - trial_ends_at set to NOW() + 14 days
-- - status = 'trial' during trial period
-- - Stripe charges after trial ends

-- NEW USER FLOW:
-- 1. User signs up → auth.users row created
-- 2. Trigger auto-creates subscriptions row with tier='free'
-- 3. User upgrades → Stripe checkout → webhook updates tier
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
-- ============================================================================
-- Migration: 005_ai_conversations
-- Sprint: Sprint 0 - Database Schema Completion
-- Story: S0.5 - Add ai_conversations Table
-- Blocks: FR18-24 (AI Chat History)
-- Priority: MEDIUM
-- ============================================================================

-- Create ai_conversations table
-- Purpose: Store AI conversation history for daily plans, goal advice, and general chat
-- UX Reference: Section 2 in ux-design-specification.md (AI Conversations)

CREATE TABLE IF NOT EXISTS ai_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,

  -- Conversation messages stored as JSONB array
  -- Structure: [{ role: 'user' | 'assistant', content: TEXT, timestamp: ISO8601 }]
  messages JSONB NOT NULL DEFAULT '[]'::JSONB,

  -- AI model used for this conversation
  -- 'llama' = Llama 3 (free tier)
  -- 'claude' = Claude (standard tier)
  -- 'gpt4' = GPT-4 (premium tier)
  ai_model TEXT NOT NULL CHECK (ai_model IN ('llama', 'claude', 'gpt4')),

  -- Conversation type
  -- 'daily_plan' = AI-generated daily plan conversation
  -- 'goal_advice' = Goal-specific coaching
  -- 'general' = General life coaching
  -- 'fitness' = Fitness-specific advice
  -- 'mental_health' = Mental health support
  conversation_type TEXT CHECK (conversation_type IN ('daily_plan', 'goal_advice', 'general', 'fitness', 'mental_health')),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_ai_conversations_user ON ai_conversations(user_id);
CREATE INDEX idx_ai_conversations_user_date ON ai_conversations(user_id, created_at DESC);
CREATE INDEX idx_ai_conversations_type ON ai_conversations(conversation_type);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage their own conversations
CREATE POLICY "Users can manage their own conversations"
  ON ai_conversations FOR ALL
  USING (auth.uid() = user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Auto-update updated_at on UPDATE
CREATE OR REPLACE FUNCTION update_ai_conversations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_ai_conversations_updated_at
  BEFORE UPDATE ON ai_conversations
  FOR EACH ROW
  EXECUTE FUNCTION update_ai_conversations_updated_at();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE ai_conversations IS 'Stores AI conversation history for daily plans, goal advice, and coaching';
COMMENT ON COLUMN ai_conversations.messages IS 'JSONB array of messages: [{ role: "user" | "assistant", content: TEXT, timestamp: ISO8601 }]';
COMMENT ON COLUMN ai_conversations.ai_model IS 'AI model used: llama (free), claude (standard), gpt4 (premium)';
COMMENT ON COLUMN ai_conversations.conversation_type IS 'Type: daily_plan, goal_advice, general, fitness, mental_health';

-- ============================================================================
-- VALIDATION QUERIES (Run these after applying migration)
-- ============================================================================

-- Expected: Table exists with JSONB messages column
-- SELECT column_name, data_type FROM information_schema.columns
-- WHERE table_name = 'ai_conversations';

-- Expected: RLS policies exist
-- SELECT * FROM pg_policies WHERE tablename = 'ai_conversations';

-- Expected: Check constraint on ai_model
-- SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint
-- WHERE conrelid = 'ai_conversations'::regclass AND contype = 'c';

-- ============================================================================
-- NOTES FOR DEVELOPERS
-- ============================================================================

-- MESSAGE FORMAT:
-- {
--   "role": "user",        // or "assistant"
--   "content": "How can I improve my fitness?",
--   "timestamp": "2025-01-16T10:30:00Z"
-- }

-- EXAMPLE MESSAGES ARRAY:
-- [
--   {
--     "role": "user",
--     "content": "Create me a daily plan for tomorrow",
--     "timestamp": "2025-01-16T09:00:00Z"
--   },
--   {
--     "role": "assistant",
--     "content": "Based on your goals, here's your plan: ...",
--     "timestamp": "2025-01-16T09:00:15Z"
--   }
-- ]

-- AI MODEL SELECTION (by tier):
-- Free tier:     Llama 3 (self-hosted)
-- Standard tier: Claude (Anthropic API)
-- Premium tier:  GPT-4 (OpenAI API)

-- USAGE:
-- 1. User sends message → append to messages array
-- 2. AI responds → append assistant message
-- 3. Update updated_at timestamp
-- 4. Query: SELECT messages FROM ai_conversations WHERE id = ?

-- CONVERSATION TYPES:
-- daily_plan:    "Create me a daily plan" → AI generates structured plan
-- goal_advice:   "How do I achieve X?" → AI provides coaching
-- general:       Open-ended life coaching chat
-- fitness:       "How many sets should I do?" → Fitness-specific
-- mental_health: "I'm feeling anxious" → Mental health support

-- COST OPTIMIZATION:
-- - Limit conversation history to last 20 messages (context window)
-- - Truncate old conversations after 90 days
-- - Use cheaper model (Llama) for simple queries
-- - Use GPT-4 only for complex reasoning (premium users)

-- PRIVACY:
-- - Conversations stored in PostgreSQL (not sent to AI after response)
-- - RLS ensures user isolation
-- - Consider E2EE for mental_health conversations (future)
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
