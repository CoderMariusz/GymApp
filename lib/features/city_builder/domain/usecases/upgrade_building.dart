import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/city_builder/domain/entities/building.dart';
import 'package:lifeos/features/city_builder/domain/entities/player_economy.dart';

/// Use case for upgrading a building
class UpgradeBuildingUseCase {
  /// Execute the upgrade building use case
  ///
  /// Returns updated [Building] and [PlayerEconomy] after upgrade
  /// Throws [InsufficientResourcesException] if player can't afford upgrade
  /// Throws [MaxLevelReachedException] if building is at max level
  Result<UpgradeBuildingResult> execute({
    required Building building,
    required PlayerEconomy playerEconomy,
    int? maxLevel,
  }) {
    try {
      // Check if building is at max level
      final effectiveMaxLevel = maxLevel ?? 50; // Default max level is 50
      if (building.level >= effectiveMaxLevel) {
        return Result.failure(
          MaxLevelReachedException(
            buildingId: building.id,
            currentLevel: building.level,
            maxLevel: effectiveMaxLevel,
          ),
        );
      }

      // Check if player has enough resources
      if (!building.canUpgrade(playerEconomy.resources)) {
        return Result.failure(
          InsufficientResourcesException(
            required: building.upgradeCosts,
            available: playerEconomy.resources,
          ),
        );
      }

      // Deduct upgrade costs from player economy
      final updatedEconomy =
          playerEconomy.subtractResources(building.upgradeCosts);

      // Upgrade the building
      final upgradedBuilding = building.upgrade();

      return Result.success(
        UpgradeBuildingResult(
          building: upgradedBuilding,
          playerEconomy: updatedEconomy,
          resourcesSpent: building.upgradeCosts,
          newLevel: upgradedBuilding.level,
        ),
      );
    } on InsufficientResourcesException catch (e) {
      return Result.failure(e);
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }

  /// Check if a building can be upgraded (preview)
  UpgradePreview preview({
    required Building building,
    required PlayerEconomy playerEconomy,
    int? maxLevel,
  }) {
    final effectiveMaxLevel = maxLevel ?? 50;

    // Check max level
    if (building.level >= effectiveMaxLevel) {
      return UpgradePreview(
        canUpgrade: false,
        reason: UpgradeBlockReason.maxLevel,
        missingResources: {},
        nextLevelStats: null,
      );
    }

    // Check resources
    final canAfford = building.canUpgrade(playerEconomy.resources);
    if (!canAfford) {
      final missing = <String, int>{};
      building.upgradeCosts.forEach((type, required) {
        final available = playerEconomy.getResourceAmount(type);
        if (available < required) {
          missing[type] = required - available;
        }
      });

      return UpgradePreview(
        canUpgrade: false,
        reason: UpgradeBlockReason.insufficientResources,
        missingResources: missing,
        nextLevelStats: building.upgrade(),
      );
    }

    return UpgradePreview(
      canUpgrade: true,
      reason: null,
      missingResources: {},
      nextLevelStats: building.upgrade(),
    );
  }

  /// Batch upgrade multiple buildings (if possible)
  Result<BatchUpgradeBuildingResult> executeBatch({
    required List<Building> buildings,
    required PlayerEconomy playerEconomy,
    int? maxLevel,
  }) {
    try {
      var currentEconomy = playerEconomy;
      final upgradedBuildings = <Building>[];
      final totalResourcesSpent = <String, int>{};
      final errors = <String, Exception>{};

      for (final building in buildings) {
        final result = execute(
          building: building,
          playerEconomy: currentEconomy,
          maxLevel: maxLevel,
        );

        result.when(
          success: (data) {
            currentEconomy = data.playerEconomy;
            upgradedBuildings.add(data.building);

            // Aggregate spent resources
            data.resourcesSpent.forEach((resourceType, amount) {
              totalResourcesSpent[resourceType] =
                  (totalResourcesSpent[resourceType] ?? 0) + amount;
            });
          },
          failure: (exception) {
            errors[building.id] = exception;
          },
        );
      }

      return Result.success(
        BatchUpgradeBuildingResult(
          buildings: upgradedBuildings,
          playerEconomy: currentEconomy,
          totalResourcesSpent: totalResourcesSpent,
          errors: errors,
        ),
      );
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }
}

/// Result of upgrading a building
class UpgradeBuildingResult {
  final Building building;
  final PlayerEconomy playerEconomy;
  final Map<String, int> resourcesSpent;
  final int newLevel;

  UpgradeBuildingResult({
    required this.building,
    required this.playerEconomy,
    required this.resourcesSpent,
    required this.newLevel,
  });
}

/// Result of batch upgrading buildings
class BatchUpgradeBuildingResult {
  final List<Building> buildings;
  final PlayerEconomy playerEconomy;
  final Map<String, int> totalResourcesSpent;
  final Map<String, Exception> errors;

  BatchUpgradeBuildingResult({
    required this.buildings,
    required this.playerEconomy,
    required this.totalResourcesSpent,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  int get successCount => buildings.length;
  int get failureCount => errors.length;
}

/// Preview information for an upgrade
class UpgradePreview {
  final bool canUpgrade;
  final UpgradeBlockReason? reason;
  final Map<String, int> missingResources;
  final Building? nextLevelStats;

  UpgradePreview({
    required this.canUpgrade,
    required this.reason,
    required this.missingResources,
    required this.nextLevelStats,
  });
}

/// Reasons why an upgrade might be blocked
enum UpgradeBlockReason {
  maxLevel,
  insufficientResources,
  buildingNotFound,
  upgradeInProgress,
}

/// Exception thrown when building is at max level
class MaxLevelReachedException implements Exception {
  final String buildingId;
  final int currentLevel;
  final int maxLevel;

  MaxLevelReachedException({
    required this.buildingId,
    required this.currentLevel,
    required this.maxLevel,
  });

  @override
  String toString() =>
      'MaxLevelReachedException: Building $buildingId is at max level $maxLevel (current: $currentLevel)';
}
