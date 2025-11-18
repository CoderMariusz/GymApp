-- ============================================================================
-- VALIDATION QUERIES - Sprint 0 Database Schema
-- Run these queries to verify all migrations applied successfully
-- ============================================================================

-- ============================================================================
-- TEST 1: Verify all 7 tables exist
-- ============================================================================

SELECT
  '✅ TEST 1: Table Count' AS test,
  COUNT(*) AS result,
  CASE
    WHEN COUNT(*) = 7 THEN '✅ PASS: All 7 tables exist'
    ELSE '❌ FAIL: Expected 7 tables, found ' || COUNT(*)
  END AS status
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'user_daily_metrics',
    'workout_templates',
    'mental_health_screenings',
    'subscriptions',
    'streaks',
    'ai_conversations',
    'mood_logs'
  );

-- ============================================================================
-- TEST 2: List all tables (visual verification)
-- ============================================================================

SELECT
  '✅ TEST 2: Tables List' AS test,
  table_name,
  '✅' AS status
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'user_daily_metrics',
    'workout_templates',
    'mental_health_screenings',
    'subscriptions',
    'streaks',
    'ai_conversations',
    'mood_logs'
  )
ORDER BY table_name;

-- ============================================================================
-- TEST 3: Verify RLS enabled on all tables
-- ============================================================================

SELECT
  '✅ TEST 3: RLS Enabled' AS test,
  tablename,
  CASE
    WHEN rowsecurity = true THEN '✅ ENABLED'
    ELSE '❌ DISABLED'
  END AS rls_status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'user_daily_metrics',
    'workout_templates',
    'mental_health_screenings',
    'subscriptions',
    'streaks',
    'ai_conversations',
    'mood_logs'
  )
ORDER BY tablename;

-- ============================================================================
-- TEST 4: Count RLS policies (should be 13+ policies)
-- ============================================================================

SELECT
  '✅ TEST 4: RLS Policies Count' AS test,
  COUNT(*) AS total_policies,
  CASE
    WHEN COUNT(*) >= 13 THEN '✅ PASS: ' || COUNT(*) || ' policies found'
    ELSE '⚠️ WARNING: Only ' || COUNT(*) || ' policies (expected 13+)'
  END AS status
FROM pg_policies
WHERE tablename IN (
  'user_daily_metrics',
  'workout_templates',
  'mental_health_screenings',
  'subscriptions',
  'streaks',
  'ai_conversations',
  'mood_logs'
);

-- ============================================================================
-- TEST 5: Verify system workout templates inserted
-- ============================================================================

SELECT
  '✅ TEST 5: System Templates' AS test,
  COUNT(*) AS template_count,
  CASE
    WHEN COUNT(*) = 3 THEN '✅ PASS: 3 system templates exist'
    ELSE '❌ FAIL: Expected 3 templates, found ' || COUNT(*)
  END AS status
FROM workout_templates
WHERE created_by = 'system';

-- ============================================================================
-- TEST 6: List system templates (visual verification)
-- ============================================================================

SELECT
  '✅ TEST 6: Template Names' AS test,
  name,
  is_public,
  created_by
FROM workout_templates
WHERE created_by = 'system'
ORDER BY name;

-- ============================================================================
-- TEST 7: Verify indexes created (should be 18+ indexes)
-- ============================================================================

SELECT
  '✅ TEST 7: Indexes Count' AS test,
  COUNT(*) AS index_count,
  CASE
    WHEN COUNT(*) >= 18 THEN '✅ PASS: ' || COUNT(*) || ' indexes found'
    ELSE '⚠️ WARNING: Only ' || COUNT(*) || ' indexes (expected 18+)'
  END AS status
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN (
    'user_daily_metrics',
    'workout_templates',
    'mental_health_screenings',
    'subscriptions',
    'streaks',
    'ai_conversations',
    'mood_logs'
  );

-- ============================================================================
-- TEST 8: Verify triggers exist (should be 7+ triggers)
-- ============================================================================

SELECT
  '✅ TEST 8: Triggers Count' AS test,
  COUNT(*) AS trigger_count,
  CASE
    WHEN COUNT(*) >= 7 THEN '✅ PASS: ' || COUNT(*) || ' triggers found'
    ELSE '⚠️ WARNING: Only ' || COUNT(*) || ' triggers (expected 7+)'
  END AS status
FROM pg_trigger
WHERE tgrelid::regclass::text IN (
  'user_daily_metrics',
  'workout_templates',
  'subscriptions',
  'streaks',
  'ai_conversations',
  'mood_logs'
);

-- ============================================================================
-- TEST 9: Verify UUID extension enabled
-- ============================================================================

SELECT
  '✅ TEST 9: UUID Extension' AS test,
  extname,
  '✅ ENABLED' AS status
FROM pg_extension
WHERE extname = 'uuid-ossp';

-- ============================================================================
-- TEST 10: Test table structure - workout_templates
-- ============================================================================

SELECT
  '✅ TEST 10: workout_templates columns' AS test,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'workout_templates'
ORDER BY ordinal_position;

-- ============================================================================
-- TEST 11: Test table structure - mental_health_screenings
-- ============================================================================

SELECT
  '✅ TEST 11: mental_health_screenings columns' AS test,
  column_name,
  data_type,
  CASE
    WHEN column_name IN ('encrypted_answers', 'encryption_iv') THEN '🔒 E2EE'
    ELSE ''
  END AS security
FROM information_schema.columns
WHERE table_name = 'mental_health_screenings'
ORDER BY ordinal_position;

-- ============================================================================
-- TEST 12: Test table structure - subscriptions
-- ============================================================================

SELECT
  '✅ TEST 12: subscriptions columns' AS test,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'subscriptions'
ORDER BY ordinal_position;

-- ============================================================================
-- SUMMARY
-- ============================================================================

SELECT
  '🎉 VALIDATION COMPLETE' AS summary,
  (SELECT COUNT(*) FROM information_schema.tables
   WHERE table_schema = 'public'
   AND table_name IN ('user_daily_metrics', 'workout_templates', 'mental_health_screenings', 'subscriptions', 'streaks', 'ai_conversations', 'mood_logs')
  ) AS tables_created,
  (SELECT COUNT(*) FROM workout_templates WHERE created_by = 'system') AS system_templates,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename IN ('user_daily_metrics', 'workout_templates', 'mental_health_screenings', 'subscriptions', 'streaks', 'ai_conversations', 'mood_logs')) AS rls_policies;
