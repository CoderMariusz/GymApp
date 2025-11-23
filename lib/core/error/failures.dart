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

/// AI Service failures
class AIServiceFailure extends Failure {
  AIServiceFailure(String message) : super('AI Service Error: $message');
}

/// AI Response parsing failures
class AIParsingFailure extends Failure {
  AIParsingFailure(String message) : super('AI Parsing Error: $message');
}

/// Rate limit exceeded failures
class RateLimitFailure extends Failure {
  RateLimitFailure(String message) : super('Rate Limit Exceeded: $message');
}

/// Calendar integration failures
class CalendarFailure extends Failure {
  CalendarFailure(String message) : super('Calendar Error: $message');
}
