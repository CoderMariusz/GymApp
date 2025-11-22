import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/exceptions/auth_exceptions.dart';
import '../../../auth/domain/usecases/login_with_email_usecase.dart';
import 'package:lifeos/core/error/result.dart';
import '../entities/profile_update_request.dart';
import '../repositories/profile_repository.dart';

/// Update profile use case
/// Updates user profile information (name, email)
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  const UpdateProfileUseCase(this._repository);

  /// Update user profile
  /// Validates email if provided
  /// Email update triggers re-verification
  Future<Result<UserEntity>> call(ProfileUpdateRequest request) async {
    try {
      // Validate email if being updated
      if (request.email != null && !EmailValidator.isValid(request.email!)) {
        return const Result.failure(
        InvalidEmailException(),
      );
      }

      // Check if request has any changes
      if (!request.hasChanges) {
        return const Result.failure(
        UnknownAuthException('No changes to save'),
      );
      }

      // Update profile via repository
      return await _repository.updateProfile(request);
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
