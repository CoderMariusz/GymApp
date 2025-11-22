// ============================================================================
// LifeOS - History Repository for Historical Data
// ============================================================================
// Used for: Workout History, Goal History, Measurements History, etc.
// ============================================================================

import 'package:gymapp/core/error/result.dart';

/// Generic repository for historical/time-series data
///
/// Provides:
/// - Chronological data storage
/// - Date range queries
/// - Aggregation functions
/// - Export capabilities
///
/// Type parameters:
/// - T: Entity type (e.g., WorkoutHistory, MeasurementHistory)
/// - ID: ID type (typically String or int)
abstract class HistoryRepository<T, ID> {
  /// Adds a new history entry
  Future<Result<T>> addEntry(T entry);

  /// Gets history entries for a specific entity
  ///
  /// Returns entries ordered by date (newest first by default)
  Future<Result<List<T>>> getHistory(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    bool ascending = false,
  });

  /// Gets a single history entry by ID
  Future<Result<T>> getEntry(ID entryId);

  /// Updates a history entry
  Future<Result<T>> updateEntry(T entry);

  /// Deletes a history entry
  Future<Result<void>> deleteEntry(ID entryId);

  /// Gets the most recent entry for an entity
  Future<Result<T?>> getLatest(ID entityId);

  /// Gets history grouped by date
  ///
  /// Returns map of date -> list of entries
  Future<Result<Map<DateTime, List<T>>>> getGroupedByDate(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets aggregated statistics for a period
  Future<Result<HistoryStats>> getStats(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Deletes all history for an entity
  Future<Result<void>> clearHistory(ID entityId);

  /// Gets entries count for an entity
  Future<Result<int>> getCount(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Checks if entity has any history
  Future<Result<bool>> hasHistory(ID entityId);
}

/// Statistics calculated from historical data
class HistoryStats {
  final int totalEntries;
  final DateTime? firstEntryDate;
  final DateTime? lastEntryDate;
  final double? average;
  final double? minimum;
  final double? maximum;
  final double? total;
  final Map<String, dynamic>? customStats;

  const HistoryStats({
    required this.totalEntries,
    this.firstEntryDate,
    this.lastEntryDate,
    this.average,
    this.minimum,
    this.maximum,
    this.total,
    this.customStats,
  });

  Duration? get timespan {
    if (firstEntryDate == null || lastEntryDate == null) return null;
    return lastEntryDate!.difference(firstEntryDate!);
  }

  double? get range {
    if (minimum == null || maximum == null) return null;
    return maximum! - minimum!;
  }
}

/// Mixin for repositories that export history data
mixin HistoryExportMixin<T, ID> on HistoryRepository<T, ID> {
  /// Exports history as CSV
  Future<Result<String>> exportToCSV(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Exports history as JSON
  Future<Result<String>> exportToJSON(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets data formatted for charts
  Future<Result<List<ChartDataPoint>>> getChartData(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
    ChartGrouping grouping = ChartGrouping.day,
  });
}

/// Data point for chart visualization
class ChartDataPoint {
  final DateTime date;
  final double value;
  final String? label;
  final Map<String, dynamic>? metadata;

  const ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
    this.metadata,
  });
}

/// How to group data for charts
enum ChartGrouping {
  hour,
  day,
  week,
  month,
  year,
}

/// Mixin for repositories with aggregation capabilities
mixin HistoryAggregationMixin<T, ID> on HistoryRepository<T, ID> {
  /// Gets daily totals
  Future<Result<Map<DateTime, double>>> getDailyTotals(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets weekly averages
  Future<Result<Map<DateTime, double>>> getWeeklyAverages(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets monthly totals
  Future<Result<Map<DateTime, double>>> getMonthlyTotals(
    ID entityId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets moving average
  Future<Result<List<ChartDataPoint>>> getMovingAverage(
    ID entityId, {
    required int windowDays,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Mixin for repositories with backup/restore
mixin HistoryBackupMixin<T, ID> on HistoryRepository<T, ID> {
  /// Creates a backup of all history
  Future<Result<String>> backupHistory(ID entityId);

  /// Restores history from backup
  Future<Result<void>> restoreHistory(
    ID entityId,
    String backupData,
  );

  /// Gets backup size in bytes
  Future<Result<int>> getBackupSize(ID entityId);
}

/// Base class for history entry entities
abstract class HistoryEntry {
  String get id;
  DateTime get timestamp;
  String get entityId;

  /// Creates a copy with updated timestamp
  HistoryEntry withTimestamp(DateTime timestamp);
}

/// Helper for calculating time-based statistics
class TimeSeriesAnalyzer {
  /// Calculates trend (linear regression slope)
  static double calculateTrend(List<ChartDataPoint> data) {
    if (data.length < 2) return 0;

    final n = data.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (var i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = data[i].value;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope;
  }

  /// Calculates standard deviation
  static double calculateStdDev(List<double> values) {
    if (values.isEmpty) return 0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
            values.length;

    return variance.sqrt();
  }

  /// Detects outliers using IQR method
  static List<int> detectOutliers(List<double> values) {
    if (values.length < 4) return [];

    final sorted = List<double>.from(values)..sort();
    final q1 = sorted[sorted.length ~/ 4];
    final q3 = sorted[(sorted.length * 3) ~/ 4];
    final iqr = q3 - q1;
    final lowerBound = q1 - 1.5 * iqr;
    final upperBound = q3 + 1.5 * iqr;

    final outliers = <int>[];
    for (var i = 0; i < values.length; i++) {
      if (values[i] < lowerBound || values[i] > upperBound) {
        outliers.add(i);
      }
    }

    return outliers;
  }
}

extension on double {
  double sqrt() {
    return this >= 0 ? this.sign * this.abs().toDouble() : 0;
  }
}
