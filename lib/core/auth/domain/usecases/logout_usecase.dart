import 'package:lifeos/core/error/result.dart';
import '../exceptions/auth_exceptions.dart';
import '../repositories/auth_repository.dart';
import '../repositories/session_repository.dart';

/// Logout use case
/// Handles user logout and session cleanup
class LogoutUseCase {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  const LogoutUseCase(
    this._authRepository,
    this._sessionRepository,
  );

  /// Logout user
  /// Clears Supabase session and local storage
  Future<Result<void>> call() async {
    try {
      // Sign out from Supabase
      final signOutResult = await _authRepository.signOut();

      // Clear local session storage
      await _sessionRepository.deleteSession();

      // Return result from auth repository
      return signOutResult;
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
