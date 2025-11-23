import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/features/fitness/domain/entities/body_measurement_entity.dart';
import 'package:lifeos/core/database/database.dart';

part 'body_measurement_model.freezed.dart';

@freezed
sealed class BodyMeasurementModel with _$BodyMeasurementModel {
  const factory BodyMeasurementModel({
    required String id,
    required String userId,
    required DateTime timestamp,
    double? weight,
    double? bodyFat,
    double? muscleMass,
    double? chest,
    double? waist,
    double? hips,
    double? biceps,
    double? thighs,
    double? calves,
    String? photoUrl,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isSynced,
  }) = _BodyMeasurementModel;

  const BodyMeasurementModel._();

  factory BodyMeasurementModel.fromDrift(BodyMeasurement row) {
    return BodyMeasurementModel(
      id: row.id,
      userId: row.userId,
      timestamp: row.timestamp,
      weight: row.weight,
      bodyFat: row.bodyFat,
      muscleMass: row.muscleMass,
      chest: row.chest,
      waist: row.waist,
      hips: row.hips,
      biceps: row.biceps,
      thighs: row.thighs,
      calves: row.calves,
      photoUrl: row.photoUrl,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }

  BodyMeasurementsCompanion toDriftCompanion() {
    return BodyMeasurementsCompanion.insert(
      id: id,
      userId: userId,
      timestamp: timestamp,
      weight: Value(weight),
      bodyFat: Value(bodyFat),
      muscleMass: Value(muscleMass),
      chest: Value(chest),
      waist: Value(waist),
      hips: Value(hips),
      biceps: Value(biceps),
      thighs: Value(thighs),
      calves: Value(calves),
      photoUrl: Value(photoUrl),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: updatedAt != null ? Value(updatedAt) : Value(DateTime.now()),
      isSynced: Value(isSynced),
    );
  }

  BodyMeasurementEntity toEntity() => BodyMeasurementEntity(
        id: id,
        userId: userId,
        timestamp: timestamp,
        weight: weight,
        bodyFat: bodyFat,
        muscleMass: muscleMass,
        chest: chest,
        waist: waist,
        hips: hips,
        biceps: biceps,
        thighs: thighs,
        calves: calves,
        photoUrl: photoUrl,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isSynced: isSynced,
      );

  factory BodyMeasurementModel.fromEntity(BodyMeasurementEntity entity) =>
      BodyMeasurementModel(
        id: entity.id,
        userId: entity.userId,
        timestamp: entity.timestamp,
        weight: entity.weight,
        bodyFat: entity.bodyFat,
        muscleMass: entity.muscleMass,
        chest: entity.chest,
        waist: entity.waist,
        hips: entity.hips,
        biceps: entity.biceps,
        thighs: entity.thighs,
        calves: entity.calves,
        photoUrl: entity.photoUrl,
        notes: entity.notes,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        isSynced: entity.isSynced,
      );
}
