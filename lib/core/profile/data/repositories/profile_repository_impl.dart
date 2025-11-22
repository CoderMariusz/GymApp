import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/exceptions/auth_exceptions.dart';
import '../../../utils/result.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/supabase_storage_datasource.dart';
import '../datasources/user_profile_datasource.dart';

/// Implementation of ProfileRepository
/// Uses UserProfileDataSource and SupabaseStorageDataSource
class ProfileRepositoryImpl implements ProfileRepository {
  final UserProfileDataSource _profileDataSource;
  final SupabaseStorageDataSource _storageDataSource;

  // Image compression settings
  static const int targetWidth = 512;
  static const int targetHeight = 512;
  static const int quality = 85;

  const ProfileRepositoryImpl(
    this._profileDataSource,
    this._storageDataSource,
  );

  @override
  Future<Result<UserEntity>> updateProfile(ProfileUpdateRequest request) async {
    try {
      // Get current user ID (needed for profile update)
      final userId = await _getCurrentUserId();

      // Update email if provided (separate API call)
      if (request.email != null) {
        final userModel = await _profileDataSource.updateEmail(request.email!);

        // If only email is being updated, return early
        if (request.name == null && request.avatarUrl == null) {
          return Success(userModel.toEntity());
        }
      }

      // Update profile (name, avatar)
      final userModel = await _profileDataSource.updateProfile(
        userId: userId,
        name: request.name,
        avatarUrl: request.avatarUrl,
      );

      return Success(userModel.toEntity());
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'Failed to update profile',
      );
    }
  }

  @override
  Future<Result<String>> uploadAvatar(File imageFile) async {
    try {
      final userId = await _getCurrentUserId();

      // Compress image to 512x512px
      final compressedFile = await _compressImage(imageFile);

      // Upload to Supabase Storage
      final publicUrl = await _storageDataSource.uploadAvatar(
        userId: userId,
        imageFile: compressedFile,
      );

      // Delete temporary compressed file
      if (compressedFile.path != imageFile.path) {
        await compressedFile.delete();
      }

      return Success(publicUrl);
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'Failed to upload avatar',
      );
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _profileDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return const Success(null);
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'Failed to change password',
      );
    }
  }

  @override
  Future<Result<void>> deleteAvatar() async {
    try {
      final userId = await _getCurrentUserId();

      await _storageDataSource.deleteAvatar(userId);

      return const Success(null);
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'Failed to delete avatar',
      );
    }
  }

  /// Compress image to target size
  /// Returns compressed file
  Future<File> _compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: targetWidth,
        minHeight: targetHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw Exception('Image compression failed');
      }

      return File(compressedFile.path);
    } catch (e) {
      // If compression fails, return original file
      return imageFile;
    }
  }

  /// Get current user ID
  Future<String> _getCurrentUserId() async {
    // This would normally come from auth repository/session
    // For now, throw exception as this needs to be injected
    throw const UnknownAuthException(
      'User ID not available - user not authenticated',
    );
  }
}
