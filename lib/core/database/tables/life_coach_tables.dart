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

// =============================================================================
// Table: ChatSessions (AI coaching chat sessions)
// =============================================================================

@DataClassName('ChatSessionData')
class ChatSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get title => text()();
  TextColumn get messagesJson => text().named('messages_json')();  // JSON array of messages
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get lastMessageAt => dateTime().named('last_message_at').nullable()();
  BoolColumn get isArchived => boolean().named('is_archived').withDefault(const Constant(false))();

  // Sync metadata
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
