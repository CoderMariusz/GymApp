import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/database/database_providers.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/fitness/data/repositories/measurements_repository_impl.dart';
import 'package:lifeos/features/fitness/domain/entities/body_measurement_entity.dart';
import 'package:lifeos/features/fitness/domain/repositories/measurements_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/record_measurement_usecase.dart';
import 'package:lifeos/features/fitness/domain/usecases/get_measurement_history_usecase.dart';

part 'measurements_provider.g.dart';

@riverpod
AppDatabase measurementsDatabase(MeasurementsDatabaseRef ref) => ref.watch(appDatabaseProvider);

@riverpod
MeasurementsRepository measurementsRepository(MeasurementsRepositoryRef ref) =>
    MeasurementsRepositoryImpl(ref.watch(measurementsDatabaseProvider));

@riverpod
RecordMeasurementUseCase recordMeasurementUseCase(RecordMeasurementUseCaseRef ref) =>
    RecordMeasurementUseCase(ref.watch(measurementsRepositoryProvider));

@riverpod
GetMeasurementHistoryUseCase getMeasurementHistoryUseCase(GetMeasurementHistoryUseCaseRef ref) =>
    GetMeasurementHistoryUseCase(ref.watch(measurementsRepositoryProvider));

class MeasurementsState {
  final bool isLoading;
  final String? error;
  final List<BodyMeasurementEntity> measurements;

  MeasurementsState({this.isLoading = false, this.error, this.measurements = const []});

  MeasurementsState copyWith({
    bool? isLoading,
    String? error,
    List<BodyMeasurementEntity>? measurements,
  }) {
    return MeasurementsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      measurements: measurements ?? this.measurements,
    );
  }
}

@riverpod
class MeasurementsNotifier extends _$MeasurementsNotifier {
  late final RecordMeasurementUseCase _recordMeasurement;
  late final GetMeasurementHistoryUseCase _getHistory;

  @override
  MeasurementsState build() {
    _recordMeasurement = ref.watch(recordMeasurementUseCaseProvider);
    _getHistory = ref.watch(getMeasurementHistoryUseCaseProvider);

    return MeasurementsState();
  }

  Future<Result<BodyMeasurementEntity>> recordMeasurement(BodyMeasurementEntity measurement) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _recordMeasurement(measurement);
    result.map(
      success: (success) => state = state.copyWith(isLoading: false, measurements: [success.data, ...state.measurements]),
      failure: (failure) => state = state.copyWith(isLoading: false, error: failure.exception.toString()),
    );
    return result;
  }

  Future<void> loadHistory(String userId, {int? limit}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getHistory(userId, limit: limit);
    result.map(
      success: (success) => state = state.copyWith(isLoading: false, measurements: success.data),
      failure: (failure) => state = state.copyWith(isLoading: false, error: failure.exception.toString()),
    );
  }
}
