import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'user_model.dart';

part 'auth_session_model.freezed.dart';
part 'auth_session_model.g.dart';

/// Auth session model - Data layer
/// Maps between Supabase Session and AuthSessionEntity
@freezed
class AuthSessionModel with _$AuthSessionModel {
  const factory AuthSessionModel({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required UserModel user,
  }) = _AuthSessionModel;

  const AuthSessionModel._();

  /// Create from Supabase Session
  factory AuthSessionModel.fromSupabase({
    required Session session,
    required Map<String, dynamic> profileData,
  }) {
    return AuthSessionModel(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      ),
      user: UserModel.fromSupabase(
        user: session.user,
        profileData: profileData,
      ),
    );
  }

  /// Create from JSON (for storage)
  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionModelFromJson(json);

  /// Convert to entity
  AuthSessionEntity toEntity() {
    return AuthSessionEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      user: user.toEntity(),
    );
  }

  /// Create from entity
  factory AuthSessionModel.fromEntity(AuthSessionEntity entity) {
    return AuthSessionModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      expiresAt: entity.expiresAt,
      user: UserModel.fromEntity(entity.user),
    );
  }
}
