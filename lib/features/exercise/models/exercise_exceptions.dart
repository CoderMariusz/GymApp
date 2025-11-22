// Story 3.2: Exercise Library - Custom Exception Types
// Better error handling and user feedback

/// Base exception for exercise-related errors
class ExerciseException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const ExerciseException(this.message, [this.stackTrace]);

  @override
  String toString() => 'ExerciseException: $message';
}

/// Network-related errors (should retry)
class NetworkException extends ExerciseException {
  const NetworkException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);

  @override
  String toString() => 'NetworkException: $message';
}

/// Authentication-related errors (should re-login)
class AuthenticationException extends ExerciseException {
  const AuthenticationException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Validation errors (show to user)
class ValidationException extends ExerciseException {
  const ValidationException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);

  @override
  String toString() => 'ValidationException: $message';
}

/// Server/Database errors (contact support)
class ServerException extends ExerciseException {
  const ServerException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);

  @override
  String toString() => 'ServerException: $message';
}

/// Not found errors
class NotFoundException extends ExerciseException {
  const NotFoundException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);

  @override
  String toString() => 'NotFoundException: $message';
}
