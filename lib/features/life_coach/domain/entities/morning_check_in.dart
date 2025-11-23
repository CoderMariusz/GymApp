import 'package:freezed_annotation/freezed_annotation.dart';

part 'morning_check_in.freezed.dart';

@freezed
class MorningCheckIn with _$MorningCheckIn {
  const factory MorningCheckIn({
    required String id,
    required DateTime date,
    required int mood,           // 1-10
    required int energy,         // 1-10
    required int sleepQuality,   // 1-10
    required double sleepHours,  // e.g., 7.5
    String? notes,
    required DateTime createdAt,
  }) = _MorningCheckIn;
}
