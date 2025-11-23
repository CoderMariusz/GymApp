import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/city_builder/domain/entities/building.dart';
import 'package:lifeos/features/city_builder/domain/entities/player_economy.dart';

/// Use case for collecting resources from a building
class CollectResourcesUseCase {
  /// Execute the collect resources use case
  ///
  /// Returns updated [PlayerEconomy] with collected resources added
  /// Throws [BuildingNotFoundException] if building doesn't exist
  /// Throws [NoResourcesAvailableException] if nothing to collect
  Result<CollectResourcesResult> execute({
    required Building building,
    required PlayerEconomy playerEconomy,
    DateTime? currentTime,
  }) {
    try {
      final now = currentTime ?? DateTime.now();

      // Calculate resources produced since last collection
      final producedResources = building.calculateProducedResources(now);

      // Check if there are any resources to collect
      if (producedResources.isEmpty ||
          producedResources.values.every((amount) => amount == 0)) {
        return Result.failure(
          NoResourcesAvailableException(buildingId: building.id),
        );
      }

      // Add produced resources to player economy
      final updatedEconomy = playerEconomy.addResources(producedResources);

      // Update building's last collection time
      final updatedBuilding = building.copyWith(
        lastCollectionTime: now,
        updatedAt: now,
      );

      return Result.success(
        CollectResourcesResult(
          playerEconomy: updatedEconomy,
          building: updatedBuilding,
          collectedResources: producedResources,
        ),
      );
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }

  /// Batch collect resources from multiple buildings
  Result<BatchCollectResourcesResult> executeBatch({
    required List<Building> buildings,
    required PlayerEconomy playerEconomy,
    DateTime? currentTime,
  }) {
    try {
      final now = currentTime ?? DateTime.now();
      var currentEconomy = playerEconomy;
      final updatedBuildings = <Building>[];
      final allCollectedResources = <String, int>{};
      final errors = <String, Exception>{};

      for (final building in buildings) {
        final result = execute(
          building: building,
          playerEconomy: currentEconomy,
          currentTime: now,
        );

        result.when(
          success: (data) {
            currentEconomy = data.playerEconomy;
            updatedBuildings.add(data.building);

            // Aggregate collected resources
            data.collectedResources.forEach((resourceType, amount) {
              allCollectedResources[resourceType] =
                  (allCollectedResources[resourceType] ?? 0) + amount;
            });
          },
          failure: (exception) {
            // Track errors but continue processing other buildings
            errors[building.id] = exception;
          },
        );
      }

      return Result.success(
        BatchCollectResourcesResult(
          playerEconomy: currentEconomy,
          buildings: updatedBuildings,
          totalCollectedResources: allCollectedResources,
          errors: errors,
        ),
      );
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }
}

/// Result of collecting resources from a single building
class CollectResourcesResult {
  final PlayerEconomy playerEconomy;
  final Building building;
  final Map<String, int> collectedResources;

  CollectResourcesResult({
    required this.playerEconomy,
    required this.building,
    required this.collectedResources,
  });
}

/// Result of batch collecting resources from multiple buildings
class BatchCollectResourcesResult {
  final PlayerEconomy playerEconomy;
  final List<Building> buildings;
  final Map<String, int> totalCollectedResources;
  final Map<String, Exception> errors;

  BatchCollectResourcesResult({
    required this.playerEconomy,
    required this.buildings,
    required this.totalCollectedResources,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  int get successCount => buildings.length;
  int get failureCount => errors.length;
}

/// Exception thrown when building is not found
class BuildingNotFoundException implements Exception {
  final String buildingId;

  BuildingNotFoundException({required this.buildingId});

  @override
  String toString() =>
      'BuildingNotFoundException: Building with id $buildingId not found';
}

/// Exception thrown when there are no resources available to collect
class NoResourcesAvailableException implements Exception {
  final String buildingId;

  NoResourcesAvailableException({required this.buildingId});

  @override
  String toString() =>
      'NoResourcesAvailableException: No resources available to collect from building $buildingId';
}
