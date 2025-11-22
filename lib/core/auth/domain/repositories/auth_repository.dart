import 'package:lifeos/core/error/result.dart';
import '../entities/auth_session_entity.dart';
import '../entities/user_entity.dart';

/// Authentication repository interface
/// Defines the contract for authentication operations
abstract class AuthRepository {
  /// Register a new user with email and password
  Future<Result<UserEntity>> registerWithEmail({
    required String email,
    required String password,
    String? name,
  });

  /// Register a new user with Google OAuth
  Future<Result<UserEntity>> registerWithGoogle();

  /// Register a new user with Apple Sign-In
  Future<Result<UserEntity>> registerWithApple();

  /// Login with email and password
  /// Returns AuthSessionEntity with tokens and user data
  Future<Result<AuthSessionEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Login with Google OAuth
  /// Returns AuthSessionEntity with tokens and user data
  Future<Result<AuthSessionEntity>> loginWithGoogle();

  /// Login with Apple Sign-In
  /// Returns AuthSessionEntity with tokens and user data
  Future<Result<AuthSessionEntity>> loginWithApple();

  /// Get current session from Supabase
  /// Returns null if no active session
  Future<Result<AuthSessionEntity?>> getCurrentSession();

  /// Send email verification
  Future<Result<void>> sendEmailVerification(String email);

  /// Verify email with token
  Future<Result<void>> verifyEmail(String token);

  /// Get current authenticated user
  Future<Result<UserEntity?>> getCurrentUser();

  /// Sign out
  Future<Result<void>> signOut();

  /// Request password reset - sends email with reset link
  Future<Result<void>> requestPasswordReset(String email);

  /// Update password - called after user clicks reset link
  /// User must be authenticated via reset token
  Future<Result<void>> updatePassword(String newPassword);

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
}
