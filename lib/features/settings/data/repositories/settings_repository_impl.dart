import 'package:lifeos/features/settings/domain/repositories/settings_repository.dart';
import 'package:lifeos/features/settings/data/datasources/supabase_settings_datasource.dart';

/// Implementation of SettingsRepository using Supabase
class SettingsRepositoryImpl implements SettingsRepository {
  final SupabaseSettingsDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<String> requestDataExport() async {
    try {
      return await _datasource.requestDataExport();
    } catch (e) {
      throw Exception('Failed to request data export: $e');
    }
  }

  @override
  Future<String?> getExportStatus(String requestId) async {
    try {
      final data = await _datasource.getExportStatus(requestId);
      if (data == null) return null;

      final status = data['status'] as String;
      if (status == 'completed') {
        return data['download_url'] as String?;
      }

      return null; // Still processing
    } catch (e) {
      throw Exception('Failed to get export status: $e');
    }
  }

  @override
  Future<String> requestAccountDeletion(String password) async {
    try {
      return await _datasource.requestAccountDeletion(password);
    } catch (e) {
      throw Exception('Failed to request account deletion: $e');
    }
  }

  @override
  Future<void> cancelAccountDeletion() async {
    try {
      await _datasource.cancelAccountDeletion();
    } catch (e) {
      throw Exception('Failed to cancel account deletion: $e');
    }
  }

  @override
  Future<bool> hasPendingDeletion() async {
    try {
      return await _datasource.hasPendingDeletion();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DateTime?> getDeletionScheduledDate() async {
    try {
      return await _datasource.getDeletionScheduledDate();
    } catch (e) {
      return null;
    }
  }
}
