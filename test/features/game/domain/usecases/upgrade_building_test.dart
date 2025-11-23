import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/domain/entities/building.dart';
import 'package:lifeos/features/game/domain/entities/player_economy.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';
import 'package:lifeos/features/game/domain/usecases/upgrade_building.dart';

void main() {
  group('UpgradeBuildingUseCase', () {
    late UpgradeBuildingUseCase useCase;
    late PlayerEconomy playerEconomy;
    late Building building;
    late DateTime testTime;

    setUp(() {
      useCase = UpgradeBuildingUseCase();
      testTime = DateTime(2024, 1, 1, 12, 0, 0);

      playerEconomy = PlayerEconomy.initial('player123');

      building = const Building(
        id: 'building1',
        type: BuildingType.mine,
        level: 1,
        gridX: 5,
        gridY: 5,
        status: BuildingStatus.ready,
        lastCollectionTime: null,
        accumulatedResources: 0,
      ).copyWith(lastCollectionTime: testTime);
    });

    group('Start Upgrade', () {
      test('should successfully start upgrade when conditions are met', () {
        // Ensure player has enough resources
        final richEconomy = playerEconomy
            .addResource(ResourceType.gold, 500)
            .addResource(ResourceType.wood, 500)
            .addResource(ResourceType.stone, 500);

        final result = useCase.startUpgrade(
          building: building,
          playerEconomy: richEconomy,
          currentTime: testTime,
        );

        expect(result.success, true);
        expect(result.building.status, BuildingStatus.upgrading);
        expect(result.upgradeStartTime, testTime);
        expect(result.error, isNull);
      });

      test('should deduct upgrade cost from player economy', () {
        final upgradeCost = building.upgradeCost;

        final richEconomy = playerEconomy
            .addResource(ResourceType.gold, 500)
            .addResource(ResourceType.wood, 500)
            .addResource(ResourceType.stone, 500);

        final initialGold = richEconomy.getResourceAmount(ResourceType.gold);

        final result = useCase.startUpgrade(
          building: building,
          playerEconomy: richEconomy,
          currentTime: testTime,
        );

        final finalGold = result.playerEconomy.getResourceAmount(ResourceType.gold);
        expect(finalGold, initialGold - upgradeCost[ResourceType.gold]!);
      });

      test('should fail if player cannot afford upgrade', () {
        // Player starts with 100 gold, needs 50 for level 1->2 upgrade
        // But also needs wood and stone
        final result = useCase.startUpgrade(
          building: building,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        expect(result.success, false);
        expect(result.error, contains('Insufficient resources'));
        expect(result.building.status, BuildingStatus.ready); // Unchanged
      });

      test('should fail if building is already at max level', () {
        final maxLevelBuilding = building.copyWith(level: Building.maxLevel);

        final richEconomy = playerEconomy
            .addResource(ResourceType.gold, 10000)
            .addResource(ResourceType.wood, 10000)
            .addResource(ResourceType.stone, 10000);

        final result = useCase.startUpgrade(
          building: maxLevelBuilding,
          playerEconomy: richEconomy,
          currentTime: testTime,
        );

        expect(result.success, false);
        expect(result.error, contains('max level'));
      });

      test('should fail if building is not ready', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final richEconomy = playerEconomy
            .addResource(ResourceType.gold, 500)
            .addResource(ResourceType.wood, 500)
            .addResource(ResourceType.stone, 500);

        final result = useCase.startUpgrade(
          building: upgradingBuilding,
          playerEconomy: richEconomy,
          currentTime: testTime,
        );

        expect(result.success, false);
        expect(result.error, contains('not ready'));
      });

      test('should provide detailed error for missing specific resources', () {
        // Player has gold but not enough wood/stone
        final partialEconomy = playerEconomy.addResource(ResourceType.gold, 500);

        final result = useCase.startUpgrade(
          building: building,
          playerEconomy: partialEconomy,
          currentTime: testTime,
        );

        expect(result.success, false);
        expect(result.error, contains('Wood'));
        expect(result.error, contains('Stone'));
      });

      test('should handle upgrade cost that scales with level', () {
        final level1Cost = building.upgradeCost[ResourceType.gold]!;
        final level5Building = building.copyWith(level: 5);
        final level5Cost = level5Building.upgradeCost[ResourceType.gold]!;

        expect(level5Cost, greaterThan(level1Cost));
      });
    });

    group('Complete Upgrade', () {
      test('should complete upgrade after duration elapsed', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final upgradeDuration = Duration(
          seconds: building.upgradeDurationSeconds,
        );
        final completeTime = testTime.add(upgradeDuration);

        final result = useCase.completeUpgrade(
          building: upgradingBuilding,
          upgradeStartTime: testTime,
          currentTime: completeTime,
        );

        expect(result, isNotNull);
        expect(result!.level, building.level + 1);
        expect(result.status, BuildingStatus.ready);
      });

      test('should not complete upgrade before duration elapsed', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final tooEarly = testTime.add(const Duration(seconds: 30));

        final result = useCase.completeUpgrade(
          building: upgradingBuilding,
          upgradeStartTime: testTime,
          currentTime: tooEarly,
        );

        expect(result, isNull); // Not ready yet
      });

      test('should return null if building is not upgrading', () {
        final result = useCase.completeUpgrade(
          building: building, // Status is ready, not upgrading
          upgradeStartTime: testTime,
          currentTime: testTime.add(const Duration(hours: 1)),
        );

        expect(result, isNull);
      });

      test('should complete upgrade exactly at completion time', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final upgradeDuration = Duration(
          seconds: building.upgradeDurationSeconds,
        );
        final exactTime = testTime.add(upgradeDuration);

        final result = useCase.completeUpgrade(
          building: upgradingBuilding,
          upgradeStartTime: testTime,
          currentTime: exactTime,
        );

        expect(result, isNotNull);
      });
    });

    group('Upgrade Time Management', () {
      test('should calculate remaining upgrade time correctly', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final halfwayTime = testTime.add(
          Duration(seconds: building.upgradeDurationSeconds ~/ 2),
        );

        final remaining = useCase.getRemainingUpgradeTime(
          building: upgradingBuilding,
          upgradeStartTime: testTime,
          currentTime: halfwayTime,
        );

        expect(remaining, isNotNull);
        expect(
          remaining!.inSeconds,
          closeTo(building.upgradeDurationSeconds / 2, 1),
        );
      });

      test('should return zero duration when upgrade is complete', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final afterComplete = testTime.add(
          Duration(seconds: building.upgradeDurationSeconds + 10),
        );

        final remaining = useCase.getRemainingUpgradeTime(
          building: upgradingBuilding,
          upgradeStartTime: testTime,
          currentTime: afterComplete,
        );

        expect(remaining, Duration.zero);
      });

      test('should return null for non-upgrading building', () {
        final remaining = useCase.getRemainingUpgradeTime(
          building: building,
          upgradeStartTime: testTime,
          currentTime: testTime,
        );

        expect(remaining, isNull);
      });

      test('should detect when upgrade is complete', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final beforeComplete = testTime.add(const Duration(seconds: 30));
        expect(
          useCase.isUpgradeComplete(
            building: upgradingBuilding,
            upgradeStartTime: testTime,
            currentTime: beforeComplete,
          ),
          false,
        );

        final afterComplete = testTime.add(
          Duration(seconds: building.upgradeDurationSeconds + 1),
        );
        expect(
          useCase.isUpgradeComplete(
            building: upgradingBuilding,
            upgradeStartTime: testTime,
            currentTime: afterComplete,
          ),
          true,
        );
      });
    });

    group('Instant Upgrade', () {
      test('should complete upgrade immediately', () {
        final richEconomy = playerEconomy
            .addResource(ResourceType.gold, 500)
            .addResource(ResourceType.wood, 500)
            .addResource(ResourceType.stone, 500);

        final result = useCase.instantUpgrade(
          building: building,
          playerEconomy: richEconomy,
          currentTime: testTime,
        );

        expect(result.success, true);
        expect(result.building.level, building.level + 1);
        expect(result.building.status, BuildingStatus.ready);
      });

      test('should still deduct resources for instant upgrade', () {
        final upgradeCost = building.upgradeCost;

        final richEconomy = playerEconomy
            .addResource(ResourceType.gold, 500)
            .addResource(ResourceType.wood, 500)
            .addResource(ResourceType.stone, 500);

        final initialGold = richEconomy.getResourceAmount(ResourceType.gold);

        final result = useCase.instantUpgrade(
          building: building,
          playerEconomy: richEconomy,
          currentTime: testTime,
        );

        final finalGold = result.playerEconomy.getResourceAmount(ResourceType.gold);
        expect(finalGold, initialGold - upgradeCost[ResourceType.gold]!);
      });

      test('should fail instant upgrade if cannot afford', () {
        final result = useCase.instantUpgrade(
          building: building,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        expect(result.success, false);
        expect(result.error, contains('Insufficient resources'));
      });
    });

    group('Total Upgrade Cost Calculation', () {
      test('should calculate total cost to upgrade multiple levels', () {
        final targetLevel = 3;
        final totalCost = useCase.getTotalUpgradeCost(
          building: building,
          targetLevel: targetLevel,
        );

        // Should sum costs for level 1->2 and 2->3
        expect(totalCost[ResourceType.gold], greaterThan(0));
        expect(totalCost[ResourceType.wood], greaterThan(0));
        expect(totalCost[ResourceType.stone], greaterThan(0));
      });

      test('should return empty map if target level is current level', () {
        final totalCost = useCase.getTotalUpgradeCost(
          building: building,
          targetLevel: building.level,
        );

        expect(totalCost.isEmpty, true);
      });

      test('should return empty map if target level exceeds max', () {
        final totalCost = useCase.getTotalUpgradeCost(
          building: building,
          targetLevel: Building.maxLevel + 1,
        );

        expect(totalCost.isEmpty, true);
      });

      test('should check if player can afford upgrade to target level', () {
        final richEconomy = playerEconomy
            .addResource(ResourceType.gold, 10000)
            .addResource(ResourceType.wood, 10000)
            .addResource(ResourceType.stone, 10000);

        final canAfford = useCase.canAffordUpgradeToLevel(
          building: building,
          playerEconomy: richEconomy,
          targetLevel: 5,
        );

        expect(canAfford, true);
      });

      test('should detect when player cannot afford target level', () {
        final canAfford = useCase.canAffordUpgradeToLevel(
          building: building,
          playerEconomy: playerEconomy,
          targetLevel: 10,
        );

        expect(canAfford, false);
      });
    });

    group('Edge Cases', () {
      test('should handle upgrading from level 9 to max level 10', () {
        final level9Building = building.copyWith(level: 9);

        final richEconomy = playerEconomy
            .addResource(ResourceType.gold, 50000)
            .addResource(ResourceType.wood, 50000)
            .addResource(ResourceType.stone, 50000);

        final result = useCase.startUpgrade(
          building: level9Building,
          playerEconomy: richEconomy,
          currentTime: testTime,
        );

        expect(result.success, true);

        final completed = useCase.completeUpgrade(
          building: result.building,
          upgradeStartTime: testTime,
          currentTime: testTime.add(
            Duration(seconds: level9Building.upgradeDurationSeconds),
          ),
        );

        expect(completed, isNotNull);
        expect(completed!.level, Building.maxLevel);
      });

      test('should handle very high level buildings with expensive costs', () {
        final highLevelBuilding = building.copyWith(level: 8);
        final cost = highLevelBuilding.upgradeCost;

        // Cost should be significantly higher than level 1
        expect(cost[ResourceType.gold], greaterThan(1000));
      });

      test('should maintain building properties during upgrade', () {
        final richEconomy = playerEconomy
            .addResource(ResourceType.gold, 500)
            .addResource(ResourceType.wood, 500)
            .addResource(ResourceType.stone, 500);

        final result = useCase.startUpgrade(
          building: building,
          playerEconomy: richEconomy,
          currentTime: testTime,
        );

        expect(result.building.id, building.id);
        expect(result.building.type, building.type);
        expect(result.building.gridX, building.gridX);
        expect(result.building.gridY, building.gridY);
      });
    });
  });
}
