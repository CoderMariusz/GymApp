import 'package:drift/drift.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/features/mind_emotion/data/models/meditation_model.dart';

/// Local data source for meditation data (Drift/SQLite)
abstract class MeditationLocalDataSource {
  Future<List<MeditationModel>> getCachedMeditations();
  Future<void> cacheMeditations(List<MeditationModel> meditations);
  Future<void> clearCache();

  Future<void> addFavorite(String userId, String meditationId);
  Future<void> removeFavorite(String userId, String meditationId);
  Future<List<String>> getFavoriteIds(String userId);
  Future<bool> isFavorite(String userId, String meditationId);

  Future<void> addDownload({
    required String userId,
    required String meditationId,
    required String localFilePath,
  });
  Future<String?> getLocalFilePath(String meditationId);
  Future<void> removeDownload(String meditationId);

  Future<void> trackSession({
    required String userId,
    required String meditationId,
    required int durationListened,
    required bool completed,
  });
  Future<int> getCompletionCount(String userId, String meditationId);
}

class MeditationLocalDataSourceImpl implements MeditationLocalDataSource {
  final AppDatabase _database;

  MeditationLocalDataSourceImpl({required AppDatabase database})
      : _database = database;

  @override
  Future<List<MeditationModel>> getCachedMeditations() async {
    final cached = await _database.getAllCachedMeditations();
    return cached.map((cache) {
      return MeditationModel(
        id: cache.id,
        title: cache.title,
        description: cache.description,
        durationSeconds: cache.durationSeconds,
        category: cache.category,
        audioUrl: cache.audioUrl,
        thumbnailUrl: cache.thumbnailUrl,
        isPremium: cache.isPremium,
        createdAt: cache.createdAt.toIso8601String(),
      );
    }).toList();
  }

  @override
  Future<void> cacheMeditations(List<MeditationModel> meditations) async {
    for (final meditation in meditations) {
      await _database.cacheMeditation(
        MeditationCachesCompanion.insert(
          id: meditation.id,
          title: meditation.title,
          description: meditation.description,
          durationSeconds: meditation.durationSeconds,
          category: meditation.category,
          audioUrl: meditation.audioUrl,
          thumbnailUrl: meditation.thumbnailUrl,
          isPremium: meditation.isPremium,
          createdAt: DateTime.parse(meditation.createdAt),
          cachedAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> clearCache() => _database.clearCache();

  @override
  Future<void> addFavorite(String userId, String meditationId) {
    return _database.addFavorite(
      id: '${userId}_$meditationId',
      userId: userId,
      meditationId: meditationId,
    );
  }

  @override
  Future<void> removeFavorite(String userId, String meditationId) {
    return _database.removeFavorite(userId, meditationId);
  }

  @override
  Future<List<String>> getFavoriteIds(String userId) async {
    final favorites = await _database.getAllFavorites(userId);
    return favorites.map((f) => f.meditationId).toList();
  }

  @override
  Future<bool> isFavorite(String userId, String meditationId) {
    return _database.isFavorite(userId, meditationId);
  }

  @override
  Future<void> addDownload({
    required String userId,
    required String meditationId,
    required String localFilePath,
  }) {
    return _database.addDownload(
      id: '${userId}_$meditationId',
      userId: userId,
      meditationId: meditationId,
      localFilePath: localFilePath,
    );
  }

  @override
  Future<String?> getLocalFilePath(String meditationId) async {
    final download = await _database.getDownload(meditationId);
    return download?.localFilePath;
  }

  @override
  Future<void> removeDownload(String meditationId) {
    return _database.removeDownload(meditationId);
  }

  @override
  Future<void> trackSession({
    required String userId,
    required String meditationId,
    required int durationListened,
    required bool completed,
  }) {
    return _database.addSession(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      meditationId: meditationId,
      durationListenedSeconds: durationListened,
      completed: completed,
      completedAt: completed ? DateTime.now() : null,
    );
  }

  @override
  Future<int> getCompletionCount(String userId, String meditationId) {
    return _database.getCompletionCount(userId, meditationId);
  }
}
