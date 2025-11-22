/// Repository interface for GDPR compliance operations
abstract class SettingsRepository {
  /// Request data export for the current user
  /// Returns the request ID for tracking
  Future<String> requestDataExport();

  /// Check the status of a data export request
  /// Returns the download URL when ready, null if still processing
  Future<String?> getExportStatus(String requestId);

  /// Request account deletion with password confirmation
  /// Returns the deletion request ID
  Future<String> requestAccountDeletion(String password);

  /// Cancel a pending account deletion within the grace period
  Future<void> cancelAccountDeletion();

  /// Check if account has a pending deletion request
  Future<bool> hasPendingDeletion();

  /// Get the deletion scheduled date (7 days from request)
  Future<DateTime?> getDeletionScheduledDate();
}
