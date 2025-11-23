// Batch 3: Drift Tables for Tracking & CRUD Operations
// Stories: 2.3, 3.6, 3.7
// Generated: 2025-01-22

import 'package:drift/drift.dart';

// =============================================================================
// Table 1: Goals (for Goal Creation & Tracking)
// Story: 2.3
// =============================================================================

@DataClassName('Goal')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // 'fitness', 'career', 'health', etc.

  // Goal specifics
  DateTimeColumn get targetDate => dateTime().named('target_date').nullable()();
  RealColumn get targetValue => real().named('target_value').nullable()();
  TextColumn get unit => text().nullable()(); // 'kg', 'reps', 'days', etc.

  // Progress tracking
  RealColumn get currentValue => real().named('current_value').withDefault(const Constant(0.0))();
  IntColumn get completionPercentage => integer().named('completion_percentage').withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().named('is_completed').withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().named('completed_at').nullable()();

  // Metadata
  TextColumn get tags => text().nullable()(); // JSON array
  IntColumn get priority => integer().withDefault(const Constant(1))(); // 1-5
  BoolColumn get isArchived => boolean().named('is_archived').withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Table 2: GoalProgress (for Goal Progress Tracking)
// Story: 2.3
// =============================================================================

@DataClassName('GoalProgress')
class GoalProgressTable extends Table {
  @override
  String get tableName => 'goal_progress';

  TextColumn get id => text()();
  TextColumn get goalId => text().named('goal_id')();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get value => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get metadata => text().nullable()(); // JSON
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Table 3: BodyMeasurements (for Body Measurements Tracking)
// Story: 3.6
// =============================================================================

@DataClassName('BodyMeasurement')
class BodyMeasurements extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  DateTimeColumn get timestamp => dateTime()();

  // Measurements (all nullable)
  RealColumn get weight => real().nullable()();
  RealColumn get bodyFat => real().named('body_fat').nullable()();
  RealColumn get muscleMass => real().named('muscle_mass').nullable()();
  RealColumn get chest => real().nullable()();
  RealColumn get waist => real().nullable()();
  RealColumn get hips => real().nullable()();
  RealColumn get biceps => real().nullable()();
  RealColumn get thighs => real().nullable()();
  RealColumn get calves => real().nullable()();

  // Photo reference
  TextColumn get photoUrl => text().named('photo_url').nullable()();

  // Notes
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Note: WorkoutTemplates table already exists in sprint0_tables.dart
// We will reuse it for Story 3.7
