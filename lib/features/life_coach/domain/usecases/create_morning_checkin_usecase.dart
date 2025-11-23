import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/core/error/failures.dart';
import 'package:lifeos/features/life_coach/domain/entities/check_in_entity.dart';
import 'package:lifeos/features/life_coach/domain/repositories/check_in_repository.dart';

/// Use case for creating a morning check-in
class CreateMorningCheckInUseCase {
  final CheckInRepository _repository;

  CreateMorningCheckInUseCase(this._repository);

  Future<Result<CheckInEntity>> call(CheckInEntity checkIn) async {
    // Validate that it's a morning check-in
    if (checkIn.type != CheckInType.morning) {
      return Result.failure(
        ValidationFailure('Check-in must be of type morning'),
      );
    }

    return await _repository.createCheckIn(checkIn);
  }
}
