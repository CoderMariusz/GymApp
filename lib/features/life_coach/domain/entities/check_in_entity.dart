import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_in_entity.freezed.dart';

/// Type of check-in
enum CheckInType {
  morning,
  evening,
}

/// Check-in entity for morning check-ins and evening reflections
@freezed
class CheckInEntity with _$CheckInEntity {
  const factory CheckInEntity({
    required String id,
    required String userId,
    required DateTime timestamp,
    required CheckInType type,

    // Morning Check-In fields
    int? energyLevel,
    int? mood,
    String? intentions,
    String? gratitude,

    // Evening Reflection fields
    int? productivityRating,
    String? wins,
    String? improvements,
    String? tomorrowFocus,

    // Common fields
    List<String>? tags,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isSynced,
  }) = _CheckInEntity;

  const CheckInEntity._();

  /// Returns true if this is a morning check-in
  bool get isMorning => type == CheckInType.morning;

  /// Returns true if this is an evening reflection
  bool get isEvening => type == CheckInType.evening;
}
