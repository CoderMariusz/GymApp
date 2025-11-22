import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage data source
/// Wrapper around flutter_secure_storage for session and preference storage
class SecureStorageDataSource {
  final FlutterSecureStorage _storage;

  const SecureStorageDataSource(this._storage);

  // Storage keys
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyExpiresAt = 'auth_expires_at';
  static const String _keyUserData = 'auth_user_data';
  static const String _keyRememberMe = 'auth_remember_me';

  /// Save session data to secure storage
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _keyAccessToken, value: accessToken),
        _storage.write(key: _keyRefreshToken, value: refreshToken),
        _storage.write(key: _keyExpiresAt, value: expiresAt.toIso8601String()),
        _storage.write(key: _keyUserData, value: jsonEncode(userData)),
      ]);
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  /// Load session data from secure storage
  /// Returns null if session doesn't exist or is invalid
  Future<Map<String, dynamic>?> loadSession() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _keyAccessToken),
        _storage.read(key: _keyRefreshToken),
        _storage.read(key: _keyExpiresAt),
        _storage.read(key: _keyUserData),
      ]);

      final accessToken = results[0];
      final refreshToken = results[1];
      final expiresAtStr = results[2];
      final userDataStr = results[3];

      // If any required field is missing, session is invalid
      if (accessToken == null ||
          refreshToken == null ||
          expiresAtStr == null ||
          userDataStr == null) {
        return null;
      }

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': DateTime.parse(expiresAtStr),
        'userData': jsonDecode(userDataStr),
      };
    } catch (e) {
      // If parsing fails, session is invalid
      return null;
    }
  }

  /// Delete all session data
  Future<void> deleteSession() async {
    try {
      await Future.wait([
        _storage.delete(key: _keyAccessToken),
        _storage.delete(key: _keyRefreshToken),
        _storage.delete(key: _keyExpiresAt),
        _storage.delete(key: _keyUserData),
      ]);
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  /// Save remember me preference
  Future<void> saveRememberMePreference(bool rememberMe) async {
    try {
      await _storage.write(
        key: _keyRememberMe,
        value: rememberMe.toString(),
      );
    } catch (e) {
      throw Exception('Failed to save remember me preference: $e');
    }
  }

  /// Load remember me preference (defaults to true)
  Future<bool> loadRememberMePreference() async {
    try {
      final value = await _storage.read(key: _keyRememberMe);
      if (value == null) return true; // Default to true
      return value.toLowerCase() == 'true';
    } catch (e) {
      return true; // Default to true on error
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }
}
