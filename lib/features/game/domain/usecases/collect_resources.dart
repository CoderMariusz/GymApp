import 'package:lifeos/features/game/domain/entities/building.dart';
import 'package:lifeos/features/game/domain/entities/player_economy.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';

/// Result of resource collection
class CollectResourcesResult {
  const CollectResourcesResult({
    required this.success,
    required this.building,
    required this.playerEconomy,
    this.collectedAmount = 0,
    this.error,
  });

  final bool success;
  final Building building;
  final PlayerEconomy playerEconomy;
  final int collectedAmount;
  final String? error;

  factory CollectResourcesResult.success({
    required Building building,
    required PlayerEconomy playerEconomy,
    required int collectedAmount,
  }) {
    return CollectResourcesResult(
      success: true,
      building: building,
      playerEconomy: playerEconomy,
      collectedAmount: collectedAmount,
    );
  }

  factory CollectResourcesResult.failure({
    required Building building,
    required PlayerEconomy playerEconomy,
    required String error,
  }) {
    return CollectResourcesResult(
      success: false,
      building: building,
      playerEconomy: playerEconomy,
      error: error,
    );
  }
}

/// Use case for collecting resources from a building
class CollectResourcesUseCase {
  /// Execute the use case to collect resources from a building
  ///
  /// Parameters:
  /// - [building]: The building to collect resources from
  /// - [playerEconomy]: Current player economy state
  /// - [currentTime]: Current time (defaults to DateTime.now())
  ///
  /// Returns:
  /// - [CollectResourcesResult] containing updated building, economy, and result status
  CollectResourcesResult execute({
    required Building building,
    required PlayerEconomy playerEconomy,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    // Validate building status
    if (building.status != BuildingStatus.ready) {
      return CollectResourcesResult.failure(
        building: building,
        playerEconomy: playerEconomy,
        error: 'Building is not ready. Status: ${building.status}',
      );
    }

    // Calculate accumulated resources
    final accumulatedAmount = building.calculateAccumulatedResources(now);

    // Check if there are resources to collect
    if (accumulatedAmount <= 0) {
      return CollectResourcesResult.failure(
        building: building,
        playerEconomy: playerEconomy,
        error: 'No resources to collect',
      );
    }

    // Get the resource type produced by this building
    final resourceType = building.producedResourceType;

    // Get current resource from player economy
    final currentResource = playerEconomy.getResource(resourceType);

    // Check if adding resources would exceed capacity
    if (currentResource.wouldExceedCapacity(accumulatedAmount)) {
      // Collect only what fits
      final canCollect = currentResource.availableSpace;

      if (canCollect <= 0) {
        return CollectResourcesResult.failure(
          building: building,
          playerEconomy: playerEconomy,
          error: 'Player ${resourceType.displayName} storage is full',
        );
      }

      // Partial collection
      final updatedBuilding = building.copyWith(
        accumulatedResources: accumulatedAmount - canCollect,
        lastCollectionTime: now,
      );

      final updatedEconomy = playerEconomy.addResource(
        resourceType,
        canCollect,
      );

      return CollectResourcesResult.success(
        building: updatedBuilding,
        playerEconomy: updatedEconomy,
        collectedAmount: canCollect,
      );
    }

    // Full collection
    final updatedBuilding = building.collect(now);
    final updatedEconomy = playerEconomy.addResource(
      resourceType,
      accumulatedAmount,
    );

    return CollectResourcesResult.success(
      building: updatedBuilding,
      playerEconomy: updatedEconomy,
      collectedAmount: accumulatedAmount,
    );
  }

  /// Collect resources from multiple buildings at once
  ///
  /// Parameters:
  /// - [buildings]: List of buildings to collect from
  /// - [playerEconomy]: Current player economy state
  /// - [currentTime]: Current time (defaults to DateTime.now())
  ///
  /// Returns:
  /// - Map of building IDs to collection results
  Map<String, CollectResourcesResult> executeMultiple({
    required List<Building> buildings,
    required PlayerEconomy playerEconomy,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final results = <String, CollectResourcesResult>{};
    var currentEconomy = playerEconomy;

    for (final building in buildings) {
      final result = execute(
        building: building,
        playerEconomy: currentEconomy,
        currentTime: now,
      );

      results[building.id] = result;

      // Update economy for next iteration
      if (result.success) {
        currentEconomy = result.playerEconomy;
      }
    }

    return results;
  }

  /// Collect all ready buildings
  ///
  /// Filters buildings that are ready and have resources to collect,
  /// then collects from all of them.
  Map<String, CollectResourcesResult> collectAllReady({
    required List<Building> buildings,
    required PlayerEconomy playerEconomy,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    final readyBuildings = buildings.where((building) {
      return building.canCollect(now);
    }).toList();

    return executeMultiple(
      buildings: readyBuildings,
      playerEconomy: playerEconomy,
      currentTime: now,
    );
  }
}
