import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/domain/entities/building.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';

void main() {
  group('BuildingType', () {
    test('should have correct values and resource mappings', () {
      expect(BuildingType.mine.value, 'mine');
      expect(BuildingType.mine.displayName, 'Mine');
      expect(BuildingType.mine.producedResource, ResourceType.gold);

      expect(BuildingType.lumberMill.producedResource, ResourceType.wood);
      expect(BuildingType.quarry.producedResource, ResourceType.stone);
      expect(BuildingType.farm.producedResource, ResourceType.food);
      expect(BuildingType.gemMine.producedResource, ResourceType.gems);
    });

    test('should create BuildingType from string', () {
      expect(BuildingType.fromString('mine'), BuildingType.mine);
      expect(BuildingType.fromString('lumber_mill'), BuildingType.lumberMill);
      expect(BuildingType.fromString('invalid'), BuildingType.mine); // Default
    });
  });

  group('Building', () {
    late Building building;
    late DateTime testTime;

    setUp(() {
      testTime = DateTime(2024, 1, 1, 12, 0, 0);
      building = Building(
        id: 'building1',
        type: BuildingType.mine,
        level: 1,
        gridX: 5,
        gridY: 5,
        status: BuildingStatus.ready,
        lastCollectionTime: testTime,
        accumulatedResources: 0,
      );
    });

    group('Production Rates', () {
      test('should calculate production rate per hour based on level', () {
        final level1 = building;
        expect(level1.productionRatePerHour, 15); // 10 * 1 * 1.5

        final level2 = building.copyWith(level: 2);
        expect(level2.productionRatePerHour, 30); // 10 * 2 * 1.5

        final level5 = building.copyWith(level: 5);
        expect(level5.productionRatePerHour, 75); // 10 * 5 * 1.5
      });

      test('should calculate production rate per second', () {
        final rate = building.productionRatePerSecond;
        expect(rate, closeTo(15 / 3600, 0.0001)); // ~0.00416
      });
    });

    group('Storage', () {
      test('should calculate storage capacity based on level', () {
        final level1 = building;
        expect(level1.storageCapacity, 100); // 100 * 1 * 1

        final level2 = building.copyWith(level: 2);
        expect(level2.storageCapacity, 400); // 100 * 2 * 2

        final level5 = building.copyWith(level: 5);
        expect(level5.storageCapacity, 2500); // 100 * 5 * 5
      });

      test('should detect when at capacity', () {
        final oneHourLater = testTime.add(const Duration(days: 10)); // Way over capacity

        expect(building.isAtCapacity(oneHourLater), true);
      });

      test('should calculate fill percentage', () {
        final buildingWithResources = building.copyWith(
          accumulatedResources: 50,
        );

        final percentage = buildingWithResources.getFillPercentage(testTime);
        expect(percentage, 0.5); // 50 / 100 capacity
      });

      test('should calculate time until full', () {
        final timeUntilFull = building.timeUntilFull(testTime);

        expect(timeUntilFull, isNotNull);
        // Level 1: 15 per hour, 100 capacity = ~6.67 hours
        expect(timeUntilFull!.inHours, closeTo(6, 1));
      });

      test('should return zero duration when already full', () {
        final fullBuilding = building.copyWith(
          accumulatedResources: building.storageCapacity,
        );

        final timeUntilFull = fullBuilding.timeUntilFull(testTime);
        expect(timeUntilFull, Duration.zero);
      });
    });

    group('Resource Accumulation', () {
      test('should calculate accumulated resources over time', () {
        final oneHourLater = testTime.add(const Duration(hours: 1));
        final accumulated = building.calculateAccumulatedResources(oneHourLater);

        expect(accumulated, 15); // 15 per hour at level 1
      });

      test('should include pre-accumulated resources', () {
        final buildingWithBase = building.copyWith(
          accumulatedResources: 25,
        );

        final oneHourLater = testTime.add(const Duration(hours: 1));
        final accumulated = buildingWithBase.calculateAccumulatedResources(oneHourLater);

        expect(accumulated, 40); // 25 + 15
      });

      test('should clamp to storage capacity', () {
        final wayLater = testTime.add(const Duration(days: 10));
        final accumulated = building.calculateAccumulatedResources(wayLater);

        expect(accumulated, lessThanOrEqualTo(building.storageCapacity));
        expect(accumulated, building.storageCapacity); // Should be exactly at capacity
      });

      test('should handle zero time difference', () {
        final accumulated = building.calculateAccumulatedResources(testTime);
        expect(accumulated, 0);
      });
    });

    group('Collection', () {
      test('should detect when building can collect', () {
        final oneHourLater = testTime.add(const Duration(hours: 1));
        expect(building.canCollect(oneHourLater), true);
      });

      test('should not allow collection from upgrading building', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final oneHourLater = testTime.add(const Duration(hours: 1));
        expect(upgradingBuilding.canCollect(oneHourLater), false);
      });

      test('should collect and reset accumulated resources', () {
        final buildingWithResources = building.copyWith(
          accumulatedResources: 50,
        );

        final now = DateTime.now();
        final collected = buildingWithResources.collect(now);

        expect(collected.accumulatedResources, 0);
        expect(collected.lastCollectionTime, now);
      });
    });

    group('Upgrade Cost', () {
      test('should calculate upgrade cost based on level', () {
        final level1Cost = building.upgradeCost;
        expect(level1Cost[ResourceType.gold], 50); // 50 * 1 * 1

        final level2Building = building.copyWith(level: 2);
        final level2Cost = level2Building.upgradeCost;
        expect(level2Cost[ResourceType.gold], 200); // 50 * 2 * 2

        final level5Building = building.copyWith(level: 5);
        final level5Cost = level5Building.upgradeCost;
        expect(level5Cost[ResourceType.gold], 1250); // 50 * 5 * 5
      });

      test('should include wood and stone in upgrade cost', () {
        final cost = building.upgradeCost;

        expect(cost[ResourceType.gold], isNotNull);
        expect(cost[ResourceType.wood], isNotNull);
        expect(cost[ResourceType.stone], isNotNull);
      });

      test('should have wood and stone cost as half of gold cost', () {
        final cost = building.upgradeCost;
        final goldCost = cost[ResourceType.gold]!;

        expect(cost[ResourceType.wood], (goldCost * 0.5).round());
        expect(cost[ResourceType.stone], (goldCost * 0.5).round());
      });
    });

    group('Upgrade Duration', () {
      test('should calculate upgrade duration based on level', () {
        expect(building.upgradeDurationSeconds, 60); // 60 * 1

        final level5 = building.copyWith(level: 5);
        expect(level5.upgradeDurationSeconds, 300); // 60 * 5
      });
    });

    group('Upgrade Mechanics', () {
      test('should start upgrade', () {
        final upgraded = building.startUpgrade();

        expect(upgraded.status, BuildingStatus.upgrading);
        expect(upgraded.level, building.level); // Level unchanged
      });

      test('should complete upgrade and increment level', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final completed = upgradingBuilding.completeUpgrade();

        expect(completed.level, building.level + 1);
        expect(completed.status, BuildingStatus.ready);
      });

      test('should check if building can be upgraded', () {
        expect(building.canUpgrade, true);

        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );
        expect(upgradingBuilding.canUpgrade, false);

        final maxLevelBuilding = building.copyWith(level: Building.maxLevel);
        expect(maxLevelBuilding.canUpgrade, false);
      });
    });

    group('Building Properties', () {
      test('should have max level constant', () {
        expect(Building.maxLevel, 10);
      });

      test('should get produced resource type from building type', () {
        expect(building.producedResourceType, ResourceType.gold);

        final lumberMill = building.copyWith(type: BuildingType.lumberMill);
        expect(lumberMill.producedResourceType, ResourceType.wood);
      });

      test('should maintain grid position', () {
        expect(building.gridX, 5);
        expect(building.gridY, 5);
      });
    });

    group('Different Building Types', () {
      test('all building types should produce different resources', () {
        final types = BuildingType.values;
        final producedResources = types.map((t) => t.producedResource).toSet();

        expect(producedResources.length, types.length); // All unique
      });

      test('should create different building types', () {
        final mine = building;
        final lumber = building.copyWith(type: BuildingType.lumberMill);
        final quarry = building.copyWith(type: BuildingType.quarry);
        final farm = building.copyWith(type: BuildingType.farm);
        final gemMine = building.copyWith(type: BuildingType.gemMine);

        expect(mine.type, BuildingType.mine);
        expect(lumber.type, BuildingType.lumberMill);
        expect(quarry.type, BuildingType.quarry);
        expect(farm.type, BuildingType.farm);
        expect(gemMine.type, BuildingType.gemMine);
      });
    });

    group('Edge Cases', () {
      test('should handle very high levels', () {
        final level10 = building.copyWith(level: 10);

        expect(level10.productionRatePerHour, 150); // 10 * 10 * 1.5
        expect(level10.storageCapacity, 10000); // 100 * 10 * 10
        expect(level10.upgradeCost[ResourceType.gold], 5000); // 50 * 10 * 10
      });

      test('should handle fractional seconds in production', () {
        // Production rate per second might be fractional
        final rate = building.productionRatePerSecond;
        expect(rate, isA<double>());
        expect(rate, greaterThan(0));
      });

      test('should handle same-time collection', () {
        final accumulated = building.calculateAccumulatedResources(
          building.lastCollectionTime,
        );
        expect(accumulated, 0);
      });
    });
  });
}
