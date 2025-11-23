// Life Coach Feature Tables
// Tables for AI-powered life coaching features (Epic 2)
// Generated: 2025-01-23

import 'package:drift/drift.dart';

// =============================================================================
// Table: DailyPlans (AI-generated daily plans)
// =============================================================================

@DataClassName('DailyPlanData')
class DailyPlans extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get tasksJson => text().named('tasks_json')();  // JSON array of tasks
  TextColumn get dailyTheme => text().named('daily_theme')();
  TextColumn get motivationalQuote => text().named('motivational_quote').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  IntColumn get source => integer()();  // 0: ai_generated, 1: manual
  TextColumn get metadataJson => text().named('metadata_json').nullable()();  // AI model info, tokens, cost

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
