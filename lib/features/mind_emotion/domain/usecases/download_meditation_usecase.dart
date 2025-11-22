import 'package:lifeos/core/error/exceptions.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/domain/repositories/meditation_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// User subscription tier
enum UserTier {
  free,
  premium,
}

/// Use case for downloading meditation audio for offline use
class DownloadMeditationUseCase {
  final MeditationRepository _repository;
  final UserTier Function() _getUserTier;

  DownloadMeditationUseCase({
    required MeditationRepository repository,
    required UserTier Function() getUserTier,
  })  : _repository = repository,
        _getUserTier = getUserTier;

  /// Download meditation for offline use
  ///
  /// Checks user tier before downloading
  /// Returns stream of download progress
  /// Premium feature only for free users
  Stream<DownloadProgress> call({
    required String meditationId,
    required MeditationEntity meditation,
  }) async* {
    try {
      // Check if user has premium tier
      final userTier = _getUserTier();
      if (userTier == UserTier.free) {
        throw TierRestrictionException(
          tier: 'free',
          requiredTier: 'premium',
        );
      }

      // Check if already downloaded
      final isDownloaded = await _repository.isDownloaded(meditationId);
      if (isDownloaded) {
        yield DownloadProgress(
          bytesReceived: 100,
          totalBytes: 100,
          percentage: 100.0,
          status: DownloadStatus.completed,
        );
        return;
      }

      // Get download directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final meditationDir = Directory('${appDocDir.path}/meditations');
      if (!await meditationDir.exists()) {
        await meditationDir.create(recursive: true);
      }

      // Create local file path
      final localPath = '${meditationDir.path}/$meditationId.mp3';

      // Download with progress tracking
      await for (final progress
          in _repository.downloadAudio(meditation.audioUrl, localPath)) {
        yield progress;
      }
    } on TierRestrictionException {
      rethrow;
    } catch (e) {
      throw DownloadException('Failed to download meditation: $e');
    }
  }
}
