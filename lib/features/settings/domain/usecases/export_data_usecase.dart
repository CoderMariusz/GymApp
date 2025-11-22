import 'package:lifeos/features/settings/domain/repositories/settings_repository.dart';

/// Use case for requesting user data export (GDPR Article 20)
class ExportDataUseCase {
  final SettingsRepository _repository;

  ExportDataUseCase(this._repository);

  /// Request data export
  /// Returns the request ID for tracking
  /// Throws exception if rate limited (max 1 export per hour)
  Future<String> call() async {
    return await _repository.requestDataExport();
  }

  /// Check export status
  /// Returns download URL when ready, null if still processing
  Future<String?> checkStatus(String requestId) async {
    return await _repository.getExportStatus(requestId);
  }
}
