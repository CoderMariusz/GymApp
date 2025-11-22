import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/core/auth/domain/entities/user_entity.dart';

part 'auth_session_entity.freezed.dart';
part 'auth_session_entity.g.dart';

/// Authentication session entity - Domain layer
/// Represents an active user session with tokens and expiration
@freezed
class AuthSessionEntity with _$AuthSessionEntity {
  const factory AuthSessionEntity({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required UserEntity user,
  }) = _AuthSessionEntity;

  const AuthSessionEntity._();

  /// Check if the session has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if the session is still valid
  bool get isValid => !isExpired;

  factory AuthSessionEntity.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionEntityFromJson(json);
}
