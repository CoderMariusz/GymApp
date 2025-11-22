import 'package:lifeos/core/error/result.dart';
import '../entities/user_entity.dart';
import '../exceptions/auth_exceptions.dart';
import '../repositories/auth_repository.dart';
import '../validators/password_validator.dart';

/// Register user use case
/// Handles user registration with email/password and social auth
class RegisterUserUseCase {
  final AuthRepository _repository;

  const RegisterUserUseCase(this._repository);

  /// Register with email and password
  Future<Result<UserEntity>> callWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      // Validate email
      if (!EmailValidator.isValid(email)) {
        return const Result.failure(
          InvalidEmailException(),
        );
      }

      // Validate password
      final passwordValidation = PasswordValidator.validate(password);
      if (!passwordValidation.isValid) {
        return const Result.failure(
          WeakPasswordException(),
        );
      }

      // Call repository to register
      return await _repository.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  /// Register with Google OAuth
  Future<Result<UserEntity>> callWithGoogle() async {
    try {
      return await _repository.registerWithGoogle();
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  /// Register with Apple Sign-In
  Future<Result<UserEntity>> callWithApple() async {
    try {
      return await _repository.registerWithApple();
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }
}
