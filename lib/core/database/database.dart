import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:lifeos/core/database/tables.drift.dart';
import 'package:lifeos/core/database/tables/sprint0_tables.dart';
import 'package:lifeos/core/database/tables/batch1_tables.dart';
import 'package:lifeos/core/database/tables/batch3_tables.dart';
import 'package:lifeos/core/database/tables/life_coach_tables.dart';

part 'database.g.dart';

/// Local database for offline-first functionality
@DriftDatabase(
  tables: [
    // Meditation tables
    MeditationFavorites,
    MeditationDownloads,
    MeditationSessions,
    MeditationCaches,
    // Sprint 0 tables
    WorkoutTemplates,
    MentalHealthScreenings,
    Subscriptions,
    Streaks,
    AiConversations,
    MoodLogs,
    UserDailyMetrics,
    // Batch 1 tables
    CheckIns,
    WorkoutLogs,
    ExerciseSets,
    // Batch 3 tables
    Goals,
    GoalProgressTable,
    BodyMeasurements,
    // Life Coach tables (Epic 2)
    DailyPlans,
    ChatSessions,
    // Sync infrastructure
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;  // Incremented for DailyPlans + ChatSessions tables

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Migration from v1 to v2 - add batch1 tables
        await m.createTable(checkIns);
        await m.createTable(workoutLogs);
        await m.createTable(exerciseSets);
      }
      if (from < 3) {
        // Migration from v2 to v3 - add batch3 tables
        await m.createTable(goals);
        await m.createTable(goalProgressTable);
        await m.createTable(bodyMeasurements);
      }
      if (from < 4) {
        // Migration from v3 to v4
        // Currently no schema changes, just version bump for consistency
      }
    },
  );

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Migration from v1 to v2 - add batch1 tables
        await m.createTable(checkIns);
        await m.createTable(workoutLogs);
        await m.createTable(exerciseSets);
      }
      if (from < 3) {
        // Migration from v2 to v3 - add batch3 tables
        await m.createTable(goals);
        await m.createTable(goalProgressTable);
        await m.createTable(bodyMeasurements);
      }
      if (from < 4) {
        // Migration from v3 to v4
        // Currently no schema changes, just version bump for consistency
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'lifeos_db');
  }

  // Meditation Favorites operations
  Future<List<MeditationFavorite>> getAllFavorites(String userId) {
    return (select(meditationFavorites)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Future<void> addFavorite({
    required String id,
    required String userId,
    required String meditationId,
  }) {
    return into(meditationFavorites).insert(
      MeditationFavoritesCompanion.insert(
        id: id,
        userId: userId,
        meditationId: meditationId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> removeFavorite(String userId, String meditationId) {
    return (delete(meditationFavorites)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.meditationId.equals(meditationId)))
        .go();
  }

  Future<bool> isFavorite(String userId, String meditationId) async {
    final result = await (select(meditationFavorites)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.meditationId.equals(meditationId)))
        .get();
    return result.isNotEmpty;
  }

  // Meditation Downloads operations
  Future<void> addDownload({
    required String id,
    required String userId,
    required String meditationId,
    required String localFilePath,
  }) {
    return into(meditationDownloads).insert(
      MeditationDownloadsCompanion.insert(
        id: id,
        userId: userId,
        meditationId: meditationId,
        localFilePath: localFilePath,
        downloadedAt: DateTime.now(),
      ),
    );
  }

  Future<MeditationDownload?> getDownload(String meditationId) {
    return (select(meditationDownloads)
          ..where((tbl) => tbl.meditationId.equals(meditationId)))
        .getSingleOrNull();
  }

  Future<void> removeDownload(String meditationId) {
    return (delete(meditationDownloads)
          ..where((tbl) => tbl.meditationId.equals(meditationId)))
        .go();
  }

  // Meditation Sessions operations
  Future<void> addSession({
    required String id,
    required String userId,
    required String meditationId,
    required int durationListenedSeconds,
    required bool completed,
    DateTime? completedAt,
  }) {
    return into(meditationSessions).insert(
      MeditationSessionsCompanion.insert(
        id: id,
        userId: userId,
        meditationId: meditationId,
        durationListenedSeconds: durationListenedSeconds,
        completed: Value(completed),
        completedAt: Value(completedAt),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<int> getCompletionCount(String userId, String meditationId) async {
    final result = await (select(meditationSessions)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.meditationId.equals(meditationId) &
              tbl.completed.equals(true)))
        .get();
    return result.length;
  }

  // Meditation Cache operations
  Future<void> cacheMeditation(MeditationCachesCompanion meditation) {
    return into(meditationCaches).insert(
      meditation,
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<MeditationCache>> getAllCachedMeditations() {
    return select(meditationCaches).get();
  }

  Future<void> clearCache() {
    return delete(meditationCaches).go();
  }

  // Sync Queue operations
  Future<void> enqueueSyncOperation({
    required String id,
    required String tableName,
    required String recordId,
    required String operation,
    required String payload,
  }) {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        id: id,
        tableName: tableName,
        recordId: recordId,
        operation: operation,
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<SyncQueueItem>> getPendingSyncItems() {
    return (select(syncQueue)..where((tbl) => tbl.isPending.equals(true)))
        .get();
  }

  Future<void> markSyncItemCompleted(String id) {
    return (update(syncQueue)..where((tbl) => tbl.id.equals(id)))
        .write(const SyncQueueCompanion(isPending: Value(false)));
  }

  Future<void> updateSyncItemRetry(String id, String errorMessage) {
    return (update(syncQueue)..where((tbl) => tbl.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: Value((select(syncQueue)
                  ..where((tbl) => tbl.id.equals(id)))
                .getSingle()
                .then((item) => item.retryCount + 1)
            as int),
        lastAttemptAt: Value(DateTime.now()),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  Future<void> clearCompletedSyncItems() {
    return (delete(syncQueue)..where((tbl) => tbl.isPending.equals(false)))
        .go();
  }
}
