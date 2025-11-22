import 'dart:io';

import '../../../auth/domain/exceptions/auth_exceptions.dart';
import 'package:lifeos/core/error/result.dart';
import '../repositories/profile_repository.dart';

/// Upload avatar use case
/// Handles avatar image upload with validation
class UploadAvatarUseCase {
  final ProfileRepository _repository;

  // Max file size: 5MB
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  const UploadAvatarUseCase(this._repository);

  /// Upload avatar image
  /// Validates file size before upload
  /// Image will be compressed to 512x512px in repository
  Future<Result<String>> call(File imageFile) async {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        return const Result.failure(
        UnknownAuthException('File not found'),
      );
      }

      // Validate file size
      final fileSize = imageFile.lengthSync();
      if (fileSize > maxFileSizeBytes) {
        return Result.failure(
          UnknownAuthException('File too large: ${(fileSize / (1024 * 1024)).toStringAsFixed(0)}MB'),
        );
      }

      // Upload via repository (includes compression)
      return await _repository.uploadAvatar(imageFile);
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
      );
    }
  }
}
