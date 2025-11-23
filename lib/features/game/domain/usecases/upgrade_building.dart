import 'package:lifeos/features/game/domain/entities/building.dart';
import 'package:lifeos/features/game/domain/entities/player_economy.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';

/// Result of building upgrade
class UpgradeBuildingResult {
  const UpgradeBuildingResult({
    required this.success,
    required this.building,
    required this.playerEconomy,
    this.upgradeStartTime,
    this.error,
  });

  final bool success;
  final Building building;
  final PlayerEconomy playerEconomy;
  final DateTime? upgradeStartTime;
  final String? error;

  factory UpgradeBuildingResult.success({
    required Building building,
    required PlayerEconomy playerEconomy,
    required DateTime upgradeStartTime,
  }) {
    return UpgradeBuildingResult(
      success: true,
      building: building,
      playerEconomy: playerEconomy,
      upgradeStartTime: upgradeStartTime,
    );
  }

  factory UpgradeBuildingResult.failure({
    required Building building,
    required PlayerEconomy playerEconomy,
    required String error,
  }) {
    return UpgradeBuildingResult(
      success: false,
      building: building,
      playerEconomy: playerEconomy,
      error: error,
    );
  }
}

/// Use case for upgrading a building
class UpgradeBuildingUseCase {
  /// Start upgrading a building
  ///
  /// Parameters:
  /// - [building]: The building to upgrade
  /// - [playerEconomy]: Current player economy state
  /// - [currentTime]: Current time (defaults to DateTime.now())
  ///
  /// Returns:
  /// - [UpgradeBuildingResult] containing updated building, economy, and result status
  UpgradeBuildingResult startUpgrade({
    required Building building,
    required PlayerEconomy playerEconomy,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    // Check if building can be upgraded
    if (!building.canUpgrade) {
      if (building.level >= Building.maxLevel) {
        return UpgradeBuildingResult.failure(
          building: building,
          playerEconomy: playerEconomy,
          error: 'Building is already at max level (${Building.maxLevel})',
        );
      }

      return UpgradeBuildingResult.failure(
        building: building,
        playerEconomy: playerEconomy,
        error: 'Building is not ready to upgrade. Status: ${building.status}',
      );
    }

    // Get upgrade cost
    final upgradeCost = building.upgradeCost;

    // Check if player can afford the upgrade
    if (!playerEconomy.canAfford(upgradeCost)) {
      final missingResources = <String>[];

      for (final entry in upgradeCost.entries) {
        final required = entry.value;
        final current = playerEconomy.getResourceAmount(entry.key);

        if (current < required) {
          final missing = required - current;
          missingResources.add(
            '${entry.key.displayName}: need $missing more (have $current, need $required)',
          );
        }
      }

      return UpgradeBuildingResult.failure(
        building: building,
        playerEconomy: playerEconomy,
        error: 'Insufficient resources. Missing: ${missingResources.join(", ")}',
      );
    }

    // Deduct resources from player economy
    final updatedEconomy = playerEconomy.subtractResources(upgradeCost);

    // Start building upgrade
    final updatedBuilding = building.startUpgrade();

    return UpgradeBuildingResult.success(
      building: updatedBuilding,
      playerEconomy: updatedEconomy,
      upgradeStartTime: now,
    );
  }

  /// Complete a building upgrade
  ///
  /// Should be called after upgrade duration has elapsed.
  ///
  /// Parameters:
  /// - [building]: The building being upgraded
  /// - [upgradeStartTime]: When the upgrade started
  /// - [currentTime]: Current time (defaults to DateTime.now())
  ///
  /// Returns:
  /// - [Building] with completed upgrade, or original if upgrade not complete
  Building? completeUpgrade({
    required Building building,
    required DateTime upgradeStartTime,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    // Check if building is upgrading
    if (building.status != BuildingStatus.upgrading) {
      return null;
    }

    // Calculate required upgrade duration
    final upgradeDuration = Duration(seconds: building.upgradeDurationSeconds);
    final upgradeCompleteTime = upgradeStartTime.add(upgradeDuration);

    // Check if upgrade is complete
    if (now.isBefore(upgradeCompleteTime)) {
      return null; // Upgrade not yet complete
    }

    // Complete the upgrade
    return building.completeUpgrade();
  }

  /// Get remaining time for upgrade completion
  ///
  /// Returns null if building is not upgrading or upgrade is complete
  Duration? getRemainingUpgradeTime({
    required Building building,
    required DateTime upgradeStartTime,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    if (building.status != BuildingStatus.upgrading) {
      return null;
    }

    final upgradeDuration = Duration(seconds: building.upgradeDurationSeconds);
    final upgradeCompleteTime = upgradeStartTime.add(upgradeDuration);

    if (now.isAfter(upgradeCompleteTime)) {
      return Duration.zero; // Upgrade complete
    }

    return upgradeCompleteTime.difference(now);
  }

  /// Check if upgrade is complete
  bool isUpgradeComplete({
    required Building building,
    required DateTime upgradeStartTime,
    DateTime? currentTime,
  }) {
    final remaining = getRemainingUpgradeTime(
      building: building,
      upgradeStartTime: upgradeStartTime,
      currentTime: currentTime,
    );

    return remaining == Duration.zero;
  }

  /// Instant upgrade (for testing or premium features)
  ///
  /// Skips the time requirement and completes upgrade immediately
  UpgradeBuildingResult instantUpgrade({
    required Building building,
    required PlayerEconomy playerEconomy,
    DateTime? currentTime,
  }) {
    final startResult = startUpgrade(
      building: building,
      playerEconomy: playerEconomy,
      currentTime: currentTime,
    );

    if (!startResult.success) {
      return startResult;
    }

    // Immediately complete the upgrade
    final completedBuilding = startResult.building.completeUpgrade();

    return UpgradeBuildingResult.success(
      building: completedBuilding,
      playerEconomy: startResult.playerEconomy,
      upgradeStartTime: startResult.upgradeStartTime!,
    );
  }

  /// Get total cost to upgrade building to target level
  ///
  /// Calculates cumulative cost from current level to target level
  Map<ResourceType, int> getTotalUpgradeCost({
    required Building building,
    required int targetLevel,
  }) {
    if (targetLevel <= building.level || targetLevel > Building.maxLevel) {
      return {};
    }

    final totalCost = <ResourceType, int>{
      ResourceType.gold: 0,
      ResourceType.wood: 0,
      ResourceType.stone: 0,
    };

    var currentBuilding = building;

    while (currentBuilding.level < targetLevel) {
      final cost = currentBuilding.upgradeCost;

      for (final entry in cost.entries) {
        totalCost[entry.key] = (totalCost[entry.key] ?? 0) + entry.value;
      }

      // Simulate upgrade
      currentBuilding = currentBuilding.copyWith(level: currentBuilding.level + 1);
    }

    return totalCost;
  }

  /// Check if player can afford to upgrade to target level
  bool canAffordUpgradeToLevel({
    required Building building,
    required PlayerEconomy playerEconomy,
    required int targetLevel,
  }) {
    final totalCost = getTotalUpgradeCost(
      building: building,
      targetLevel: targetLevel,
    );

    return playerEconomy.canAfford(totalCost);
  }
}
