import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_update_request.freezed.dart';

/// Profile update request entity
/// Contains fields to update in user profile
@freezed
class ProfileUpdateRequest with _$ProfileUpdateRequest {
  const factory ProfileUpdateRequest({
    String? name,
    String? email,
    String? avatarUrl,
  }) = _ProfileUpdateRequest;
}

/// Extension for ProfileUpdateRequest helper methods
extension ProfileUpdateRequestX on ProfileUpdateRequest {
  /// Check if request has any changes
  bool get hasChanges => name != null || email != null || avatarUrl != null;
}
