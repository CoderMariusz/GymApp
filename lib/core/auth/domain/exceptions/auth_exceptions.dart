/// Base authentication exception
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Email already exists exception
class EmailAlreadyExistsException extends AuthException {
  const EmailAlreadyExistsException()
      : super(
          'This email is already registered. Try logging in?',
          code: 'email-already-exists',
        );
}

/// Weak password exception
class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super(
          'Password must be 8+ chars with uppercase, number, special char',
          code: 'weak-password',
        );
}

/// Invalid email exception
class InvalidEmailException extends AuthException {
  const InvalidEmailException()
      : super(
          'Please enter a valid email address',
          code: 'invalid-email',
        );
}

/// Network error exception
class NetworkException extends AuthException {
  const NetworkException()
      : super(
          'Connection failed. Please try again.',
          code: 'network-error',
        );
}

/// User not found exception
class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super(
          'User not found',
          code: 'user-not-found',
        );
}

/// Invalid credentials exception
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super(
          'Invalid email or password',
          code: 'invalid-credentials',
        );
}

/// OAuth cancelled exception
class OAuthCancelledException extends AuthException {
  const OAuthCancelledException()
      : super(
          'Sign in cancelled',
          code: 'oauth-cancelled',
        );
}

/// OAuth failed exception
class OAuthFailedException extends AuthException {
  const OAuthFailedException()
      : super(
          'Sign in failed. Please try again.',
          code: 'oauth-failed',
        );
}

/// Session expired exception
class SessionExpiredException extends AuthException {
  const SessionExpiredException()
      : super(
          'Your session has expired. Please sign in again.',
          code: 'session-expired',
        );
}

/// Unknown exception
class UnknownAuthException extends AuthException {
  const UnknownAuthException([String? message])
      : super(
          message ?? 'An unexpected error occurred',
          code: 'unknown',
        );
}
