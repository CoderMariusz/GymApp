import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for GDPR operations via Supabase
class SupabaseSettingsDatasource {
  final SupabaseClient _client;

  SupabaseSettingsDatasource(this._client);

  /// Request data export via Edge Function
  Future<String> requestDataExport() async {
    final response = await _client.functions.invoke(
      'export-user-data',
      method: HttpMethod.post,
    );

    if (response.status != 200) {
      throw Exception('Failed to request data export: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    return data['request_id'] as String;
  }

  /// Get export status
  Future<Map<String, dynamic>?> getExportStatus(String requestId) async {
    final response = await _client
        .from('data_export_requests')
        .select('status, download_url, expires_at')
        .eq('id', requestId)
        .eq('user_id', _client.auth.currentUser!.id)
        .single();

    return response;
  }

  /// Request account deletion via Edge Function
  Future<String> requestAccountDeletion(String password) async {
    final response = await _client.functions.invoke(
      'delete-account',
      method: HttpMethod.post,
      body: {'password': password},
    );

    if (response.status != 200) {
      final error = response.data as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'Failed to request account deletion');
    }

    final data = response.data as Map<String, dynamic>;
    return data['request_id'] as String;
  }

  /// Cancel account deletion
  Future<void> cancelAccountDeletion() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Mark deletion request as cancelled
    await _client
        .from('account_deletion_requests')
        .update({'status': 'cancelled'})
        .eq('user_id', userId)
        .eq('status', 'pending');

    // Clear deletion timestamp from user profile
    await _client
        .from('user_profiles')
        .update({'deletion_requested_at': null})
        .eq('id', userId);
  }

  /// Check if account has pending deletion
  Future<bool> hasPendingDeletion() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _client
        .from('account_deletion_requests')
        .select('id')
        .eq('user_id', userId)
        .eq('status', 'pending')
        .maybeSingle();

    return response != null;
  }

  /// Get deletion scheduled date
  Future<DateTime?> getDeletionScheduledDate() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('account_deletion_requests')
        .select('scheduled_deletion_at')
        .eq('user_id', userId)
        .eq('status', 'pending')
        .maybeSingle();

    if (response == null) return null;

    final timestamp = response['scheduled_deletion_at'];
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
}
