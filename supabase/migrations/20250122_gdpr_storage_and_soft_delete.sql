-- Migration: GDPR Storage and Soft Delete Configuration
-- Description: Sets up storage bucket for exports and soft delete for user profiles
-- Story: 1.6 - GDPR Compliance
-- Created: 2025-01-22

-- =============================================================================
-- 1. Create Storage Bucket for Data Exports
-- =============================================================================

-- Create exports bucket (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('exports', 'exports', false)
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- 2. Storage RLS Policies - Users can only access their own exports
-- =============================================================================

-- Policy: Users can upload to their own folder
CREATE POLICY "Users can upload to own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'exports' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy: Users can read their own exports
CREATE POLICY "Users can read own exports"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'exports' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy: Auto-delete expired exports (system only)
CREATE POLICY "System can delete expired exports"
ON storage.objects FOR DELETE
TO service_role
USING (bucket_id = 'exports');

-- =============================================================================
-- 3. Add Soft Delete Column to User Profiles
-- =============================================================================

-- Add deletion_requested_at column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'user_profiles'
    AND column_name = 'deletion_requested_at'
  ) THEN
    ALTER TABLE user_profiles
    ADD COLUMN deletion_requested_at TIMESTAMPTZ;
  END IF;
END $$;

-- Create index for efficiently finding users with pending deletion
CREATE INDEX IF NOT EXISTS idx_users_deletion_requested
  ON user_profiles(deletion_requested_at)
  WHERE deletion_requested_at IS NOT NULL;

-- =============================================================================
-- 4. Add Lifecycle Policy for Storage (Auto-delete after 7 days)
-- =============================================================================

-- Note: This is configured via Supabase Dashboard or CLI:
-- supabase storage update exports --lifecycle-rules '[
--   {
--     "action": "Delete",
--     "condition": {
--       "age": 7,
--       "matchesPrefix": [""]
--     }
--   }
-- ]'

-- Comment for documentation
COMMENT ON COLUMN user_profiles.deletion_requested_at IS 'Timestamp when user requested account deletion. Null if no deletion pending.';
COMMENT ON INDEX idx_users_deletion_requested IS 'Index for finding users with pending deletion requests';

-- =============================================================================
-- 5. Function to Auto-Cancel Deletion on User Activity (Optional Enhancement)
-- =============================================================================

CREATE OR REPLACE FUNCTION auto_cancel_deletion_on_activity()
RETURNS TRIGGER AS $$
BEGIN
  -- If user has pending deletion but is creating/updating data, auto-cancel
  IF EXISTS (
    SELECT 1
    FROM user_profiles
    WHERE id = NEW.user_id
    AND deletion_requested_at IS NOT NULL
  ) THEN
    -- Update user profile to clear deletion
    UPDATE user_profiles
    SET deletion_requested_at = NULL
    WHERE id = NEW.user_id;

    -- Cancel deletion request
    UPDATE account_deletion_requests
    SET status = 'cancelled'
    WHERE user_id = NEW.user_id
    AND status = 'pending';

    -- Log activity (optional)
    RAISE NOTICE 'Auto-cancelled account deletion for user % due to activity', NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Optionally add triggers to key tables to auto-cancel deletion on activity
-- Example: If user creates a workout, assume they want to keep their account
-- CREATE TRIGGER auto_cancel_on_workout_create
--   BEFORE INSERT ON workout_templates
--   FOR EACH ROW
--   EXECUTE FUNCTION auto_cancel_deletion_on_activity();

-- =============================================================================
-- 6. Add Email Notification Queue (Optional)
-- =============================================================================

-- Table to queue email notifications for GDPR operations
CREATE TABLE IF NOT EXISTS gdpr_email_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email_type TEXT NOT NULL, -- 'export_ready', 'deletion_scheduled', 'deletion_reminder'
  recipient_email TEXT NOT NULL,
  template_data JSONB,
  status TEXT DEFAULT 'pending', -- 'pending', 'sent', 'failed'
  attempts INT DEFAULT 0,
  last_attempt_at TIMESTAMPTZ,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  sent_at TIMESTAMPTZ
);

CREATE INDEX idx_email_queue_status ON gdpr_email_queue(status);
CREATE INDEX idx_email_queue_created ON gdpr_email_queue(created_at);

COMMENT ON TABLE gdpr_email_queue IS 'Queue for GDPR-related email notifications';

-- =============================================================================
-- 7. Grant Necessary Permissions
-- =============================================================================

-- Grant storage access to authenticated users
GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;

-- Grant select on email queue to service role (for cron jobs)
GRANT SELECT, UPDATE ON gdpr_email_queue TO service_role;

-- =============================================================================
-- 8. Verification Query (for manual testing)
-- =============================================================================

-- To verify setup, run:
-- SELECT * FROM storage.buckets WHERE id = 'exports';
-- SELECT * FROM user_profiles WHERE deletion_requested_at IS NOT NULL;
