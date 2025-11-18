# Sprint 0: Database Schema Completion - Migration Files

**Sprint:** Sprint 0 - Database Schema Completion
**Status:** Ready to Apply
**Date:** 2025-01-17
**Prerequisites:** Epic 0 Story 0.3 (Supabase Backend Setup)

---

## Overview

This directory contains **6 SQL migration files** that add missing database tables required by the UX Design specification.

### What Gets Created

| Migration | Table | Blocks FRs | Priority |
|-----------|-------|-----------|----------|
| `001_workout_templates.sql` | `workout_templates` | FR43-46 | HIGH |
| `002_mental_health_screenings.sql` | `mental_health_screenings` | FR66-70 | **CRITICAL** |
| `003_subscriptions.sql` | `subscriptions` | FR91-97 | HIGH |
| `004_streaks.sql` | `streaks` | FR85-90 | MEDIUM |
| `005_ai_conversations.sql` | `ai_conversations` | FR18-24 | MEDIUM |
| `006_mood_logs.sql` | `mood_logs` | FR55-60 | MEDIUM |

**Total Impact:** Unblocks 38/123 FRs (31%)

---

## Prerequisites

Before applying these migrations:

✅ **Epic 0 Story 0.3 completed** (Supabase backend setup)
✅ **Supabase project created** (via Supabase Dashboard)
✅ **Database accessible** (either via CLI or Dashboard)
✅ **PostgreSQL version 15+** (Supabase default)

---

## Method 1: Supabase CLI (Recommended)

**Best for:** Local development with version control

### Step 1: Copy migrations to Supabase directory

Once you've completed Epic 0 Story 0.3 and have a `supabase/` directory:

```bash
# Copy all migration files
cp migrations/sprint-0/*.sql supabase/migrations/

# Or copy manually via Windows Explorer
# From: migrations/sprint-0/
# To:   supabase/migrations/
```

### Step 2: Rename files with Supabase timestamp format

Supabase expects migrations in format: `YYYYMMDDHHMMSS_description.sql`

```bash
# Rename files (example timestamps)
mv supabase/migrations/001_workout_templates.sql \
   supabase/migrations/20250117100000_workout_templates.sql

mv supabase/migrations/002_mental_health_screenings.sql \
   supabase/migrations/20250117100001_mental_health_screenings.sql

mv supabase/migrations/003_subscriptions.sql \
   supabase/migrations/20250117100002_subscriptions.sql

mv supabase/migrations/004_streaks.sql \
   supabase/migrations/20250117100003_streaks.sql

mv supabase/migrations/005_ai_conversations.sql \
   supabase/migrations/20250117100004_ai_conversations.sql

mv supabase/migrations/006_mood_logs.sql \
   supabase/migrations/20250117100005_mood_logs.sql
```

### Step 3: Apply migrations

```bash
# Apply all migrations to remote Supabase project
supabase db push

# Verify migrations applied
supabase migration list
```

---

## Method 2: Supabase Dashboard SQL Editor (Quick)

**Best for:** Quick setup without CLI

### Step 1: Open Supabase Dashboard

1. Go to https://app.supabase.com
2. Select your project
3. Navigate to **SQL Editor** (left sidebar)

### Step 2: Run each migration manually

For each migration file (001-006):

1. Click **+ New Query**
2. Copy the entire SQL file contents
3. Paste into SQL Editor
4. Click **Run** (or Ctrl+Enter)
5. Wait for confirmation: "Success. No rows returned"

**Run migrations in order:** 001 → 002 → 003 → 004 → 005 → 006

### Step 3: Verify tables created

Run this query in SQL Editor:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

**Expected output:**
- ai_conversations
- mental_health_screenings
- mood_logs
- streaks
- subscriptions
- workout_templates

---

## Method 3: Direct PostgreSQL (psql)

**Best for:** Direct database access

### Step 1: Get connection string

From Supabase Dashboard:
1. Go to **Settings** → **Database**
2. Copy **Connection string** (URI format)
3. Replace `[YOUR-PASSWORD]` with your database password

### Step 2: Apply migrations

```bash
# Connect to database
psql "postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres"

# Apply each migration
\i migrations/sprint-0/001_workout_templates.sql
\i migrations/sprint-0/002_mental_health_screenings.sql
\i migrations/sprint-0/003_subscriptions.sql
\i migrations/sprint-0/004_streaks.sql
\i migrations/sprint-0/005_ai_conversations.sql
\i migrations/sprint-0/006_mood_logs.sql

# Verify tables
\dt
```

---

## Validation

After applying all migrations, run these validation queries:

### 1. Verify all 6 tables exist

```sql
SELECT COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'workout_templates',
    'mental_health_screenings',
    'subscriptions',
    'streaks',
    'ai_conversations',
    'mood_logs'
  );
```

**Expected:** `table_count = 6`

### 2. Verify RLS enabled on all tables

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'workout_templates',
    'mental_health_screenings',
    'subscriptions',
    'streaks',
    'ai_conversations',
    'mood_logs'
  );
```

**Expected:** All tables have `rowsecurity = true`

### 3. Verify system templates inserted

```sql
SELECT COUNT(*) AS system_templates
FROM workout_templates
WHERE created_by = 'system';
```

**Expected:** `system_templates = 3` (Push/Pull/Leg)

### 4. Verify indexes created

```sql
SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN (
    'workout_templates',
    'mental_health_screenings',
    'subscriptions',
    'streaks',
    'ai_conversations',
    'mood_logs'
  )
ORDER BY tablename, indexname;
```

**Expected:** 18+ indexes total

### 5. Verify triggers exist

```sql
SELECT tgname, tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid::regclass::text IN (
  'workout_templates',
  'subscriptions',
  'streaks',
  'ai_conversations',
  'mood_logs'
)
ORDER BY table_name, tgname;
```

**Expected:** 5+ triggers (updated_at triggers + mood_logs → daily_metrics)

---

## Troubleshooting

### Error: "relation 'auth.users' does not exist"

**Cause:** Auth schema not initialized
**Fix:** Run Epic 0 Story 0.3 first (Supabase Auth setup)

### Error: "relation 'user_daily_metrics' does not exist"

**Cause:** Missing base tables from architecture.md
**Fix:** Create base tables first (see `docs/ecosystem/architecture.md` Section 6.1)

### Error: "permission denied for schema public"

**Cause:** Insufficient database permissions
**Fix:** Use service role key or database password (not anon key)

### Error: "duplicate key value violates unique constraint"

**Cause:** System templates already inserted (running migration twice)
**Fix:** Safe to ignore, or delete existing templates:
```sql
DELETE FROM workout_templates WHERE created_by = 'system';
```

---

## Next Steps

After successfully applying all 6 migrations:

1. ✅ **Update architecture.md**
   - Add new tables to Section 6.1 (Database Schema)
   - Document new columns and relationships

2. ✅ **Update implementation-readiness-report.md**
   - Change readiness from 82% → 100%
   - Update FR coverage

3. ✅ **Create Drift mirror tables** (Story S0.8)
   - Add all 6 tables to Flutter Drift schema
   - Enable offline-first support

4. ✅ **Create Edge Functions** (Story S0.7)
   - `process-mental-health-screening`
   - `generate-workout-plan-from-template`

5. 🚀 **Proceed to Epic 1**
   - Story 1.1: User Account Creation
   - Story 1.2: User Login & Session Management
   - All database tables now ready!

---

## Migration Details

### 001_workout_templates.sql
- **Creates:** `workout_templates` table
- **Inserts:** 3 system templates (Push/Pull/Leg)
- **RLS:** Users can view own + public templates
- **Indexes:** 3 (user, public, created)
- **UX Reference:** Section 14 (Templates & Workout Library)

### 002_mental_health_screenings.sql ⚠️ CRITICAL
- **Creates:** `mental_health_screenings` table
- **Security:** E2EE fields (encrypted_answers, encryption_iv)
- **Crisis Detection:** `crisis_threshold_reached` flag
- **RLS:** Users can ONLY access their own results
- **Compliance:** HIPAA, GDPR
- **UX Reference:** Section 16 (Mental Health Screening Results)

### 003_subscriptions.sql
- **Creates:** `subscriptions` table
- **Trigger:** Auto-create free tier for new users
- **Stripe Integration:** customer_id, subscription_id fields
- **Tiers:** free, mind (€2.99), fitness (€2.99), three_pack (€5.00), plus (€7.00)
- **UX Reference:** Section 15 (Subscription & Paywall)

### 004_streaks.sql
- **Creates:** `streaks` table
- **Tracks:** workout, meditation, check_in streaks
- **Gamification:** current_streak, longest_streak, freeze_used
- **Unique:** One streak record per user per type
- **UX Reference:** Section 9 (Gamification)

### 005_ai_conversations.sql
- **Creates:** `ai_conversations` table
- **JSONB:** Messages array with role + content + timestamp
- **AI Models:** llama (free), claude (standard), gpt4 (premium)
- **Types:** daily_plan, goal_advice, general, fitness, mental_health
- **UX Reference:** Section 2 (AI Conversations)

### 006_mood_logs.sql
- **Creates:** `mood_logs` table
- **Trigger:** Auto-update `user_daily_metrics` on insert
- **Scales:** mood_score, energy_score, stress_level (1-5)
- **Multi-log:** Multiple logs per day allowed
- **CMI:** Enables cross-module pattern detection
- **UX Reference:** Section 6 (Mood & Stress Tracking)

---

## Files in This Directory

```
migrations/sprint-0/
├── README.md                                  (this file)
├── 001_workout_templates.sql                  (119 lines)
├── 002_mental_health_screenings.sql           (167 lines)
├── 003_subscriptions.sql                      (165 lines)
├── 004_streaks.sql                            (147 lines)
├── 005_ai_conversations.sql                   (172 lines)
└── 006_mood_logs.sql                          (180 lines)
```

**Total:** 950+ lines of SQL

---

## Support

- **Documentation:** See `docs/ecosystem/sprint-0-database-schema-completion.md`
- **Architecture:** See `docs/ecosystem/architecture.md` Section 6.1
- **UX Design:** See `docs/ecosystem/ux-design-specification.md`
- **Issues:** Open issue in GitHub repository

---

**Author:** Winston (BMAD Architect)
**Date:** 2025-01-17
**Status:** Ready for Application
**Effort:** 15-30 minutes to apply all migrations
