import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/sync/conflict_resolver.dart';

/// Manages Realtime subscriptions for data sync
class RealtimeSyncService {
  final SupabaseClient _supabase;
  final AppDatabase _database;
  final ConflictResolver _conflictResolver;
  final Map<String, RealtimeChannel> _subscriptions = {};
  final StreamController<SyncEvent> _syncEventController = StreamController.broadcast();

  RealtimeSyncService(
    this._supabase,
    this._database,
    this._conflictResolver,
  );

  /// Stream of sync events
  Stream<SyncEvent> get syncEvents => _syncEventController.stream;

  /// Subscribe to changes for a specific table
  Future<void> subscribeToTable({
    required String tableName,
    required String userId,
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) async {
    // Unsubscribe if already subscribed
    if (_subscriptions.containsKey(tableName)) {
      await unsubscribeFromTable(tableName);
    }

    final channel = _supabase.channel('$tableName-$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            _syncEventController.add(SyncEvent(
              type: SyncEventType.remoteInsert,
              tableName: tableName,
              data: data,
            ));
            onInsert(data);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            final remoteData = payload.newRecord;
            final recordId = remoteData['id'] as String;

            // Fetch local data to check for conflicts
            final localData = await _fetchLocalRecord(tableName, recordId);
            if (localData != null) {
              final resolution = _conflictResolver.resolve(
                localData: localData,
                remoteData: remoteData,
              );

              _syncEventController.add(SyncEvent(
                type: SyncEventType.remoteUpdate,
                tableName: tableName,
                data: resolution.resolvedData,
                wasConflict: resolution.wasConflict,
              ));

              onUpdate(resolution.resolvedData);
            } else {
              _syncEventController.add(SyncEvent(
                type: SyncEventType.remoteUpdate,
                tableName: tableName,
                data: remoteData,
              ));
              onUpdate(remoteData);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final data = payload.oldRecord;
            _syncEventController.add(SyncEvent(
              type: SyncEventType.remoteDelete,
              tableName: tableName,
              data: data,
            ));
            onDelete(data);
          },
        )
        .subscribe();

    _subscriptions[tableName] = channel;
  }

  /// Unsubscribe from a table
  Future<void> unsubscribeFromTable(String tableName) async {
    final channel = _subscriptions.remove(tableName);
    if (channel != null) {
      await _supabase.removeChannel(channel);
    }
  }

  /// Unsubscribe from all tables
  Future<void> unsubscribeAll() async {
    for (final tableName in _subscriptions.keys.toList()) {
      await unsubscribeFromTable(tableName);
    }
  }

  /// Fetch local record for conflict resolution
  Future<Map<String, dynamic>?> _fetchLocalRecord(String tableName, String recordId) async {
    try {
      switch (tableName) {
        case 'mood_logs':
          final record = await (_database.select(_database.moodLogs)
                ..where((tbl) => tbl.id.equals(recordId)))
              .getSingleOrNull();
          if (record == null) return null;
          return {
            'id': record.id,
            'user_id': record.userId,
            'mood_score': record.moodScore,
            'energy_score': record.energyScore,
            'stress_level': record.stressLevel,
            'notes': record.notes,
            'logged_at': record.loggedAt.toIso8601String(),
            'created_at': record.createdAt.toIso8601String(),
            'updated_at': record.createdAt.toIso8601String(), // Use createdAt as fallback
          };
        // Add other tables as needed
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    unsubscribeAll();
    _syncEventController.close();
  }
}

/// Sync event for tracking changes
class SyncEvent {
  final SyncEventType type;
  final String tableName;
  final Map<String, dynamic> data;
  final bool wasConflict;
  final DateTime timestamp;

  SyncEvent({
    required this.type,
    required this.tableName,
    required this.data,
    this.wasConflict = false,
  }) : timestamp = DateTime.now();
}

/// Types of sync events
enum SyncEventType {
  remoteInsert,
  remoteUpdate,
  remoteDelete,
  localInsert,
  localUpdate,
  localDelete,
  conflict,
}
