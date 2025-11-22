import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:lifeos/core/database/database.dart';

/// Service for managing the sync queue for offline operations
class SyncQueueService {
  final AppDatabase _database;
  final _uuid = const Uuid();

  SyncQueueService(this._database);

  /// Enqueue a create operation
  Future<void> enqueueCreate(String tableName, String recordId, Map<String, dynamic> data) async {
    await _database.enqueueSyncOperation(
      id: _uuid.v4(),
      tableName: tableName,
      recordId: recordId,
      operation: 'insert',
      payload: jsonEncode(data),
    );
  }

  /// Enqueue an update operation
  Future<void> enqueueUpdate(String tableName, String recordId, Map<String, dynamic> data) async {
    await _database.enqueueSyncOperation(
      id: _uuid.v4(),
      tableName: tableName,
      recordId: recordId,
      operation: 'update',
      payload: jsonEncode(data),
    );
  }

  /// Enqueue a delete operation
  Future<void> enqueueDelete(String tableName, String recordId) async {
    await _database.enqueueSyncOperation(
      id: _uuid.v4(),
      tableName: tableName,
      recordId: recordId,
      operation: 'delete',
      payload: jsonEncode({'id': recordId}),
    );
  }

  /// Get all pending sync operations
  Future<List<SyncQueueItem>> getPendingOperations() async {
    return await _database.getPendingSyncItems();
  }

  /// Mark a sync operation as completed
  Future<void> markCompleted(String queueId) async {
    await _database.markSyncItemCompleted(queueId);
  }

  /// Update retry count and error message for failed sync
  Future<void> recordFailure(String queueId, String errorMessage) async {
    await _database.updateSyncItemRetry(queueId, errorMessage);
  }

  /// Clear all completed sync items (housekeeping)
  Future<void> clearCompleted() async {
    await _database.clearCompletedSyncItems();
  }

  /// Get count of pending operations
  Future<int> getPendingCount() async {
    final items = await getPendingOperations();
    return items.length;
  }

  /// Check if there are any pending operations
  Future<bool> hasPendingOperations() async {
    final count = await getPendingCount();
    return count > 0;
  }
}
