import 'package:drift/drift.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/core/error/failures.dart';
import 'package:lifeos/features/fitness/data/models/body_measurement_model.dart';
import 'package:lifeos/features/fitness/domain/entities/body_measurement_entity.dart';
import 'package:lifeos/features/fitness/domain/repositories/measurements_repository.dart';

class MeasurementsRepositoryImpl implements MeasurementsRepository {
  final AppDatabase _database;

  MeasurementsRepositoryImpl(this._database);

  @override
  Future<Result<BodyMeasurementEntity>> recordMeasurement(BodyMeasurementEntity measurement) async {
    try {
      final model = BodyMeasurementModel.fromEntity(measurement);
      await _database.into(_database.bodyMeasurements).insert(model.toDriftCompanion());
      return Result.success(measurement);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to record measurement: $e'));
    }
  }

  @override
  Future<Result<List<BodyMeasurementEntity>>> getMeasurements(String userId, {int? limit}) async {
    try {
      var query = _database.select(_database.bodyMeasurements)
        ..where((tbl) => tbl.userId.equals(userId))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)]);

      if (limit != null) {
        query = query..limit(limit);
      }

      final rows = await query.get();
      final entities = rows.map((row) => BodyMeasurementModel.fromDrift(row).toEntity()).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get measurements: $e'));
    }
  }

  @override
  Future<Result<BodyMeasurementEntity?>> getLatestMeasurement(String userId) async {
    try {
      final row = await (_database.select(_database.bodyMeasurements)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)])
            ..limit(1))
          .getSingleOrNull();

      if (row == null) return const Result.success(null);
      return Result.success(BodyMeasurementModel.fromDrift(row).toEntity());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get latest measurement: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMeasurement(String id) async {
    try {
      await (_database.delete(_database.bodyMeasurements)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete measurement: $e'));
    }
  }
}
