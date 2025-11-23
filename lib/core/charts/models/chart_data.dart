import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_data.freezed.dart';

@freezed
sealed class ChartDataPoint with _$ChartDataPoint {
  const factory ChartDataPoint({
    required double x,      // Usually timestamp or index
    required double y,      // Value
    String? label,          // Optional label (e.g., "Jan 15")
    dynamic metadata,       // Extra data for tooltips
  }) = _ChartDataPoint;
}

enum AggregationPeriod { daily, weekly, monthly }
enum AggregationType { sum, average, max, min }
