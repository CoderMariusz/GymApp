// Sprint 0: Drift Mirror Tables for Offline-First Support
// These tables mirror the PostgreSQL tables in Supabase for offline functionality
// Generated: 2025-01-17

import 'package:drift/drift.dart';

// =============================================================================
// Table 1: WorkoutTemplates (mirrors workout_templates)
// =============================================================================

@DataClassName('WorkoutTemplate')
class WorkoutTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isPublic => boolean().named('is_public').withDefault(const Constant(false))();
  TextColumn get createdBy => text().named('created_by').withDefault(const Constant('user'))();
  TextColumn get exercises => text()(); // JSON string of exercises array
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Table 2: MentalHealthScreenings (mirrors mental_health_screenings)
// =============================================================================

@DataClassName('MentalHealthScreening')
class MentalHealthScreenings extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get screeningType => text().named('screening_type')(); // 'GAD-7' | 'PHQ-9'
  IntColumn get score => integer()();
  TextColumn get severity => text()(); // 'minimal' | 'mild' | 'moderate' | 'moderately_severe' | 'severe'
  TextColumn get encryptedAnswers => text().named('encrypted_answers')();
  TextColumn get encryptionIv => text().named('encryption_iv')();
  BoolColumn get crisisThresholdReached => boolean().named('crisis_threshold_reached').withDefault(const Constant(false))();
  BoolColumn get crisisModalShown => boolean().named('crisis_modal_shown').withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().named('completed_at').withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Table 3: Subscriptions (mirrors subscriptions)
// =============================================================================

@DataClassName('Subscription')
class Subscriptions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get tier => text().withDefault(const Constant('free'))(); // 'free' | 'mind' | 'fitness' | 'three_pack' | 'plus'
  TextColumn get stripeCustomerId => text().named('stripe_customer_id').nullable()();
  TextColumn get stripeSubscriptionId => text().named('stripe_subscription_id').nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active' | 'trial' | 'canceled' | 'past_due'
  DateTimeColumn get trialEndsAt => dateTime().named('trial_ends_at').nullable()();
  DateTimeColumn get currentPeriodStart => dateTime().named('current_period_start').nullable()();
  DateTimeColumn get currentPeriodEnd => dateTime().named('current_period_end').nullable()();
  DateTimeColumn get canceledAt => dateTime().named('canceled_at').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Table 4: Streaks (mirrors streaks)
// =============================================================================

@DataClassName('Streak')
class Streaks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get streakType => text().named('streak_type')(); // 'workout' | 'meditation' | 'check_in'
  IntColumn get currentStreak => integer().named('current_streak').withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().named('longest_streak').withDefault(const Constant(0))();
  DateTimeColumn get lastCompletedDate => dateTime().named('last_completed_date').nullable()();
  BoolColumn get freezeUsed => boolean().named('freeze_used').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{userId, streakType}];
}

// =============================================================================
// Table 5: AiConversations (mirrors ai_conversations)
// =============================================================================

@DataClassName('AiConversation')
class AiConversations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get messages => text()(); // JSON string of messages array
  TextColumn get aiModel => text().named('ai_model')(); // 'llama' | 'claude' | 'gpt4'
  TextColumn get conversationType => text().named('conversation_type').nullable()(); // 'daily_plan' | 'goal_advice' | 'general' | 'fitness' | 'mental_health'
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Table 6: MoodLogs (mirrors mood_logs)
// =============================================================================

@DataClassName('MoodLog')
class MoodLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  IntColumn get moodScore => integer().named('mood_score')(); // 1-5
  IntColumn get energyScore => integer().named('energy_score').nullable()(); // 1-5
  IntColumn get stressLevel => integer().named('stress_level').nullable()(); // 1-5
  TextColumn get notes => text().nullable()();
  DateTimeColumn get loggedAt => dateTime().named('logged_at').withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Table 7: UserDailyMetrics (mirrors user_daily_metrics)
// =============================================================================

@DataClassName('UserDailyMetric')
class UserDailyMetrics extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  DateTimeColumn get date => dateTime()();

  // Fitness metrics
  BoolColumn get workoutCompleted => boolean().named('workout_completed').withDefault(const Constant(false))();
  IntColumn get workoutDurationMinutes => integer().named('workout_duration_minutes').withDefault(const Constant(0))();
  IntColumn get caloriesBurned => integer().named('calories_burned').withDefault(const Constant(0))();
  IntColumn get setsCompleted => integer().named('sets_completed').withDefault(const Constant(0))();
  RealColumn get workoutIntensity => real().named('workout_intensity').nullable()();

  // Mind metrics
  BoolColumn get meditationCompleted => boolean().named('meditation_completed').withDefault(const Constant(false))();
  IntColumn get meditationDurationMinutes => integer().named('meditation_duration_minutes').withDefault(const Constant(0))();
  IntColumn get moodScore => integer().named('mood_score').nullable()();
  IntColumn get stressLevel => integer().named('stress_level').nullable()();
  IntColumn get journalEntriesCount => integer().named('journal_entries_count').withDefault(const Constant(0))();

  // Life Coach metrics
  BoolColumn get dailyPlanGenerated => boolean().named('daily_plan_generated').withDefault(const Constant(false))();
  IntColumn get tasksCompleted => integer().named('tasks_completed').withDefault(const Constant(0))();
  IntColumn get tasksTotal => integer().named('tasks_total').withDefault(const Constant(0))();
  RealColumn get completionRate => real().named('completion_rate').nullable()();
  IntColumn get aiConversationsCount => integer().named('ai_conversations_count').withDefault(const Constant(0))();

  DateTimeColumn get aggregatedAt => dateTime().named('aggregated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{userId, date}];
}
