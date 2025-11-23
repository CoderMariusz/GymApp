import '../../../auth/domain/exceptions/auth_exceptions.dart';
import '../../../auth/domain/validators/password_validator.dart';
import 'package:lifeos/core/error/result.dart';
import '../repositories/profile_repository.dart';

/// Change password use case
/// Handles password change with current password verification
class ChangePasswordUseCase {
  final ProfileRepository _repository;

  const ChangePasswordUseCase(this._repository);

  /// Change user password
  /// Requires current password for security
  /// New password must meet validation requirements
  Future<Result<void>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Validate current password is not empty
      if (currentPassword.isEmpty) {
        return const Result.failure(
          InvalidCredentialsException(),
        );
      }

      // Validate new password
      final validation = PasswordValidator.validate(newPassword);
      if (!validation.isValid) {
        return const Result.failure(
          WeakPasswordException(),
        );
      }

      // Check passwords are different
      if (currentPassword == newPassword) {
        return const Result.failure(
          WeakPasswordException(),
        );
      }

      // Change password via repository
      return await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
      );
    }
  }
}
