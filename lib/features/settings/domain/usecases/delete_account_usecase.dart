import 'package:lifeos/features/settings/domain/repositories/settings_repository.dart';

/// Use case for requesting account deletion (GDPR Article 17)
class DeleteAccountUseCase {
  final SettingsRepository _repository;

  DeleteAccountUseCase(this._repository);

  /// Request account deletion with password confirmation
  /// Returns the deletion request ID
  /// Account will be deleted after 7-day grace period
  /// Throws exception if password is incorrect
  Future<String> call(String password) async {
    if (password.isEmpty) {
      throw Exception('Password is required for account deletion');
    }

    return await _repository.requestAccountDeletion(password);
  }

  /// Check if account has a pending deletion request
  Future<bool> hasPendingDeletion() async {
    return await _repository.hasPendingDeletion();
  }

  /// Get the scheduled deletion date (7 days from request)
  Future<DateTime?> getScheduledDeletionDate() async {
    return await _repository.getDeletionScheduledDate();
  }
}
