import 'package:lifeos/core/error/result.dart';
import '../exceptions/auth_exceptions.dart';
import '../repositories/auth_repository.dart';
import 'login_with_email_usecase.dart';

/// Request password reset use case
/// Sends password reset email to user
class RequestPasswordResetUseCase {
  final AuthRepository _repository;

  const RequestPasswordResetUseCase(this._repository);

  /// Request password reset for given email
  /// Sends email with reset link that expires in 1 hour
  Future<Result<void>> call(String email) async {
    try {
      // Validate email format
      if (!EmailValidator.isValid(email)) {
        return const Result.failure(
          InvalidEmailException(),
          'Please enter a valid email address',
        );
      }

      // Request password reset from repository
      return await _repository.requestPasswordReset(email);
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
        'Failed to send password reset email',
      );
    }
  }
}
