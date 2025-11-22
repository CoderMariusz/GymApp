import '../../../utils/result.dart';
import '../entities/auth_session_entity.dart';
import '../exceptions/auth_exceptions.dart';
import '../repositories/auth_repository.dart';
import '../repositories/session_repository.dart';

/// Login with email use case
/// Handles email/password authentication with session management
class LoginWithEmailUseCase {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  const LoginWithEmailUseCase(
    this._authRepository,
    this._sessionRepository,
  );

  /// Login with email and password
  /// Creates session and stores it if rememberMe is true
  Future<Result<AuthSessionEntity>> call({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      // Validate email format
      if (!EmailValidator.isValid(email)) {
        return const Failure(
          InvalidEmailException(),
          'Please enter a valid email address',
        );
      }

      // Login through auth repository
      // This will return an AuthSessionEntity from Supabase
      final loginResult = await _authRepository.loginWithEmail(
        email: email,
        password: password,
      );

      // Check if login failed
      if (loginResult is Failure) {
        return loginResult as Failure<AuthSessionEntity>;
      }

      final session = (loginResult as Success<AuthSessionEntity>).data;

      // Check if email is verified
      if (!session.user.emailVerified) {
        return const Failure(
          EmailNotVerifiedException(),
          'Please verify your email before logging in',
        );
      }

      // Save session if remember me is true
      if (rememberMe) {
        await _sessionRepository.saveSession(session);
        await _sessionRepository.saveRememberMePreference(true);
      } else {
        await _sessionRepository.saveRememberMePreference(false);
      }

      return Success(session);
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred during login',
      );
    }
  }
}

/// Simple email validator
class EmailValidator {
  static bool isValid(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }
}
