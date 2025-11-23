import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/fitness/domain/entities/body_measurement_entity.dart';

abstract class MeasurementsRepository {
  Future<Result<BodyMeasurementEntity>> recordMeasurement(BodyMeasurementEntity measurement);
  Future<Result<List<BodyMeasurementEntity>>> getMeasurements(String userId, {int? limit});
  Future<Result<BodyMeasurementEntity?>> getLatestMeasurement(String userId);
  Future<Result<void>> deleteMeasurement(String id);
}
