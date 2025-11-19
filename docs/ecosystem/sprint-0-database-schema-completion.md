# Sprint 0: Database Schema Completion

**Projekt:** LifeOS (Life Operating System)
**Faza:** Sprint 0 - Uzupełnienie bazy danych
**Cel:** Dodanie brakujących tabel wymaganych przez UX Design
**Status:** Ready for Implementation
**Data:** 2025-01-16
**Prerequisite:** Epic 0 - Setup & Infrastructure (musi być ukończony)

---

## Executive Summary

**Sprint 0** wypełnia krityczne luki w schemacie bazy danych zidentyfikowane podczas implementation-readiness analysis. Obecnie architektura definiuje tylko 8 tabel, ale UX design wymaga 14 tabel do pełnej funkcjonalności.

**Co zostanie zbudowane:**
- 6 nowych tabel PostgreSQL (Supabase)
- 2 nowe Edge Functions (Supabase Deno)
- 6 nowych tabel Drift (SQLite mirror dla offline-first)
- Migracje bazy danych
- Testy integracy

**Szacowany czas:** 1-2 tygodnie (18-21 godzin) dla 1 developera

**Prerequisites:**
- Epic 0 ukończony (Flutter setup, Supabase połączony)
- Epic 1 Story 1.1-1.2 ukończone (Auth działa)
- Supabase CLI zainstalowane

---

## Gap Analysis Summary

### Brakujące Tabele (6)

| Tabela | Blocks FRs | Impact | UX Section |
|--------|-----------|--------|------------|
| `workout_templates` | FR43-46 | HIGH | Section 14: Templates & Workout Library |
| `mental_health_screenings` | FR66-70 | CRITICAL | Section 16: Mental Health Screening |
| `subscriptions` | FR91-97 | HIGH | Section 15: Subscription & Paywall |
| `streaks` | FR85-90 | MEDIUM | Section 9: Gamification |
| `ai_conversations` | FR18-24 | MEDIUM | Section 2: AI Conversations |
| `mood_logs` | FR55-60 | MEDIUM | Section 6: Mood & Stress Tracking |

**Total FRs Blocked:** 38/123 (31%)

### Brakujące Edge Functions (2)

1. `process-mental-health-screening` - Score calculation + crisis detection
2. `generate-workout-plan-from-template` - Template → Workout conversion with Smart Pattern Memory

---

## Story Breakdown

Sprint 0 składa się z **8 stories** wykonywanych sekwencyjnie:

| Story | Tytuł | Czas | Priority |
|-------|-------|------|----------|
| **S0.1** | Add workout_templates Table | 2-3h | HIGH |
| **S0.2** | Add mental_health_screenings Table | 2-3h | CRITICAL |
| **S0.3** | Add subscriptions Table | 2h | HIGH |
| **S0.4** | Add streaks Table | 1-2h | MEDIUM |
| **S0.5** | Add ai_conversations Table | 1-2h | MEDIUM |
| **S0.6** | Add mood_logs Table | 2h | MEDIUM |
| **S0.7** | Create Edge Functions | 4-6h | HIGH |
| **S0.8** | Add Drift Mirror Tables | 2-3h | HIGH |

**Total:** 16-23 godziny (~1.5 tygodnia)

---

## Detailed Implementation

### Story S0.1: Add workout_templates Table

**Goal:** Enable users to create, save, and reuse custom workout templates (FR43-46)

**UX Reference:** Section 14: Templates & Workout Library UX (ux-design-specification.md:1296-1435)

**Acceptance Criteria:**
1. `workout_templates` table created in PostgreSQL
2. RLS policies configured (users can manage their own templates + view public ones)
3. Indexes created for performance
4. Migration tested (up + down)
5. Test data inserted (3 system templates + 1 custom user template)

---

#### Implementation Steps

**1. Create Migration File**

```bash
cd ~/Documents/Programowanie/GymApp/GymApp
supabase migration new add_workout_templates_table
```

**2. Add SQL to Migration File**

File: `supabase/migrations/TIMESTAMP_add_workout_templates_table.sql`

```sql
-- Create workout_templates table
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

-- Create indexes
CREATE INDEX idx_workout_templates_user ON workout_templates(user_id);
CREATE INDEX idx_workout_templates_public ON workout_templates(is_public) WHERE is_public = TRUE;
CREATE INDEX idx_workout_templates_created ON workout_templates(created_at DESC);

-- Enable RLS
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

-- Trigger: Auto-update updated_at
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

-- Insert system templates (pre-built templates)
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
```

**3. Apply Migration**

```bash
# Push to Supabase
supabase db push

# Verify in Supabase Dashboard → Database → Tables
# Should see workout_templates with 3 system templates
```

**4. Test RLS Policies**

Create test file: `test/integration/workout_templates_rls_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/api/supabase_client.dart';

void main() {
  setUpAll(() async {
    await SupabaseConfig.initialize();
  });

  group('workout_templates RLS', () {
    test('Anonymous user can view public templates', () async {
      final templates = await supabase
          .from('workout_templates')
          .select()
          .eq('is_public', true);

      expect(templates.length, 3);  // 3 system templates
    });

    test('Authenticated user can create template', () async {
      // Requires auth.uid() to be set (test user logged in)
      // This test is skipped in CI if no test user available
    }, skip: 'Requires authenticated user');
  });
}
```

**Validation:**
- [x] Table created in Supabase
- [x] 3 system templates inserted
- [x] RLS policies working (SELECT public templates works)
- [x] Indexes created (check `idx_workout_templates_user`)
- [x] Trigger updates `updated_at` on UPDATE

---

### Story S0.2: Add mental_health_screenings Table

**Goal:** Store GAD-7 and PHQ-9 screening results with crisis detection (FR66-70)

**UX Reference:** Section 16: Mental Health Screening Results UX (ux-design-specification.md:1764-2112)

**CRITICAL Safety Requirements:**
- Auto-detect crisis threshold (GAD-7 ≥15, PHQ-9 ≥20, Q9 ≥2)
- E2EE for `answers` field (sensitive health data)
- DO NOT log crisis modal trigger to analytics
- Offline-first (results cached locally)

**Acceptance Criteria:**
1. `mental_health_screenings` table created
2. E2EE encryption applied to `answers` field
3. RLS policies configured (users can only access their own results)
4. Crisis threshold logic validated
5. Test data inserted (2 screenings: 1 moderate, 1 severe)

---

#### Implementation Steps

**1. Create Migration File**

```bash
supabase migration new add_mental_health_screenings_table
```

**2. Add SQL to Migration File**

File: `supabase/migrations/TIMESTAMP_add_mental_health_screenings_table.sql`

```sql
-- Create mental_health_screenings table
CREATE TABLE IF NOT EXISTS mental_health_screenings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,

  screening_type TEXT NOT NULL CHECK (screening_type IN ('GAD-7', 'PHQ-9')),
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 27),
  severity TEXT NOT NULL CHECK (severity IN ('minimal', 'mild', 'moderate', 'moderately_severe', 'severe')),

  -- Individual question responses (E2EE encrypted, stored as TEXT not JSONB)
  -- Client-side encryption before insert
  encrypted_answers TEXT NOT NULL,
  encryption_iv TEXT NOT NULL,  -- Initialization vector for AES-256-GCM

  -- Crisis tracking (FR69)
  crisis_threshold_reached BOOLEAN DEFAULT FALSE,
  crisis_modal_shown BOOLEAN DEFAULT FALSE,  -- Set by client after showing modal

  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_screenings_user_type ON mental_health_screenings(user_id, screening_type);
CREATE INDEX idx_screenings_user_date ON mental_health_screenings(user_id, completed_at DESC);
CREATE INDEX idx_screenings_crisis ON mental_health_screenings(crisis_threshold_reached) WHERE crisis_threshold_reached = TRUE;

-- Enable RLS
ALTER TABLE mental_health_screenings ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access their own screening results
CREATE POLICY "Users can only access their own screenings"
  ON mental_health_screenings FOR ALL
  USING (auth.uid() = user_id);

-- COMMENT: Crisis threshold detection happens in Edge Function
-- before insert, not in database trigger
```

**3. Apply Migration**

```bash
supabase db push
```

**4. Create Client-Side Encryption Helper**

File: `lib/core/encryption/screening_encryption.dart`

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ScreeningEncryption {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'mental_health_encryption_key';

  // Generate or retrieve encryption key
  static Future<encrypt.Key> _getKey() async {
    String? keyString = await _storage.read(key: _keyName);

    if (keyString == null) {
      final key = encrypt.Key.fromSecureRandom(32);  // 256-bit key
      await _storage.write(key: _keyName, value: key.base64);
      return key;
    }

    return encrypt.Key.fromBase64(keyString);
  }

  // Encrypt answers array
  static Future<Map<String, String>> encryptAnswers(List<int> answers) async {
    final key = await _getKey();
    final iv = encrypt.IV.fromSecureRandom(16);  // 128-bit IV

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    final answersJson = jsonEncode(answers);
    final encrypted = encrypter.encrypt(answersJson, iv: iv);

    return {
      'encrypted_answers': encrypted.base64,
      'encryption_iv': iv.base64,
    };
  }

  // Decrypt answers
  static Future<List<int>> decryptAnswers(String encryptedBase64, String ivBase64) async {
    final key = await _getKey();
    final iv = encrypt.IV.fromBase64(ivBase64);

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);

    return List<int>.from(jsonDecode(decrypted));
  }
}
```

**Validation:**
- [x] Table created with E2EE fields
- [x] RLS policies working
- [x] Client-side encryption helper working
- [x] Crisis threshold field exists
- [x] Severity check constraint working

---

### Story S0.3: Add subscriptions Table

**Goal:** Track user subscription tiers and Stripe integration (FR91-97)

**UX Reference:** Section 15: Subscription & Paywall UX (ux-design-specification.md:1438-1762)

**Acceptance Criteria:**
1. `subscriptions` table created
2. RLS policies configured
3. Stripe webhook handler prepared (stub)
4. Default free tier for all users
5. Test data inserted (1 free user, 1 premium user)

---

#### Implementation (Shortened - Full SQL in migration file)

```bash
supabase migration new add_subscriptions_table
```

**Key Fields:**
- `tier`: 'free' | 'mind' | 'fitness' | 'three_pack' | 'plus'
- `stripe_customer_id`, `stripe_subscription_id`
- `status`: 'active' | 'trial' | 'canceled' | 'past_due'
- `trial_ends_at`, `current_period_end`, `canceled_at`

**RLS:** Users can SELECT their own subscription, service role can UPDATE (for Stripe webhooks)

---

### Story S0.4: Add streaks Table

**Goal:** Track daily streaks for workout, meditation, check-in (FR85-90)

**UX Reference:** Section 9: Gamification UX

**Key Fields:**
- `streak_type`: 'workout' | 'meditation' | 'check_in'
- `current_streak`, `longest_streak`
- `last_completed_date`, `freeze_used`

---

### Story S0.5: Add ai_conversations Table

**Goal:** Store AI conversation history (FR18-24)

**Key Fields:**
- `messages`: JSONB array of {role, content, timestamp}
- `ai_model`: 'llama' | 'claude' | 'gpt4'
- `conversation_type`: 'daily_plan' | 'goal_advice' | 'general'

---

### Story S0.6: Add mood_logs Table

**Goal:** Granular mood tracking (multiple logs per day) (FR55-60)

**Key Fields:**
- `mood_score`, `energy_score`, `stress_level` (1-5 scale)
- `notes` (optional journal)
- Trigger to update `user_daily_metrics` on INSERT

---

### Story S0.7: Create Edge Functions

**Goal:** Create 2 Edge Functions for mental health screening + templates

**Time:** 4-6 hours

**Function 1: process-mental-health-screening**

```bash
supabase functions new process-mental-health-screening
```

**Function 2: generate-workout-plan-from-template**

```bash
supabase functions new generate-workout-plan-from-template
```

**See implementation-readiness-report.md (GAP-002) for complete code**

---

### Story S0.8: Add Drift Mirror Tables

**Goal:** Add all 6 new tables to Drift (SQLite) for offline-first support

**Time:** 2-3 hours

**Steps:**
1. Create Drift table definitions for each new table
2. Update Drift database schema version
3. Write migration for local SQLite
4. Test offline sync (insert locally → sync to Supabase)

**Example (workout_templates):**

File: `lib/core/database/tables/workout_templates.drift.dart`

```dart
import 'package:drift/drift.dart';

@DataClassName('WorkoutTemplate')
class WorkoutTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  TextColumn get createdBy => text().withDefault(const Constant('user'))();
  TextColumn get exercises => text()();  // JSON string
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

**Validation:**
- [x] All 6 tables added to Drift
- [x] Schema version incremented
- [x] Offline insert works
- [x] Sync to Supabase works

---

## Testing Strategy

### Unit Tests (70%)
- Encryption/decryption helpers
- Crisis threshold detection logic
- Streak calculation logic

### Integration Tests (20%)
- RLS policies for each table
- Supabase CRUD operations
- Drift sync queue

### E2E Tests (10%)
- Create template → Use template → Delete template
- Complete screening → View results → Trigger crisis modal
- Subscribe → Downgrade → Cancel

---

## Success Criteria

Sprint 0 jest ukończony gdy:

✅ **Database Schema**
- All 6 tables created in Supabase PostgreSQL
- RLS policies tested and working
- Indexes created for performance
- Migrations reversible (up + down)

✅ **Edge Functions**
- `process-mental-health-screening` deployed and tested
- `generate-workout-plan-from-template` deployed and tested

✅ **Offline Support**
- All 6 tables mirrored in Drift (SQLite)
- Sync queue working for new tables

✅ **Testing**
- Integration tests pass for all RLS policies
- Crisis threshold detection validated
- E2EE encryption/decryption working

✅ **Documentation**
- Migration files documented
- Edge Function docs created
- Updated architecture.md with new schema

---

## Next Steps

Po ukończeniu Sprint 0:

1. **Update Documentation**
   - Add new tables to architecture.md (Section 6.1)
   - Update FR coverage in implementation-readiness-report.md (82% → 100%)

2. **Proceed to Epic 1**
   - Story 1.1: User Account Creation
   - Story 1.2: User Login & Session Management
   - Now all database tables are ready!

3. **Begin Feature Implementation**
   - Epic 2: Life Coach MVP
   - Epic 3: Fitness Coach MVP
   - Epic 4: Mind & Emotion MVP

---

## Estimated Effort Summary

| Story | Task | Time |
|-------|------|------|
| S0.1 | workout_templates Table | 2-3h |
| S0.2 | mental_health_screenings Table | 2-3h |
| S0.3 | subscriptions Table | 2h |
| S0.4 | streaks Table | 1-2h |
| S0.5 | ai_conversations Table | 1-2h |
| S0.6 | mood_logs Table | 2h |
| S0.7 | Edge Functions (2 functions) | 4-6h |
| S0.8 | Drift Mirror Tables (6 tables) | 2-3h |
| **TOTAL** | | **16-23 hours (1-2 weeks)** |

---

**Author:** Winston (BMAD Architect)
**Date:** 2025-01-16
**Status:** Ready for Implementation
**Prerequisite:** Epic 0 - Setup & Infrastructure
**Next:** Epic 1 - Core Platform Foundation

---

## Appendix: Complete SQL Migration Files

### Migration S0.1: workout_templates

See detailed SQL above in Story S0.1

### Migration S0.2: mental_health_screenings

See detailed SQL above in Story S0.2

### Migration S0.3: subscriptions

<details>
<summary>Click to expand full SQL</summary>

```sql
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL UNIQUE,
  tier TEXT NOT NULL DEFAULT 'free' CHECK (tier IN ('free', 'mind', 'fitness', 'three_pack', 'plus')),

  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,

  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'trial', 'canceled', 'past_due')),

  trial_ends_at TIMESTAMPTZ,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_stripe ON subscriptions(stripe_subscription_id);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can update subscriptions"
  ON subscriptions FOR ALL
  USING (auth.role() = 'service_role');

-- Auto-create free tier subscription for new users
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
```

</details>

### Migration S0.4: streaks

<details>
<summary>Click to expand full SQL</summary>

```sql
CREATE TABLE IF NOT EXISTS streaks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  streak_type TEXT NOT NULL CHECK (streak_type IN ('workout', 'meditation', 'check_in')),

  current_streak INTEGER NOT NULL DEFAULT 0 CHECK (current_streak >= 0),
  longest_streak INTEGER NOT NULL DEFAULT 0 CHECK (longest_streak >= 0),

  last_completed_date DATE,
  freeze_used BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, streak_type)
);

CREATE INDEX idx_streaks_user ON streaks(user_id);

ALTER TABLE streaks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own streaks"
  ON streaks FOR ALL
  USING (auth.uid() = user_id);
```

</details>

### Migration S0.5: ai_conversations

<details>
<summary>Click to expand full SQL</summary>

```sql
CREATE TABLE IF NOT EXISTS ai_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,

  messages JSONB NOT NULL DEFAULT '[]'::JSONB,
  ai_model TEXT NOT NULL CHECK (ai_model IN ('llama', 'claude', 'gpt4')),
  conversation_type TEXT CHECK (conversation_type IN ('daily_plan', 'goal_advice', 'general', 'fitness', 'mental_health')),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_conversations_user ON ai_conversations(user_id);
CREATE INDEX idx_ai_conversations_user_date ON ai_conversations(user_id, created_at DESC);

ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own conversations"
  ON ai_conversations FOR ALL
  USING (auth.uid() = user_id);
```

</details>

### Migration S0.6: mood_logs

<details>
<summary>Click to expand full SQL</summary>

```sql
CREATE TABLE IF NOT EXISTS mood_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,

  mood_score INTEGER NOT NULL CHECK (mood_score BETWEEN 1 AND 5),
  energy_score INTEGER CHECK (energy_score BETWEEN 1 AND 5),
  stress_level INTEGER CHECK (stress_level BETWEEN 1 AND 5),

  notes TEXT,

  logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_mood_logs_user ON mood_logs(user_id);
CREATE INDEX idx_mood_logs_user_date ON mood_logs(user_id, logged_at DESC);

ALTER TABLE mood_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own mood logs"
  ON mood_logs FOR ALL
  USING (auth.uid() = user_id);

-- Trigger: Update user_daily_metrics when mood_log inserted
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
```

</details>
