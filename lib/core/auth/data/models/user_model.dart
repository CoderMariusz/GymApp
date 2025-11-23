import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model - Data layer DTO
/// Maps between Supabase User and UserEntity
@freezed
sealed class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    String? name,
    String? avatarUrl,
    required bool emailVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
      emailVerified: emailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      avatarUrl: entity.avatarUrl,
      emailVerified: entity.emailVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create from Supabase User and user_profiles data
  factory UserModel.fromSupabase({
    required supabase.User user,
    Map<String, dynamic>? profileData,
  }) {
    final now = DateTime.now();

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: profileData?['name'] as String? ??
            user.userMetadata?['name'] as String? ??
            user.email?.split('@').first,
      avatarUrl: profileData?['avatar_url'] as String? ??
                 user.userMetadata?['avatar_url'] as String?,
      emailVerified: user.emailConfirmedAt != null,
      createdAt: user.createdAt != null
          ? DateTime.parse(user.createdAt!)
          : now,
      updatedAt: profileData?['updated_at'] != null
          ? DateTime.parse(profileData!['updated_at'] as String)
          : now,
    );
  }
}
