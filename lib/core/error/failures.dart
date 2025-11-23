/// Base failure class for error handling
abstract class Failure implements Exception {
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

/// Database operation failures
class DatabaseFailure extends Failure {
  DatabaseFailure(String message) : super('Database Error: $message');
}

/// Validation failures
class ValidationFailure extends Failure {
  ValidationFailure(String message) : super('Validation Error: $message');
}

/// Network operation failures
class NetworkFailure extends Failure {
  NetworkFailure(String message) : super('Network Error: $message');
}

/// Not found failures
class NotFoundException extends Failure {
  NotFoundException(String message) : super('Not Found: $message');
}

/// Authentication failures
class AuthFailure extends Failure {
  AuthFailure(String message) : super('Auth Error: $message');
}
