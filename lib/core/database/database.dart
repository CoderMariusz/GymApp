import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:lifeos/core/database/tables.drift.dart';

part 'database.g.dart';

/// Local database for offline-first functionality
@DriftDatabase(
  tables: [
    MeditationFavorites,
    MeditationDownloads,
    MeditationSessions,
    MeditationCaches,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
        completed: completed,
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
}
