/// Result type for error handling
/// Represents either a successful result or a failure
sealed class Result<T> {
  const Result();
}

/// Represents a successful result
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Represents a failure result
class Failure<T> extends Result<T> {
  final Exception exception;
  final String message;

  const Failure(this.exception, this.message);
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Returns true if this is a Success
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a Failure
  bool get isFailure => this is Failure<T>;

  /// Gets the value if Success, throws if Failure
  T get value {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    throw Exception('Cannot get value from Failure');
  }

  /// Gets the exception if Failure, throws if Success
  Exception get exception {
    if (this is Failure<T>) {
      return (this as Failure<T>).exception;
    }
    throw Exception('Cannot get exception from Success');
  }

  /// Transforms the result
  Result<R> map<R>(R Function(T) mapper) {
    if (this is Success<T>) {
      try {
        return Success(mapper((this as Success<T>).value));
      } catch (e) {
        return Failure(Exception(e.toString()), e.toString());
      }
    }
    return Failure((this as Failure<T>).exception, (this as Failure<T>).message);
  }

  /// Executes a function based on success or failure
  R when<R>({
    required R Function(T value) success,
    required R Function(Exception exception, String message) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).value);
    }
    return failure((this as Failure<T>).exception, (this as Failure<T>).message);
  }
}
