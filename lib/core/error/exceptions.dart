/// Base exception for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Exception thrown when there's no internet connection
class NetworkException extends AppException {
  NetworkException([String? message])
      : super(message ?? 'No internet connection', code: 'NETWORK_ERROR');
}

/// Exception thrown when sync conflict occurs
class SyncConflictException extends AppException {
  SyncConflictException([String? message])
      : super(message ?? 'Data conflict during synchronization',
            code: 'SYNC_CONFLICT');
}

/// Exception thrown when subscription is required
class SubscriptionRequiredException extends AppException {
  final String feature;

  SubscriptionRequiredException(this.feature)
      : super('Premium subscription required to access $feature',
            code: 'SUBSCRIPTION_REQUIRED');
}

/// Exception thrown when tier check fails
class TierRestrictionException extends AppException {
  final String tier;
  final String requiredTier;

  TierRestrictionException({
    required this.tier,
    required this.requiredTier,
  }) : super(
            'Feature requires $requiredTier tier, but user has $tier tier',
            code: 'TIER_RESTRICTION');
}

/// Exception thrown when database operation fails
class DatabaseException extends AppException {
  DatabaseException([String? message])
      : super(message ?? 'Database operation failed', code: 'DATABASE_ERROR');
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  final int? statusCode;

  ServerException([String? message, this.statusCode])
      : super(message ?? 'Server error occurred', code: 'SERVER_ERROR');
}

/// Exception thrown when download fails
class DownloadException extends AppException {
  DownloadException([String? message])
      : super(message ?? 'Download failed', code: 'DOWNLOAD_ERROR');
}

/// Exception thrown when audio playback fails
class AudioException extends AppException {
  AudioException([String? message])
      : super(message ?? 'Audio playback error', code: 'AUDIO_ERROR');
}
