import 'package:lifeos/features/settings/domain/repositories/settings_repository.dart';

/// Use case for canceling account deletion within grace period
class CancelDeletionUseCase {
  final SettingsRepository _repository;

  CancelDeletionUseCase(this._repository);

  /// Cancel pending account deletion
  /// Only works within 7-day grace period
  /// Throws exception if no pending deletion or grace period expired
  Future<void> call() async {
    final hasPending = await _repository.hasPendingDeletion();
    if (!hasPending) {
      throw Exception('No pending deletion request found');
    }

    await _repository.cancelAccountDeletion();
  }
}
