import 'package:lifeos/core/error/result.dart';
import '../entities/auth_session_entity.dart';
import '../exceptions/auth_exceptions.dart';
import '../repositories/auth_repository.dart';
import '../repositories/session_repository.dart';

/// Login with Google OAuth use case
/// Handles Google authentication with session management
class LoginWithGoogleUseCase {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  const LoginWithGoogleUseCase(
    this._authRepository,
    this._sessionRepository,
  );

  /// Login with Google OAuth
  /// Always saves session (OAuth users expect to stay logged in)
  Future<Result<AuthSessionEntity>> call() async {
    try {
      // Login through auth repository (handles OAuth flow)
      final loginResult = await _authRepository.loginWithGoogle();

      // Check if login failed
      if (loginResult is Failure) {
        return loginResult as Failure<AuthSessionEntity>;
      }

      final session = (loginResult as Success<AuthSessionEntity>).data;

      // Always save session for OAuth (users expect to stay logged in)
      await _sessionRepository.saveSession(session);
      await _sessionRepository.saveRememberMePreference(true);

      return Result.success(session);
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred during Google sign-in',
      );
    }
  }
}
