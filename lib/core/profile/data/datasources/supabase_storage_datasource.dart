import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase storage data source
/// Handles file uploads to Supabase Storage
class SupabaseStorageDataSource {
  final SupabaseClient _client;

  // Storage bucket name for avatars
  static const String _avatarsBucket = 'avatars';

  const SupabaseStorageDataSource(this._client);

  /// Upload avatar to Supabase Storage
  /// Returns public URL of uploaded file
  /// File is stored at: avatars/{userId}/avatar.jpg
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final path = '$userId/avatar.jpg';

      // Upload file (overwrites if exists)
      await _client.storage.from(_avatarsBucket).upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Get public URL
      final publicUrl = _client.storage.from(_avatarsBucket).getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Delete avatar from storage
  Future<void> deleteAvatar(String userId) async {
    try {
      final path = '$userId/avatar.jpg';
      await _client.storage.from(_avatarsBucket).remove([path]);
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }
}
