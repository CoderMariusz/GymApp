import '../../../utils/result.dart';
import '../entities/auth_session_entity.dart';
import '../exceptions/auth_exceptions.dart';
import '../repositories/session_repository.dart';

/// Check auth status use case
/// Checks if a valid session exists for auto-login
class CheckAuthStatusUseCase {
  final SessionRepository _sessionRepository;

  const CheckAuthStatusUseCase(this._sessionRepository);

  /// Check if valid session exists
  /// Returns null if no session or session is expired
  /// Used by AppInitializer for auto-login logic
  Future<Result<AuthSessionEntity?>> call() async {
    try {
      // Load session from secure storage
      final sessionResult = await _sessionRepository.loadSession();

      // Check if load failed
      if (sessionResult is Failure) {
        return const Success(null);
      }

      final session = (sessionResult as Success<AuthSessionEntity?>).data;

      // Return null if no session exists
      if (session == null) {
        return const Success(null);
      }

      // Check if session is expired
      if (session.isExpired) {
        // Clear expired session
        await _sessionRepository.deleteSession();
        return const Failure(
          SessionExpiredException(),
          'Your session has expired. Please sign in again.',
        );
      }

      // Session is valid
      return Success(session);
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'Failed to check auth status',
      );
    }
  }
}
