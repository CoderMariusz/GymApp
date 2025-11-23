import 'package:lifeos/core/error/result.dart';
import '../exceptions/auth_exceptions.dart';
import '../repositories/auth_repository.dart';
import '../validators/password_validator.dart';

/// Update password use case
/// Updates user password after clicking reset link
class UpdatePasswordUseCase {
  final AuthRepository _repository;

  const UpdatePasswordUseCase(this._repository);

  /// Update user password
  /// User must be authenticated via reset token
  /// Password must meet security requirements
  Future<Result<void>> call(String newPassword) async {
    try {
      // Validate password
      final validation = PasswordValidator.validate(newPassword);
      if (!validation.isValid) {
        return const Result.failure(
          WeakPasswordException(),
        );
      }

      // Update password via repository
      return await _repository.updatePassword(newPassword);
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
      );
    }
  }
}
