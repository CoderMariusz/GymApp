import '../../../auth/domain/exceptions/auth_exceptions.dart';
import '../../../auth/domain/validators/password_validator.dart';
import '../../../utils/result.dart';
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
        return const Failure(
          InvalidCredentialsException(),
          'Current password is required',
        );
      }

      // Validate new password
      final validation = PasswordValidator.validate(newPassword);
      if (!validation.isValid) {
        return Failure(
          const WeakPasswordException(),
          validation.errors.join('\n'),
        );
      }

      // Check passwords are different
      if (currentPassword == newPassword) {
        return const Failure(
          WeakPasswordException(),
          'New password must be different from current password',
        );
      }

      // Change password via repository
      return await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'Failed to change password',
      );
    }
  }
}
