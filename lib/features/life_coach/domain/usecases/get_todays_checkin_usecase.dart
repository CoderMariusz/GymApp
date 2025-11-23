import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/life_coach/domain/entities/check_in_entity.dart';
import 'package:gymapp/features/life_coach/domain/repositories/check_in_repository.dart';

/// Use case for getting today's check-in
class GetTodaysCheckInUseCase {
  final CheckInRepository _repository;

  GetTodaysCheckInUseCase(this._repository);

  Future<Result<CheckInEntity?>> call(String userId, CheckInType type) async {
    return await _repository.getTodaysCheckIn(userId, type);
  }
}
