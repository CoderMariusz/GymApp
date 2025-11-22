import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';

/// Download progress information
class DownloadProgress {
  final int bytesReceived;
  final int totalBytes;
  final double percentage;
  final DownloadStatus status;

  DownloadProgress({
    required this.bytesReceived,
    required this.totalBytes,
    required this.percentage,
    required this.status,
  });

  DownloadProgress copyWith({
    int? bytesReceived,
    int? totalBytes,
    double? percentage,
    DownloadStatus? status,
  }) {
    return DownloadProgress(
      bytesReceived: bytesReceived ?? this.bytesReceived,
      totalBytes: totalBytes ?? this.totalBytes,
      percentage: percentage ?? this.percentage,
      status: status ?? this.status,
    );
  }
}

enum DownloadStatus {
  idle,
  downloading,
  completed,
  failed,
  cancelled,
}

/// Abstract repository for meditation operations
abstract class MeditationRepository {
  /// Get all meditations from the backend
  Future<Result<List<MeditationEntity>>> getMeditations();

  /// Get a single meditation by ID
  Future<Result<MeditationEntity>> getMeditationById(String id);

  /// Toggle favorite status for a meditation
  Future<Result<void>> toggleFavorite(String userId, String meditationId);

  /// Get list of favorited meditation IDs for a user
  Future<Result<List<String>>> getFavoriteIds(String userId);

  /// Download meditation audio file
  Stream<DownloadProgress> downloadAudio(String audioUrl, String localPath);

  /// Check if meditation is downloaded locally
  Future<bool> isDownloaded(String meditationId);

  /// Get local file path for downloaded meditation
  Future<String?> getLocalFilePath(String meditationId);

  /// Delete downloaded meditation
  Future<Result<void>> deleteDownload(String meditationId);

  /// Track meditation session
  Future<Result<void>> trackSession({
    required String userId,
    required String meditationId,
    required int durationListened,
    required bool completed,
  });

  /// Get completion count for a meditation
  Future<Result<int>> getCompletionCount(String userId, String meditationId);
}
