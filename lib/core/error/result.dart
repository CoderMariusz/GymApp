import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// Result type for handling success and failure cases
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Exception exception) = Failure<T>;

  const Result._();

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if success, throw if failure
  T get dataOrThrow {
    return when(
      success: (data) => data,
      failure: (error) => throw error,
    );
  }

  /// Get data if success, null if failure
  T? get dataOrNull {
    return when(
      success: (data) => data,
      failure: (_) => null,
    );
  }
}
