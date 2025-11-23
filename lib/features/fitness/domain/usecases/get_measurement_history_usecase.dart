import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/fitness/domain/entities/body_measurement_entity.dart';
import 'package:lifeos/features/fitness/domain/repositories/measurements_repository.dart';

class GetMeasurementHistoryUseCase {
  final MeasurementsRepository _repository;

  GetMeasurementHistoryUseCase(this._repository);

  Future<Result<List<BodyMeasurementEntity>>> call(String userId, {int? limit}) async {
    return await _repository.getMeasurements(userId, limit: limit);
  }
}
