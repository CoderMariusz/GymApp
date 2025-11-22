import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/exceptions/auth_exceptions.dart';

/// User profile data source
/// Handles user profile updates in Supabase
class UserProfileDataSource {
  final SupabaseClient _client;

  const UserProfileDataSource(this._client);

  /// Update user profile in database
  /// Updates user_profiles table
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['full_name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      // Update user_profiles table
      await _client.from('user_profiles').update(updates).eq('user_id', userId);

      // Fetch updated user
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const UnknownAuthException('User not authenticated');
      }

      // Fetch profile data
      final profileData = await _getUserProfile(userId);

      return UserModel.fromSupabase(
        user: user,
        profileData: profileData,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Update user email
  /// Triggers re-verification email
  Future<UserModel> updateEmail(String newEmail) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      final user = _client.auth.currentUser;
      if (user == null) {
        throw const UnknownAuthException('User not authenticated');
      }

      final profileData = await _getUserProfile(user.id);

      return UserModel.fromSupabase(
        user: user,
        profileData: profileData,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Change password
  /// Requires re-authentication with current password first
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Re-authenticate with current password
      final user = _client.auth.currentUser;
      if (user == null || user.email == null) {
        throw const UnknownAuthException('User not authenticated');
      }

      await _client.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      // Update password
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Get user profile from database
  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Handle Supabase auth exceptions
  Exception _handleAuthException(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid') && message.contains('password')) {
      return const InvalidCredentialsException();
    }

    if (message.contains('email') && message.contains('already')) {
      return const EmailAlreadyExistsException();
    }

    return UnknownAuthException(e.message);
  }
}
