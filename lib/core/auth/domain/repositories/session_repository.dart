import '../../../utils/result.dart';
import '../entities/auth_session_entity.dart';

/// Session repository interface
/// Defines the contract for session persistence operations
abstract class SessionRepository {
  /// Save session to secure storage
  Future<Result<void>> saveSession(AuthSessionEntity session);

  /// Load session from secure storage
  /// Returns null if no session exists or if session is invalid
  Future<Result<AuthSessionEntity?>> loadSession();

  /// Delete session from secure storage
  Future<Result<void>> deleteSession();

  /// Save remember me preference
  Future<Result<void>> saveRememberMePreference(bool rememberMe);

  /// Load remember me preference (defaults to true)
  Future<Result<bool>> loadRememberMePreference();

  /// Clear all stored data
  Future<Result<void>> clearAll();
}
