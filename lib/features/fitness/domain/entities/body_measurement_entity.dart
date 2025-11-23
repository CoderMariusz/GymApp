import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_measurement_entity.freezed.dart';
part 'body_measurement_entity.g.dart';

@freezed
class BodyMeasurementEntity with _$BodyMeasurementEntity {
  const factory BodyMeasurementEntity({
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
  }) = _BodyMeasurementEntity;

  const BodyMeasurementEntity._();

  factory BodyMeasurementEntity.fromJson(Map<String, dynamic> json) =>
      _$BodyMeasurementEntityFromJson(json);
}
