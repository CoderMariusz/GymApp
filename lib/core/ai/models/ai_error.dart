sealed class AIException implements Exception {
  final String message;
  final int? statusCode;

  const AIException(this.message, [this.statusCode]);

  @override
  String toString() => 'AIException: $message (status: $statusCode)';
}

class RateLimitException extends AIException {
  final int retryAfterSeconds;

  const RateLimitException({
    required this.retryAfterSeconds,
    String message = 'Rate limit exceeded',
  }) : super(message, 429);
}

class AuthenticationException extends AIException {
  const AuthenticationException([String message = 'Invalid API key'])
      : super(message, 401);
}

class InvalidRequestException extends AIException {
  const InvalidRequestException([String message = 'Invalid request'])
      : super(message, 400);
}

class NetworkException extends AIException {
  const NetworkException([String message = 'Network error'])
      : super(message);
}

class TimeoutException extends AIException {
  const TimeoutException([String message = 'Request timeout'])
      : super(message, 408);
}
