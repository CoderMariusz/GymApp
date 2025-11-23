import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/core/error/failures.dart';
import 'package:gymapp/features/life_coach/domain/entities/check_in_entity.dart';
import 'package:gymapp/features/life_coach/domain/repositories/check_in_repository.dart';

/// Use case for creating an evening reflection
class CreateEveningReflectionUseCase {
  final CheckInRepository _repository;

  CreateEveningReflectionUseCase(this._repository);

  Future<Result<CheckInEntity>> call(CheckInEntity checkIn) async {
    // Validate that it's an evening reflection
    if (checkIn.type != CheckInType.evening) {
      return Result.failure(
        ValidationFailure('Check-in must be of type evening'),
      );
    }

    return await _repository.createCheckIn(checkIn);
  }
}
