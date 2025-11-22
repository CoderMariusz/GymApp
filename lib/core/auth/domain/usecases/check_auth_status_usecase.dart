import 'package:lifeos/core/error/result.dart';
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
        return const Result.success(null);
      }

      final session = (sessionResult as Success<AuthSessionEntity?>).data;

      // Return null if no session exists
      if (session == null) {
        return const Result.success(null);
      }

      // Check if session is expired
      if (session.isExpired) {
        // Clear expired session
        await _sessionRepository.deleteSession();
        return const Result.failure(
        SessionExpiredException(),
      );
      }

      // Session is valid
      return Result.success(session);
    } on AuthException catch (e) {
      return Result.failure(
        e);
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
      );
    }
  }
}
