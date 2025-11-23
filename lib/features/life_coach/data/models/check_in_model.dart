import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymapp/features/life_coach/domain/entities/check_in_entity.dart';
import 'package:gymapp/core/database/database.dart';

part 'check_in_model.freezed.dart';
part 'check_in_model.g.dart';

/// Model for check-in data (mirrors CheckInEntity)
@freezed
class CheckInModel with _$CheckInModel {
  const factory CheckInModel({
    required String id,
    required String userId,
    required DateTime timestamp,
    required String type,

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
  }) = _CheckInModel;

  const CheckInModel._();

  factory CheckInModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInModelFromJson(json);

  /// Create model from Drift database row
  factory CheckInModel.fromDrift(CheckIn row) {
    final tagsJson = row.tags;
    return CheckInModel(
      id: row.id,
      userId: row.userId,
      timestamp: row.timestamp,
      type: row.type,
      energyLevel: row.energyLevel,
      mood: row.mood,
      intentions: row.intentions,
      gratitude: row.gratitude,
      productivityRating: row.productivityRating,
      wins: row.wins,
      improvements: row.improvements,
      tomorrowFocus: row.tomorrowFocus,
      tags: tagsJson != null ? List<String>.from(jsonDecode(tagsJson)) : null,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }

  /// Convert to Drift companion for insertion/update
  CheckInsCompanion toDriftCompanion() {
    return CheckInsCompanion.insert(
      id: id,
      userId: userId,
      timestamp: timestamp,
      type: type,
      energyLevel: Value(energyLevel),
      mood: Value(mood),
      intentions: Value(intentions),
      gratitude: Value(gratitude),
      productivityRating: Value(productivityRating),
      wins: Value(wins),
      improvements: Value(improvements),
      tomorrowFocus: Value(tomorrowFocus),
      tags: Value(tags != null ? jsonEncode(tags) : null),
      notes: Value(notes),
      createdAt: createdAt,
      updatedAt: Value(updatedAt ?? DateTime.now()),
      isSynced: isSynced,
    );
  }

  /// Convert model to entity
  CheckInEntity toEntity() {
    return CheckInEntity(
      id: id,
      userId: userId,
      timestamp: timestamp,
      type: type == 'morning' ? CheckInType.morning : CheckInType.evening,
      energyLevel: energyLevel,
      mood: mood,
      intentions: intentions,
      gratitude: gratitude,
      productivityRating: productivityRating,
      wins: wins,
      improvements: improvements,
      tomorrowFocus: tomorrowFocus,
      tags: tags,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  /// Create model from entity
  factory CheckInModel.fromEntity(CheckInEntity entity) {
    return CheckInModel(
      id: entity.id,
      userId: entity.userId,
      timestamp: entity.timestamp,
      type: entity.type == CheckInType.morning ? 'morning' : 'evening',
      energyLevel: entity.energyLevel,
      mood: entity.mood,
      intentions: entity.intentions,
      gratitude: entity.gratitude,
      productivityRating: entity.productivityRating,
      wins: entity.wins,
      improvements: entity.improvements,
      tomorrowFocus: entity.tomorrowFocus,
      tags: entity.tags,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
    );
  }
}
