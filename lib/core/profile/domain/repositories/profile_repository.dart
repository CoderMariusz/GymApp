import 'dart:io';

import 'package:lifeos/core/error/result.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/profile_update_request.dart';

/// Profile repository interface
/// Defines the contract for profile operations
abstract class ProfileRepository {
  /// Update user profile
  Future<Result<UserEntity>> updateProfile(ProfileUpdateRequest request);

  /// Upload avatar image
  /// Returns public URL of uploaded avatar
  Future<Result<String>> uploadAvatar(File imageFile);

  /// Change password
  /// Requires current password for verification
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Delete avatar
  Future<Result<void>> deleteAvatar();
}
