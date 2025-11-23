import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/database/database_providers.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/life_coach/data/repositories/check_in_repository_impl.dart';
import 'package:lifeos/features/life_coach/domain/entities/check_in_entity.dart';
import 'package:lifeos/features/life_coach/domain/repositories/check_in_repository.dart';
import 'package:lifeos/features/life_coach/domain/usecases/create_morning_checkin_usecase.dart';
import 'package:lifeos/features/life_coach/domain/usecases/create_evening_reflection_usecase.dart';
import 'package:lifeos/features/life_coach/domain/usecases/get_todays_checkin_usecase.dart';

part 'check_in_provider.g.dart';

/// Database provider for check-ins
@riverpod
AppDatabase checkInDatabase(CheckInDatabaseRef ref) {
  return ref.watch(appDatabaseProvider);
}

/// Repository provider
@riverpod
CheckInRepository checkInRepository(CheckInRepositoryRef ref) {
  final database = ref.watch(checkInDatabaseProvider);
  return CheckInRepositoryImpl(database);
}

/// Create morning check-in use case
@riverpod
CreateMorningCheckInUseCase createMorningCheckInUseCase(CreateMorningCheckInUseCaseRef ref) {
  final repository = ref.watch(checkInRepositoryProvider);
  return CreateMorningCheckInUseCase(repository);
}

/// Create evening reflection use case
@riverpod
CreateEveningReflectionUseCase createEveningReflectionUseCase(CreateEveningReflectionUseCaseRef ref) {
  final repository = ref.watch(checkInRepositoryProvider);
  return CreateEveningReflectionUseCase(repository);
}

/// Get today's check-in use case
@riverpod
GetTodaysCheckInUseCase getTodaysCheckInUseCase(GetTodaysCheckInUseCaseRef ref) {
  final repository = ref.watch(checkInRepositoryProvider);
  return GetTodaysCheckInUseCase(repository);
}

/// Check-in state
class CheckInState {
  final bool isLoading;
  final String? error;
  final CheckInEntity? todaysMorningCheckIn;
  final CheckInEntity? todaysEveningCheckIn;
  final List<CheckInEntity> recentCheckIns;

  CheckInState({
    this.isLoading = false,
    this.error,
    this.todaysMorningCheckIn,
    this.todaysEveningCheckIn,
    this.recentCheckIns = const [],
  });

  CheckInState copyWith({
    bool? isLoading,
    String? error,
    CheckInEntity? todaysMorningCheckIn,
    CheckInEntity? todaysEveningCheckIn,
    List<CheckInEntity>? recentCheckIns,
  }) {
    return CheckInState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      todaysMorningCheckIn:
          todaysMorningCheckIn ?? this.todaysMorningCheckIn,
      todaysEveningCheckIn:
          todaysEveningCheckIn ?? this.todaysEveningCheckIn,
      recentCheckIns: recentCheckIns ?? this.recentCheckIns,
    );
  }
}

/// Check-in notifier
@riverpod
class CheckInNotifier extends _$CheckInNotifier {
  late final CheckInRepository _repository;
  late final CreateMorningCheckInUseCase _createMorningCheckIn;
  late final CreateEveningReflectionUseCase _createEveningReflection;
  late final GetTodaysCheckInUseCase _getTodaysCheckIn;

  @override
  CheckInState build() {
    _repository = ref.watch(checkInRepositoryProvider);
    _createMorningCheckIn = ref.watch(createMorningCheckInUseCaseProvider);
    _createEveningReflection = ref.watch(createEveningReflectionUseCaseProvider);
    _getTodaysCheckIn = ref.watch(getTodaysCheckInUseCaseProvider);

    return CheckInState();
  }

  /// Create morning check-in
  Future<Result<CheckInEntity>> createMorningCheckIn(
      CheckInEntity checkIn) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createMorningCheckIn(checkIn);

    result.map(
      success: (success) {
        state = state.copyWith(
          isLoading: false,
          todaysMorningCheckIn: success.data,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.exception.toString(),
        );
      },
    );

    return result;
  }

  /// Create evening reflection
  Future<Result<CheckInEntity>> createEveningReflection(
      CheckInEntity checkIn) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createEveningReflection(checkIn);

    result.map(
      success: (success) {
        state = state.copyWith(
          isLoading: false,
          todaysEveningCheckIn: success.data,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.exception.toString(),
        );
      },
    );

    return result;
  }

  /// Load today's check-ins
  Future<void> loadTodaysCheckIns(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    // Load morning check-in
    final morningResult =
        await _getTodaysCheckIn(userId, CheckInType.morning);
    CheckInEntity? morningCheckIn;
    morningResult.map(
      success: (success) => morningCheckIn = success.data,
      failure: (failure) => null,
    );

    // Load evening check-in
    final eveningResult =
        await _getTodaysCheckIn(userId, CheckInType.evening);
    CheckInEntity? eveningCheckIn;
    eveningResult.map(
      success: (success) => eveningCheckIn = success.data,
      failure: (failure) => null,
    );

    state = state.copyWith(
      isLoading: false,
      todaysMorningCheckIn: morningCheckIn,
      todaysEveningCheckIn: eveningCheckIn,
    );
  }

  /// Load recent check-ins
  Future<void> loadRecentCheckIns(String userId) async {
    final result = await _repository.getAllCheckIns(userId);

    result.map(
      success: (checkIns) {
        state = state.copyWith(
          recentCheckIns: checkIns.take(10).toList(),
        );
      },
      failure: (_) => null,
    );
  }
}
