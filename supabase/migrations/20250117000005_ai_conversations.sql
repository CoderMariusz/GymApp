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
