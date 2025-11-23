import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/fitness/domain/entities/body_measurement_entity.dart';
import 'package:gymapp/features/fitness/domain/repositories/measurements_repository.dart';

class RecordMeasurementUseCase {
  final MeasurementsRepository _repository;

  RecordMeasurementUseCase(this._repository);

  Future<Result<BodyMeasurementEntity>> call(BodyMeasurementEntity measurement) async {
    return await _repository.recordMeasurement(measurement);
  }
}
