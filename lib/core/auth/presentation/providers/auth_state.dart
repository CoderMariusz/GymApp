import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

/// Authentication state
/// Represents the current authentication status
@freezed
sealed class AuthState with _$AuthState {
  /// Initial state
  const factory AuthState.initial() = _Initial;

  /// Loading state (during authentication operations)
  const factory AuthState.loading() = _Loading;

  /// Authenticated state (user is logged in)
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;

  /// Unauthenticated state (no user logged in)
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Error state (authentication failed)
  const factory AuthState.error(String message) = _Error;
}
