import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymapp/core/database/database.dart';
import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/core/initialization/app_initializer.dart';
import 'package:gymapp/features/life_coach/data/repositories/check_in_repository_impl.dart';
import 'package:gymapp/features/life_coach/domain/entities/check_in_entity.dart';
import 'package:gymapp/features/life_coach/domain/repositories/check_in_repository.dart';
import 'package:gymapp/features/life_coach/domain/usecases/create_morning_checkin_usecase.dart';
import 'package:gymapp/features/life_coach/domain/usecases/create_evening_reflection_usecase.dart';
import 'package:gymapp/features/life_coach/domain/usecases/get_todays_checkin_usecase.dart';

/// Database provider for check-ins
final checkInDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(appDatabaseProvider);
});

/// Repository provider
final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  final database = ref.watch(checkInDatabaseProvider);
  return CheckInRepositoryImpl(database);
});

/// Create morning check-in use case
final createMorningCheckInUseCaseProvider =
    Provider<CreateMorningCheckInUseCase>((ref) {
  final repository = ref.watch(checkInRepositoryProvider);
  return CreateMorningCheckInUseCase(repository);
});

/// Create evening reflection use case
final createEveningReflectionUseCaseProvider =
    Provider<CreateEveningReflectionUseCase>((ref) {
  final repository = ref.watch(checkInRepositoryProvider);
  return CreateEveningReflectionUseCase(repository);
});

/// Get today's check-in use case
final getTodaysCheckInUseCaseProvider =
    Provider<GetTodaysCheckInUseCase>((ref) {
  final repository = ref.watch(checkInRepositoryProvider);
  return GetTodaysCheckInUseCase(repository);
});

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
class CheckInNotifier extends StateNotifier<CheckInState> {
  final CheckInRepository _repository;
  final CreateMorningCheckInUseCase _createMorningCheckIn;
  final CreateEveningReflectionUseCase _createEveningReflection;
  final GetTodaysCheckInUseCase _getTodaysCheckIn;

  CheckInNotifier(
    this._repository,
    this._createMorningCheckIn,
    this._createEveningReflection,
    this._getTodaysCheckIn,
  ) : super(CheckInState());

  /// Create morning check-in
  Future<Result<CheckInEntity>> createMorningCheckIn(
      CheckInEntity checkIn) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createMorningCheckIn(checkIn);

    result.when(
      success: (createdCheckIn) {
        state = state.copyWith(
          isLoading: false,
          todaysMorningCheckIn: createdCheckIn,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
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

    result.when(
      success: (createdCheckIn) {
        state = state.copyWith(
          isLoading: false,
          todaysEveningCheckIn: createdCheckIn,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
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
    morningResult.when(
      success: (checkIn) => morningCheckIn = checkIn,
      failure: (_) => null,
    );

    // Load evening check-in
    final eveningResult =
        await _getTodaysCheckIn(userId, CheckInType.evening);
    CheckInEntity? eveningCheckIn;
    eveningResult.when(
      success: (checkIn) => eveningCheckIn = checkIn,
      failure: (_) => null,
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

    result.when(
      success: (checkIns) {
        state = state.copyWith(
          recentCheckIns: checkIns.take(10).toList(),
        );
      },
      failure: (_) => null,
    );
  }
}

/// Check-in provider
final checkInProvider =
    StateNotifierProvider<CheckInNotifier, CheckInState>((ref) {
  final repository = ref.watch(checkInRepositoryProvider);
  final createMorning = ref.watch(createMorningCheckInUseCaseProvider);
  final createEvening = ref.watch(createEveningReflectionUseCaseProvider);
  final getTodaysCheckIn = ref.watch(getTodaysCheckInUseCaseProvider);

  return CheckInNotifier(
    repository,
    createMorning,
    createEvening,
    getTodaysCheckIn,
  );
});
