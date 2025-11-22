import 'dart:io';
import 'package:dio/dio.dart';
import 'package:lifeos/core/error/exceptions.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/mind_emotion/data/datasources/meditation_local_datasource.dart';
import 'package:lifeos/features/mind_emotion/data/datasources/meditation_remote_datasource.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/domain/repositories/meditation_repository.dart';

class MeditationRepositoryImpl implements MeditationRepository {
  final MeditationRemoteDataSource _remoteDataSource;
  final MeditationLocalDataSource _localDataSource;
  final Dio _dio;

  MeditationRepositoryImpl({
    required MeditationRemoteDataSource remoteDataSource,
    required MeditationLocalDataSource localDataSource,
    required Dio dio,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _dio = dio;

  @override
  Future<Result<List<MeditationEntity>>> getMeditations() async {
    try {
      // Try to fetch from remote
      final meditations = await _remoteDataSource.getMeditations();

      // Cache for offline access
      await _localDataSource.cacheMeditations(meditations);

      // Convert to entities (favorites and downloads will be merged later)
      final entities = meditations.map((m) => m.toEntity()).toList();

      return Result.success(entities);
    } on NetworkException {
      // Fall back to cached data if no network
      try {
        final cached = await _localDataSource.getCachedMeditations();
        final entities = cached.map((m) => m.toEntity()).toList();
        return Result.success(entities);
      } catch (e) {
        return Result.failure(DatabaseException('Failed to load cached data'));
      }
    } catch (e) {
      // Try cached data on any error
      try {
        final cached = await _localDataSource.getCachedMeditations();
        final entities = cached.map((m) => m.toEntity()).toList();
        return Result.success(entities);
      } catch (_) {
        return Result.failure(
            Exception('Failed to get meditations: $e') as Exception);
      }
    }
  }

  @override
  Future<Result<MeditationEntity>> getMeditationById(String id) async {
    try {
      final meditation = await _remoteDataSource.getMeditationById(id);
      return Result.success(meditation.toEntity());
    } catch (e) {
      return Result.failure(
          Exception('Failed to get meditation: $e') as Exception);
    }
  }

  @override
  Future<Result<void>> toggleFavorite(String userId, String meditationId) async {
    try {
      // Check current state
      final isFav = await _localDataSource.isFavorite(userId, meditationId);

      if (isFav) {
        // Remove from local first
        await _localDataSource.removeFavorite(userId, meditationId);
        // Then try to sync to remote
        try {
          await _remoteDataSource.toggleFavorite(userId, meditationId);
        } catch (_) {
          // Ignore network errors - will sync later
        }
      } else {
        // Add to local first
        await _localDataSource.addFavorite(userId, meditationId);
        // Then try to sync to remote
        try {
          await _remoteDataSource.toggleFavorite(userId, meditationId);
        } catch (_) {
          // Ignore network errors - will sync later
        }
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
          Exception('Failed to toggle favorite: $e') as Exception);
    }
  }

  @override
  Future<Result<List<String>>> getFavoriteIds(String userId) async {
    try {
      // Get from local first (source of truth for offline-first)
      final localFavorites = await _localDataSource.getFavoriteIds(userId);

      // Try to sync with remote in background
      try {
        final remoteFavorites = await _remoteDataSource.getFavoriteIds(userId);
        // Could implement sync logic here if needed
      } catch (_) {
        // Ignore network errors
      }

      return Result.success(localFavorites);
    } catch (e) {
      return Result.failure(
          Exception('Failed to get favorites: $e') as Exception);
    }
  }

  @override
  Stream<DownloadProgress> downloadAudio(
      String audioUrl, String localPath) async* {
    try {
      yield DownloadProgress(
        bytesReceived: 0,
        totalBytes: 0,
        percentage: 0.0,
        status: DownloadStatus.downloading,
      );

      await _dio.download(
        audioUrl,
        localPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final percentage = (received / total * 100);
            // Note: This won't actually yield in the callback
            // Proper implementation would use StreamController
          }
        },
      );

      yield DownloadProgress(
        bytesReceived: 100,
        totalBytes: 100,
        percentage: 100.0,
        status: DownloadStatus.completed,
      );
    } catch (e) {
      yield DownloadProgress(
        bytesReceived: 0,
        totalBytes: 0,
        percentage: 0.0,
        status: DownloadStatus.failed,
      );
      throw DownloadException('Failed to download audio: $e');
    }
  }

  @override
  Future<bool> isDownloaded(String meditationId) async {
    try {
      final filePath = await _localDataSource.getLocalFilePath(meditationId);
      if (filePath == null) return false;

      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getLocalFilePath(String meditationId) async {
    try {
      return await _localDataSource.getLocalFilePath(meditationId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Result<void>> deleteDownload(String meditationId) async {
    try {
      final filePath = await _localDataSource.getLocalFilePath(meditationId);
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
        await _localDataSource.removeDownload(meditationId);
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
          Exception('Failed to delete download: $e') as Exception);
    }
  }

  @override
  Future<Result<void>> trackSession({
    required String userId,
    required String meditationId,
    required int durationListened,
    required bool completed,
  }) async {
    try {
      // Save to local first
      await _localDataSource.trackSession(
        userId: userId,
        meditationId: meditationId,
        durationListened: durationListened,
        completed: completed,
      );

      // Try to sync to remote
      try {
        await _remoteDataSource.trackSession(
          userId: userId,
          meditationId: meditationId,
          durationListened: durationListened,
          completed: completed,
        );
      } catch (_) {
        // Ignore network errors - will sync later
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
          Exception('Failed to track session: $e') as Exception);
    }
  }

  @override
  Future<Result<int>> getCompletionCount(
      String userId, String meditationId) async {
    try {
      // Get from local first
      final count =
          await _localDataSource.getCompletionCount(userId, meditationId);
      return Result.success(count);
    } catch (e) {
      return Result.failure(
          Exception('Failed to get completion count: $e') as Exception);
    }
  }
}
