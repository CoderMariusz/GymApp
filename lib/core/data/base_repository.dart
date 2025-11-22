// ============================================================================
// LifeOS - Base Repository Interface
// ============================================================================
// Used in: Goals, Measurements, Templates, Workouts, etc.
// Token Savings: ~50% (reused across all CRUD operations)
// ============================================================================

import 'package:gymapp/core/error/result.dart';

/// Base repository interface for CRUD operations
///
/// Provides standard Create, Read, Update, Delete operations with:
/// - Result type for error handling
/// - Async operations
/// - Generic type support
/// - Offline-first capability hooks
///
/// Usage:
/// ```dart
/// class GoalsRepository extends BaseRepository<Goal, String> {
///   @override
///   Future<Result<Goal>> create(Goal entity) async {
///     // Implementation
///   }
/// }
/// ```
abstract class BaseRepository<T, ID> {
  /// Creates a new entity
  ///
  /// Returns:
  /// - Success with created entity (including generated ID)
  /// - Failure with error details
  Future<Result<T>> create(T entity);

  /// Retrieves a single entity by ID
  ///
  /// Returns:
  /// - Success with entity if found
  /// - Failure if not found or error occurred
  Future<Result<T>> getById(ID id);

  /// Retrieves all entities
  ///
  /// Optional filters can be provided via [params]
  ///
  /// Returns:
  /// - Success with list of entities (can be empty)
  /// - Failure if error occurred
  Future<Result<List<T>>> getAll({Map<String, dynamic>? params});

  /// Updates an existing entity
  ///
  /// Returns:
  /// - Success with updated entity
  /// - Failure if not found or error occurred
  Future<Result<T>> update(T entity);

  /// Deletes an entity by ID
  ///
  /// Returns:
  /// - Success with void
  /// - Failure if not found or error occurred
  Future<Result<void>> delete(ID id);

  /// Checks if entity exists by ID
  ///
  /// Returns:
  /// - Success with boolean
  /// - Failure if error occurred
  Future<Result<bool>> exists(ID id);

  /// Counts total entities
  ///
  /// Optional filters via [params]
  ///
  /// Returns:
  /// - Success with count
  /// - Failure if error occurred
  Future<Result<int>> count({Map<String, dynamic>? params});
}

/// Extended repository with batch operations
abstract class BatchRepository<T, ID> extends BaseRepository<T, ID> {
  /// Creates multiple entities in a single transaction
  Future<Result<List<T>>> createBatch(List<T> entities);

  /// Updates multiple entities in a single transaction
  Future<Result<List<T>>> updateBatch(List<T> entities);

  /// Deletes multiple entities by IDs in a single transaction
  Future<Result<void>> deleteBatch(List<ID> ids);
}

/// Repository with search capabilities
abstract class SearchableRepository<T, ID> extends BaseRepository<T, ID> {
  /// Searches entities by query string
  ///
  /// Searches across relevant text fields
  ///
  /// Returns:
  /// - Success with matching entities
  /// - Failure if error occurred
  Future<Result<List<T>>> search(
    String query, {
    Map<String, dynamic>? filters,
  });

  /// Filters entities by specific criteria
  Future<Result<List<T>>> filter(Map<String, dynamic> criteria);
}

/// Repository with pagination support
abstract class PaginatedRepository<T, ID> extends BaseRepository<T, ID> {
  /// Gets paginated results
  ///
  /// Parameters:
  /// - [page]: Page number (0-indexed)
  /// - [pageSize]: Number of items per page
  /// - [params]: Optional filters/sorting
  ///
  /// Returns:
  /// - Success with PaginatedResult
  /// - Failure if error occurred
  Future<Result<PaginatedResult<T>>> getPaginated({
    required int page,
    required int pageSize,
    Map<String, dynamic>? params,
  });
}

/// Result wrapper for paginated queries
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  }) : hasMore = (page + 1) * pageSize < totalCount;

  int get totalPages => (totalCount / pageSize).ceil();
  bool get isFirstPage => page == 0;
  bool get isLastPage => !hasMore;
}

/// Repository with sorting capabilities
abstract class SortableRepository<T, ID> extends BaseRepository<T, ID> {
  /// Gets all entities sorted by field
  ///
  /// Parameters:
  /// - [sortBy]: Field name to sort by
  /// - [ascending]: Sort order (true = ascending, false = descending)
  ///
  /// Returns:
  /// - Success with sorted entities
  /// - Failure if error occurred
  Future<Result<List<T>>> getAllSorted({
    required String sortBy,
    bool ascending = true,
    Map<String, dynamic>? filters,
  });
}

/// Full-featured repository with all capabilities
abstract class FullRepository<T, ID>
    implements
        BatchRepository<T, ID>,
        SearchableRepository<T, ID>,
        PaginatedRepository<T, ID>,
        SortableRepository<T, ID> {
  // Combines all repository capabilities
}

/// Mixin for repositories that need offline sync
mixin OfflineSyncMixin<T, ID> on BaseRepository<T, ID> {
  /// Marks entity as pending sync
  Future<Result<void>> markForSync(ID id);

  /// Gets all entities pending sync
  Future<Result<List<T>>> getPendingSync();

  /// Marks entity as synced
  Future<Result<void>> markAsSynced(ID id);
}

/// Mixin for repositories with soft delete
mixin SoftDeleteMixin<T, ID> on BaseRepository<T, ID> {
  /// Soft deletes entity (marks as deleted without removing)
  Future<Result<void>> softDelete(ID id);

  /// Restores soft deleted entity
  Future<Result<void>> restore(ID id);

  /// Gets all soft deleted entities
  Future<Result<List<T>>> getDeleted();

  /// Permanently deletes entity (hard delete)
  Future<Result<void>> hardDelete(ID id);
}

/// Mixin for repositories with timestamps
mixin TimestampMixin<T, ID> on BaseRepository<T, ID> {
  /// Gets entities created after date
  Future<Result<List<T>>> getCreatedAfter(DateTime date);

  /// Gets entities updated after date
  Future<Result<List<T>>> getUpdatedAfter(DateTime date);

  /// Gets entities created between dates
  Future<Result<List<T>>> getCreatedBetween(DateTime start, DateTime end);
}
