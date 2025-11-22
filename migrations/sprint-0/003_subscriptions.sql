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
