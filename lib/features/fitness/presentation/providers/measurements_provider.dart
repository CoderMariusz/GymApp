import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymapp/core/database/database.dart';
import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/core/initialization/app_initializer.dart';
import 'package:gymapp/features/fitness/data/repositories/measurements_repository_impl.dart';
import 'package:gymapp/features/fitness/domain/entities/body_measurement_entity.dart';
import 'package:gymapp/features/fitness/domain/repositories/measurements_repository.dart';
import 'package:gymapp/features/fitness/domain/usecases/record_measurement_usecase.dart';
import 'package:gymapp/features/fitness/domain/usecases/get_measurement_history_usecase.dart';

final measurementsDatabaseProvider = Provider<AppDatabase>((ref) => ref.watch(appDatabaseProvider));
final measurementsRepositoryProvider = Provider<MeasurementsRepository>(
    (ref) => MeasurementsRepositoryImpl(ref.watch(measurementsDatabaseProvider)));
final recordMeasurementUseCaseProvider =
    Provider((ref) => RecordMeasurementUseCase(ref.watch(measurementsRepositoryProvider)));
final getMeasurementHistoryUseCaseProvider =
    Provider((ref) => GetMeasurementHistoryUseCase(ref.watch(measurementsRepositoryProvider)));

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

class MeasurementsNotifier extends StateNotifier<MeasurementsState> {
  final RecordMeasurementUseCase _recordMeasurement;
  final GetMeasurementHistoryUseCase _getHistory;

  MeasurementsNotifier(this._recordMeasurement, this._getHistory) : super(MeasurementsState());

  Future<Result<BodyMeasurementEntity>> recordMeasurement(BodyMeasurementEntity measurement) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _recordMeasurement(measurement);
    result.when(
      success: (m) => state = state.copyWith(isLoading: false, measurements: [m, ...state.measurements]),
      failure: (f) => state = state.copyWith(isLoading: false, error: f.toString()),
    );
    return result;
  }

  Future<void> loadHistory(String userId, {int? limit}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getHistory(userId, limit: limit);
    result.when(
      success: (m) => state = state.copyWith(isLoading: false, measurements: m),
      failure: (f) => state = state.copyWith(isLoading: false, error: f.toString()),
    );
  }
}

final measurementsProvider = StateNotifierProvider<MeasurementsNotifier, MeasurementsState>((ref) {
  return MeasurementsNotifier(
    ref.watch(recordMeasurementUseCaseProvider),
    ref.watch(getMeasurementHistoryUseCaseProvider),
  );
});
