// Batch 1: Drift Tables for Forms & Input Flows
// Stories: 2.1, 2.5, 3.3, 3.8
// Generated: 2025-01-22

import 'package:drift/drift.dart';

// =============================================================================
// Table 1: CheckIns (for Morning Check-In & Evening Reflection)
// Stories: 2.1, 2.5
// =============================================================================

@DataClassName('CheckIn')
class CheckIns extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get type => text()(); // 'morning' | 'evening'

  // Morning Check-In fields
  IntColumn get energyLevel => integer().named('energy_level').nullable()(); // 1-10
  IntColumn get mood => integer().nullable()(); // 1-10
  TextColumn get intentions => text().nullable()();
  TextColumn get gratitude => text().nullable()();

  // Evening Reflection fields
  IntColumn get productivityRating => integer().named('productivity_rating').nullable()(); // 1-10
  TextColumn get wins => text().nullable()();
  TextColumn get improvements => text().nullable()();
  TextColumn get tomorrowFocus => text().named('tomorrow_focus').nullable()();

  // Common fields
  TextColumn get tags => text().nullable()(); // JSON array of strings
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Table 2: WorkoutLogs (for Workout Logging & Quick Log)
// Stories: 3.3, 3.8
// =============================================================================

@DataClassName('WorkoutLog')
class WorkoutLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get workoutName => text().named('workout_name')();
  IntColumn get duration => integer()(); // seconds
  TextColumn get notes => text().nullable()();
  BoolColumn get isQuickLog => boolean().named('is_quick_log').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Table 3: ExerciseSets (for Workout Logging)
// Story: 3.3
// =============================================================================

@DataClassName('ExerciseSet')
class ExerciseSets extends Table {
  TextColumn get id => text()();
  TextColumn get workoutLogId => text().named('workout_log_id')();
  TextColumn get exerciseName => text().named('exercise_name')();
  IntColumn get setNumber => integer().named('set_number')();
  RealColumn get weight => real().nullable()(); // kg or lbs
  IntColumn get reps => integer().nullable()();
  IntColumn get duration => integer().nullable()(); // seconds, for timed exercises
  IntColumn get restTime => integer().named('rest_time').nullable()(); // seconds
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
