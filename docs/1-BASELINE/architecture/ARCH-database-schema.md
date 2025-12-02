# Database Schema - Architecture

<!-- AI-INDEX: database, schema, postgresql, drift, sqlite, rls, tables, migrations, offline-first -->

**Wersja:** 2.0
**Backend:** Supabase (PostgreSQL) + Drift (SQLite)

---

## Spis Treści

1. [Overview](#1-overview)
2. [Core Tables](#2-core-tables)
3. [Module Tables](#3-module-tables)
4. [Row Level Security (RLS)](#4-row-level-security-rls)
5. [Drift Mirror](#5-drift-mirror)
6. [Sync Strategy](#6-sync-strategy)
7. [Migrations](#7-migrations)

---

## 1. Overview

### Database Strategy

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Cloud** | PostgreSQL (Supabase) | Primary store, sync, RLS |
| **Local** | SQLite (Drift) | Offline-first, instant UI |
| **Sync** | Custom Queue | Background sync |

### Key Principles

1. **Offline-First:** Drift writes first, sync to Supabase
2. **RLS Everywhere:** Row-level security for multi-tenancy
3. **Shared Schema:** `user_daily_metrics` for Cross-Module Intelligence
4. **E2EE Fields:** Encrypted blobs for sensitive data

---

## 2. Core Tables

### users (Supabase Auth built-in)

```sql
id UUID PRIMARY KEY
email TEXT UNIQUE
created_at TIMESTAMPTZ
```

### user_daily_metrics (Cross-Module Intelligence - SHARED)

**Purpose:** Aggregated metrics from all modules for pattern detection.

```sql
CREATE TABLE user_daily_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  date DATE NOT NULL,

  -- Fitness metrics
  workout_completed BOOLEAN DEFAULT FALSE,
  workout_duration_minutes INTEGER DEFAULT 0,
  calories_burned INTEGER DEFAULT 0,
  sets_completed INTEGER DEFAULT 0,
  workout_intensity DECIMAL(3,2),  -- 0.0-1.0

  -- Mind metrics
  meditation_completed BOOLEAN DEFAULT FALSE,
  meditation_duration_minutes INTEGER DEFAULT 0,
  mood_score INTEGER,              -- 1-10 (nullable)
  stress_level INTEGER,            -- 1-10 (nullable)
  journal_entries_count INTEGER DEFAULT 0,

  -- Life Coach metrics
  daily_plan_generated BOOLEAN DEFAULT FALSE,
  tasks_completed INTEGER DEFAULT 0,
  tasks_total INTEGER DEFAULT 0,
  completion_rate DECIMAL(3,2),    -- 0.0-1.0
  ai_conversations_count INTEGER DEFAULT 0,

  aggregated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, date)
);
```

### detected_patterns (Cross-Module Intelligence)

**Purpose:** Store detected correlations and AI-generated insights.

```sql
CREATE TABLE detected_patterns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  pattern_type TEXT NOT NULL,  -- 'correlation', 'trend', 'anomaly'

  metric_a TEXT NOT NULL,      -- e.g., 'workout_completed'
  metric_b TEXT NOT NULL,      -- e.g., 'stress_level'
  correlation_coefficient DECIMAL(4,3),  -- -1.0 to 1.0
  confidence_score DECIMAL(3,2),         -- 0.0-1.0

  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  sample_size INTEGER NOT NULL,

  insight_text TEXT,           -- AI-generated
  recommendation_text TEXT,    -- AI-generated

  viewed_at TIMESTAMPTZ,
  dismissed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, metric_a, metric_b, end_date)
);
```

### subscriptions

```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  tier TEXT NOT NULL,          -- 'free', 'single', 'pack', 'plus'
  modules TEXT[] DEFAULT '{}', -- ['fitness'], ['fitness', 'mind']
  stripe_subscription_id TEXT,
  started_at TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id)
);
```

### streaks

```sql
CREATE TABLE streaks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  streak_type TEXT NOT NULL,   -- 'workout', 'meditation', 'check_in'
  current_count INTEGER DEFAULT 0,
  longest_count INTEGER DEFAULT 0,
  last_activity_date DATE,
  freeze_used_this_week BOOLEAN DEFAULT FALSE,
  freeze_used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, streak_type)
);
```

---

## 3. Module Tables

### Fitness Module

**workouts**
```sql
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  duration_minutes INTEGER,
  calories_burned INTEGER,
  notes TEXT,
  template_id UUID,
  synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**workout_exercises**
```sql
CREATE TABLE workout_exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_id UUID REFERENCES exercises(id),
  order_index INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**workout_sets**
```sql
CREATE TABLE workout_sets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_exercise_id UUID REFERENCES workout_exercises(id) ON DELETE CASCADE,
  set_number INTEGER NOT NULL,
  reps INTEGER,
  weight DECIMAL(6,2),
  rpe INTEGER,           -- 1-10 rate of perceived exertion
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**exercises** (Library)
```sql
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  muscle_group TEXT NOT NULL,
  secondary_muscles TEXT[],
  equipment TEXT,
  difficulty TEXT,       -- 'beginner', 'intermediate', 'advanced'
  instructions TEXT,
  video_url TEXT,
  is_custom BOOLEAN DEFAULT FALSE,
  user_id UUID,          -- NULL for system exercises
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**exercise_favorites**
```sql
CREATE TABLE exercise_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, exercise_id)
);
```

**workout_templates**
```sql
CREATE TABLE workout_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID,          -- NULL for system templates
  name TEXT NOT NULL,
  description TEXT,
  exercises_json JSONB NOT NULL,  -- [{ exercise_id, sets, reps, weight }]
  is_preset BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**body_measurements**
```sql
CREATE TABLE body_measurements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  date DATE NOT NULL,
  weight DECIMAL(5,2),
  weight_unit TEXT DEFAULT 'kg',
  body_fat_percent DECIMAL(4,2),
  chest DECIMAL(5,2),
  waist DECIMAL(5,2),
  hips DECIMAL(5,2),
  arms DECIMAL(5,2),
  legs DECIMAL(5,2),
  photos_json JSONB,     -- [{ url, type: 'front'|'side'|'back' }]
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Life Coach Module

**daily_plans**
```sql
CREATE TABLE daily_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  date DATE NOT NULL,
  tasks JSONB NOT NULL,  -- [{ id, title, completed, priority, category }]
  generated_by TEXT,     -- 'llama', 'claude', 'gpt4'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, date)
);
```

**goals**
```sql
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,         -- 'fitness', 'mental_health', 'career', etc.
  target_value INTEGER,
  current_value INTEGER DEFAULT 0,
  target_date DATE,
  completed_at TIMESTAMPTZ,
  archived_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**goal_progress**
```sql
CREATE TABLE goal_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
  value INTEGER NOT NULL,
  note TEXT,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**check_ins**
```sql
CREATE TABLE check_ins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  type TEXT NOT NULL,    -- 'morning', 'evening'
  mood INTEGER,          -- 1-5
  energy INTEGER,        -- 1-5
  sleep_quality INTEGER, -- 1-5
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**ai_conversations**
```sql
CREATE TABLE ai_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  messages JSONB NOT NULL,  -- [{ role, content, timestamp }]
  model TEXT NOT NULL,      -- 'llama', 'claude', 'gpt4'
  context_type TEXT,        -- 'daily_plan', 'goal', 'general'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Mind Module

**meditation_sessions**
```sql
CREATE TABLE meditation_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  meditation_id UUID,
  duration_minutes INTEGER NOT NULL,
  completed BOOLEAN DEFAULT TRUE,
  completed_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**meditation_favorites**
```sql
CREATE TABLE meditation_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  meditation_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, meditation_id)
);
```

**meditation_downloads**
```sql
CREATE TABLE meditation_downloads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  meditation_id UUID NOT NULL,
  file_path TEXT NOT NULL,
  file_size INTEGER,
  downloaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**mood_logs**
```sql
CREATE TABLE mood_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  mood INTEGER NOT NULL,     -- 1-5
  stress INTEGER,            -- 1-5
  triggers TEXT[],           -- ['work', 'relationships', etc.]
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**journal_entries** (E2EE)
```sql
CREATE TABLE journal_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  encrypted_content TEXT NOT NULL,  -- AES-256-GCM blob
  encryption_iv TEXT NOT NULL,      -- Initialization vector
  mood_at_time INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**mental_health_screenings**
```sql
CREATE TABLE mental_health_screenings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  type TEXT NOT NULL,        -- 'gad7', 'phq9'
  score INTEGER NOT NULL,
  answers JSONB NOT NULL,    -- [{ question_id, answer }]
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 4. Row Level Security (RLS)

### Enable RLS on All Tables

```sql
ALTER TABLE user_daily_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE detected_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE body_measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE meditation_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE mood_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
```

### User Data Isolation Policy

```sql
-- Standard policy: Users can only access their own data
CREATE POLICY "Users can only access their own data"
  ON user_daily_metrics FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only access their own workouts"
  ON workouts FOR ALL
  USING (auth.uid() = user_id);

-- Apply to all user-owned tables
```

### Subscription-Based Access

```sql
-- Premium features locked by subscription
CREATE POLICY "Premium meditation access"
  ON meditation_sessions FOR SELECT
  USING (
    auth.uid() = user_id AND
    (
      SELECT tier FROM subscriptions
      WHERE user_id = auth.uid()
    ) IN ('single', 'pack', 'plus')
  );
```

### Public Read for System Data

```sql
-- Exercises library is public (read)
CREATE POLICY "Exercises are public"
  ON exercises FOR SELECT
  USING (is_custom = FALSE OR user_id = auth.uid());

-- Workout templates: public presets + user's custom
CREATE POLICY "Templates access"
  ON workout_templates FOR SELECT
  USING (is_preset = TRUE OR user_id = auth.uid());
```

---

## 5. Drift Mirror

### Drift Tables (Local SQLite)

**Structure identical to PostgreSQL** for seamless sync.

```dart
// lib/core/database/tables.dart

class WorkoutsTable extends Table {
  UuidColumn get id => uuid()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  IntColumn get caloriesBurned => integer().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
```

### Sync Status Tracking

```dart
class SyncQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableName => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // 'insert', 'update', 'delete'
  TextColumn get data => text()();      // JSON payload
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}
```

---

## 6. Sync Strategy

### Write Flow

```
1. User action (e.g., log workout)
   ↓
2. Save to Drift (local) → Instant UI update
   ↓
3. Add to SyncQueue (priority based on data type)
   ↓
4. SyncService detects WiFi/connection
   ↓
5. Process queue: Send to Supabase
   ↓
6. Mark as synced in Drift
```

### Priority Levels

| Priority | Data Type | Sync Urgency |
|----------|-----------|--------------|
| 0 (Highest) | Auth changes, payments | Immediate |
| 1 | Workouts, check-ins | Next available |
| 2 | Mood logs, favorites | Background |
| 3 | Analytics events | Low priority |

### Conflict Resolution

```dart
// Last-write-wins based on updated_at timestamp
Future<void> resolveConflict(
  LocalRecord local,
  RemoteRecord remote,
) async {
  if (remote.updatedAt.isAfter(local.updatedAt)) {
    // Remote wins - update local
    await localDb.update(remote);
  } else {
    // Local wins - push to remote
    await remoteDb.upsert(local);
  }
}
```

---

## 7. Migrations

### Migration Files Location

```
supabase/migrations/
├── 001_initial_schema.sql                    # Core tables
├── 002_add_exercise_favorites.sql
├── 003_seed_exercises.sql                    # 500+ exercises
├── 004_fix_security_definer.sql
├── 20250117000001_workout_templates.sql
├── 20250117000002_mental_health_screenings.sql
├── 20250117000003_subscriptions.sql
├── 20250117000004_streaks.sql
├── 20250117000005_ai_conversations.sql
├── 20250117000006_mood_logs.sql
├── 20250122_enable_realtime_sync.sql
├── 20250122_gdpr_storage_and_soft_delete.sql
├── 20251122_create_meditation_tables.sql
└── 20251122_seed_meditation_data.sql
```

### Running Migrations

```bash
# Apply all pending migrations
supabase db push

# Create new migration
supabase migration new <migration_name>

# Reset database (dev only)
supabase db reset
```

---

## Powiązane Dokumenty

- [ARCH-overview.md](./ARCH-overview.md) - Architecture overview
- [ARCH-security.md](./ARCH-security.md) - E2EE, GDPR details
- [PRD-nfr.md](../product/PRD-nfr.md) - NFR requirements

---

*20+ Tables | RLS Enabled | Offline-First with Drift*
