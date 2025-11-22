import 'dart:convert';

/// Conflict resolution strategy for data sync
enum ConflictStrategy {
  lastWriteWins,
  firstWriteWins,
  manual,
}

/// Result of conflict resolution
class ConflictResolution {
  final Map<String, dynamic> resolvedData;
  final bool wasConflict;
  final String? conflictReason;

  ConflictResolution({
    required this.resolvedData,
    required this.wasConflict,
    this.conflictReason,
  });
}

/// Service for resolving data conflicts during sync
class ConflictResolver {
  final ConflictStrategy strategy;

  ConflictResolver({this.strategy = ConflictStrategy.lastWriteWins});

  /// Resolve conflict between local and remote data
  ConflictResolution resolve({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) {
    // Extract timestamps for comparison
    final localUpdatedAt = _parseTimestamp(localData['updated_at']);
    final remoteUpdatedAt = _parseTimestamp(remoteData['updated_at']);

    // If no conflict (same data), return remote
    if (jsonEncode(localData) == jsonEncode(remoteData)) {
      return ConflictResolution(
        resolvedData: remoteData,
        wasConflict: false,
      );
    }

    // Apply conflict resolution strategy
    switch (strategy) {
      case ConflictStrategy.lastWriteWins:
        return _lastWriteWins(localData, remoteData, localUpdatedAt, remoteUpdatedAt);
      case ConflictStrategy.firstWriteWins:
        return _firstWriteWins(localData, remoteData, localUpdatedAt, remoteUpdatedAt);
      case ConflictStrategy.manual:
        return ConflictResolution(
          resolvedData: remoteData,
          wasConflict: true,
          conflictReason: 'Manual resolution required',
        );
    }
  }

  ConflictResolution _lastWriteWins(
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
    DateTime? localUpdatedAt,
    DateTime? remoteUpdatedAt,
  ) {
    // If we can't determine timestamps, prefer remote
    if (localUpdatedAt == null || remoteUpdatedAt == null) {
      return ConflictResolution(
        resolvedData: remoteData,
        wasConflict: true,
        conflictReason: 'Missing timestamp, defaulting to remote',
      );
    }

    // Use the most recently updated data
    final useLocal = localUpdatedAt.isAfter(remoteUpdatedAt);
    return ConflictResolution(
      resolvedData: useLocal ? localData : remoteData,
      wasConflict: true,
      conflictReason: 'Last write wins: ${useLocal ? 'local' : 'remote'} was newer',
    );
  }

  ConflictResolution _firstWriteWins(
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
    DateTime? localUpdatedAt,
    DateTime? remoteUpdatedAt,
  ) {
    // If we can't determine timestamps, prefer remote
    if (localUpdatedAt == null || remoteUpdatedAt == null) {
      return ConflictResolution(
        resolvedData: remoteData,
        wasConflict: true,
        conflictReason: 'Missing timestamp, defaulting to remote',
      );
    }

    // Use the earliest data
    final useLocal = localUpdatedAt.isBefore(remoteUpdatedAt);
    return ConflictResolution(
      resolvedData: useLocal ? localData : remoteData,
      wasConflict: true,
      conflictReason: 'First write wins: ${useLocal ? 'local' : 'remote'} was earlier',
    );
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
