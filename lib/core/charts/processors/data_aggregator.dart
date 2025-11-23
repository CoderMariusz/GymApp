import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../models/chart_data.dart';

class DataAggregator {
  /// Generic aggregation - reusable for ANY time-series data!
  static List<ChartDataPoint> aggregateByPeriod<T>({
    required List<T> items,
    required DateTime Function(T) getDate,
    required double Function(T) getValue,
    required AggregationPeriod period,
    required AggregationType type,
  }) {
    if (items.isEmpty) return [];

    // Group by period
    final grouped = groupBy<T, DateTime>(items, (item) {
      final date = getDate(item);
      switch (period) {
        case AggregationPeriod.daily:
          return DateTime(date.year, date.month, date.day);
        case AggregationPeriod.weekly:
          return _getWeekStart(date);
        case AggregationPeriod.monthly:
          return DateTime(date.year, date.month);
      }
    });

    // Aggregate values
    return grouped.entries.map((entry) {
      final values = entry.value.map(getValue).toList();
      final aggregated = _aggregate(values, type);

      return ChartDataPoint(
        x: entry.key.millisecondsSinceEpoch.toDouble(),
        y: aggregated,
        label: _formatLabel(entry.key, period),
      );
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  static double _aggregate(List<double> values, AggregationType type) {
    if (values.isEmpty) return 0;

    switch (type) {
      case AggregationType.sum:
        return values.reduce((a, b) => a + b);
      case AggregationType.average:
        return values.average;
      case AggregationType.max:
        return values.reduce((a, b) => a > b ? a : b);
      case AggregationType.min:
        return values.reduce((a, b) => a < b ? a : b);
    }
  }

  static DateTime _getWeekStart(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  static String _formatLabel(DateTime date, AggregationPeriod period) {
    switch (period) {
      case AggregationPeriod.daily:
        return DateFormat('MMM dd').format(date);
      case AggregationPeriod.weekly:
        return DateFormat('MMM dd').format(date);
      case AggregationPeriod.monthly:
        return DateFormat('MMM yyyy').format(date);
    }
  }
}
