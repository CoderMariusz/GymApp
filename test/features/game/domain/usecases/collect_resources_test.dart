import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/domain/entities/building.dart';
import 'package:lifeos/features/game/domain/entities/player_economy.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';
import 'package:lifeos/features/game/domain/usecases/collect_resources.dart';

void main() {
  group('CollectResourcesUseCase', () {
    late CollectResourcesUseCase useCase;
    late PlayerEconomy playerEconomy;
    late Building building;
    late DateTime testTime;

    setUp(() {
      useCase = CollectResourcesUseCase();
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
      ).copyWith(
        lastCollectionTime: testTime.subtract(const Duration(hours: 1)),
      );
    });

    group('Single Building Collection', () {
      test('should successfully collect resources from ready building', () {
        // Building has accumulated resources over 1 hour
        final result = useCase.execute(
          building: building,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        expect(result.success, true);
        expect(result.collectedAmount, greaterThan(0));
        expect(result.error, isNull);
        expect(result.building.accumulatedResources, 0);
        expect(result.building.lastCollectionTime, testTime);
      });

      test('should add collected resources to player economy', () {
        final initialGold = playerEconomy.getResourceAmount(ResourceType.gold);

        final result = useCase.execute(
          building: building,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        final finalGold = result.playerEconomy.getResourceAmount(ResourceType.gold);
        expect(finalGold, initialGold + result.collectedAmount);
      });

      test('should calculate correct accumulated amount based on time', () {
        // 1 hour = 3600 seconds
        // Level 1 mine: 10 * 1 * 1.5 = 15 per hour
        final oneHourLater = building.lastCollectionTime.add(const Duration(hours: 1));

        final result = useCase.execute(
          building: building,
          playerEconomy: playerEconomy,
          currentTime: oneHourLater,
        );

        expect(result.collectedAmount, 15); // 15 resources in 1 hour
      });

      test('should fail if building is not ready', () {
        final upgradingBuilding = building.copyWith(
          status: BuildingStatus.upgrading,
        );

        final result = useCase.execute(
          building: upgradingBuilding,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        expect(result.success, false);
        expect(result.error, contains('not ready'));
        expect(result.collectedAmount, 0);
      });

      test('should fail if no resources to collect', () {
        final result = useCase.execute(
          building: building,
          playerEconomy: playerEconomy,
          currentTime: building.lastCollectionTime, // Same time
        );

        expect(result.success, false);
        expect(result.error, contains('No resources'));
        expect(result.collectedAmount, 0);
      });

      test('should respect building storage capacity', () {
        // Wait way longer than needed to fill storage
        final wayLater = building.lastCollectionTime.add(const Duration(days: 10));

        final result = useCase.execute(
          building: building,
          playerEconomy: playerEconomy,
          currentTime: wayLater,
        );

        expect(result.collectedAmount, lessThanOrEqualTo(building.storageCapacity));
      });

      test('should handle partial collection when player storage is nearly full', () {
        // Fill player gold storage almost to capacity
        final nearFullEconomy = playerEconomy.addResource(
          ResourceType.gold,
          990, // Capacity is 1000, so 10 space left
        );

        // Building has 50 resources to collect
        final buildingWithResources = building.copyWith(
          accumulatedResources: 50,
          lastCollectionTime: testTime,
        );

        final result = useCase.execute(
          building: buildingWithResources,
          playerEconomy: nearFullEconomy,
          currentTime: testTime,
        );

        expect(result.success, true);
        expect(result.collectedAmount, 10); // Only what fits
        expect(result.building.accumulatedResources, 40); // Remainder stays
      });

      test('should fail if player storage is completely full', () {
        final fullEconomy = playerEconomy.addResource(
          ResourceType.gold,
          1000, // At capacity
        );

        final buildingWithResources = building.copyWith(
          accumulatedResources: 50,
          lastCollectionTime: testTime,
        );

        final result = useCase.execute(
          building: buildingWithResources,
          playerEconomy: fullEconomy,
          currentTime: testTime,
        );

        expect(result.success, false);
        expect(result.error, contains('storage is full'));
      });

      test('should collect correct resource type based on building type', () {
        final lumberMill = building.copyWith(
          type: BuildingType.lumberMill,
        );

        final initialWood = playerEconomy.getResourceAmount(ResourceType.wood);

        final result = useCase.execute(
          building: lumberMill,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        final finalWood = result.playerEconomy.getResourceAmount(ResourceType.wood);
        expect(finalWood, greaterThan(initialWood));
      });

      test('should handle building with pre-accumulated resources', () {
        final buildingWithAccumulated = building.copyWith(
          accumulatedResources: 25,
          lastCollectionTime: testTime.subtract(const Duration(minutes: 30)),
        );

        final result = useCase.execute(
          building: buildingWithAccumulated,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        // Should collect pre-accumulated + new production
        expect(result.collectedAmount, greaterThan(25));
      });
    });

    group('Multiple Building Collection', () {
      test('should collect from multiple buildings', () {
        final buildings = [
          building,
          building.copyWith(id: 'building2', gridX: 6),
          building.copyWith(id: 'building3', gridX: 7),
        ];

        final results = useCase.executeMultiple(
          buildings: buildings,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        expect(results.length, 3);
        expect(results.values.every((r) => r.success), true);
      });

      test('should update economy progressively for multiple buildings', () {
        final buildings = [
          building.copyWith(id: 'b1', accumulatedResources: 10),
          building.copyWith(id: 'b2', accumulatedResources: 20),
          building.copyWith(id: 'b3', accumulatedResources: 30),
        ];

        final results = useCase.executeMultiple(
          buildings: buildings,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        // Last result should have all resources added
        final lastResult = results['b3']!;
        expect(
          lastResult.playerEconomy.getResourceAmount(ResourceType.gold),
          playerEconomy.getResourceAmount(ResourceType.gold) + 60,
        );
      });

      test('should handle mixed success/failure in multiple collection', () {
        final buildings = [
          building.copyWith(id: 'b1', accumulatedResources: 10),
          building.copyWith(
            id: 'b2',
            status: BuildingStatus.upgrading, // Will fail
          ),
          building.copyWith(id: 'b3', accumulatedResources: 30),
        ];

        final results = useCase.executeMultiple(
          buildings: buildings,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        expect(results['b1']!.success, true);
        expect(results['b2']!.success, false);
        expect(results['b3']!.success, true);
      });

      test('should stop adding to economy when storage becomes full', () {
        final nearFullEconomy = playerEconomy.addResource(
          ResourceType.gold,
          980, // 20 space left
        );

        final buildings = [
          building.copyWith(id: 'b1', accumulatedResources: 10), // Fits
          building.copyWith(id: 'b2', accumulatedResources: 10), // Fits
          building.copyWith(id: 'b3', accumulatedResources: 10), // Won't fit
        ];

        final results = useCase.executeMultiple(
          buildings: buildings,
          playerEconomy: nearFullEconomy,
          currentTime: testTime,
        );

        expect(results['b1']!.success, true);
        expect(results['b2']!.success, true);
        expect(results['b3']!.success, false);
      });
    });

    group('Collect All Ready', () {
      test('should filter and collect only ready buildings', () {
        final buildings = [
          building.copyWith(
            id: 'b1',
            status: BuildingStatus.ready,
            accumulatedResources: 10,
          ),
          building.copyWith(
            id: 'b2',
            status: BuildingStatus.upgrading, // Not ready
            accumulatedResources: 20,
          ),
          building.copyWith(
            id: 'b3',
            status: BuildingStatus.ready,
            accumulatedResources: 0, // No resources
          ),
          building.copyWith(
            id: 'b4',
            status: BuildingStatus.ready,
            accumulatedResources: 30,
          ),
        ];

        final results = useCase.collectAllReady(
          buildings: buildings,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        // Should only collect from b1 and b4
        expect(results.length, 2);
        expect(results.containsKey('b1'), true);
        expect(results.containsKey('b4'), true);
        expect(results.containsKey('b2'), false);
        expect(results.containsKey('b3'), false);
      });

      test('should return empty map if no buildings are ready', () {
        final buildings = [
          building.copyWith(
            id: 'b1',
            status: BuildingStatus.upgrading,
          ),
          building.copyWith(
            id: 'b2',
            accumulatedResources: 0,
          ),
        ];

        final results = useCase.collectAllReady(
          buildings: buildings,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        expect(results.isEmpty, true);
      });

      test('should collect from buildings with different resource types', () {
        final buildings = [
          building.copyWith(
            id: 'mine',
            type: BuildingType.mine,
            accumulatedResources: 10,
          ),
          building.copyWith(
            id: 'lumber',
            type: BuildingType.lumberMill,
            accumulatedResources: 15,
          ),
          building.copyWith(
            id: 'quarry',
            type: BuildingType.quarry,
            accumulatedResources: 20,
          ),
        ];

        final results = useCase.collectAllReady(
          buildings: buildings,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        expect(results.length, 3);

        final finalEconomy = results['quarry']!.playerEconomy;
        expect(
          finalEconomy.getResourceAmount(ResourceType.gold),
          playerEconomy.getResourceAmount(ResourceType.gold) + 10,
        );
        expect(
          finalEconomy.getResourceAmount(ResourceType.wood),
          playerEconomy.getResourceAmount(ResourceType.wood) + 15,
        );
        expect(
          finalEconomy.getResourceAmount(ResourceType.stone),
          playerEconomy.getResourceAmount(ResourceType.stone) + 20,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle building at exactly storage capacity', () {
        final fullBuilding = building.copyWith(
          accumulatedResources: building.storageCapacity,
          lastCollectionTime: testTime,
        );

        final result = useCase.execute(
          building: fullBuilding,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        expect(result.success, true);
        expect(result.collectedAmount, building.storageCapacity);
      });

      test('should handle zero-capacity player storage', () {
        // Create economy with zero capacity (unlimited)
        final zeroCapEconomy = playerEconomy.updateCapacity(ResourceType.gold, 0);

        final buildingWithResources = building.copyWith(
          accumulatedResources: 1000,
          lastCollectionTime: testTime,
        );

        final result = useCase.execute(
          building: buildingWithResources,
          playerEconomy: zeroCapEconomy,
          currentTime: testTime,
        );

        expect(result.success, true);
        expect(result.collectedAmount, 1000);
      });

      test('should handle very small time differences', () {
        final oneSecondLater = building.lastCollectionTime.add(
          const Duration(seconds: 1),
        );

        final result = useCase.execute(
          building: building,
          playerEconomy: playerEconomy,
          currentTime: oneSecondLater,
        );

        // Level 1 mine: 15 per hour = 0.004166... per second
        // Should still collect something (or 0 if rounded down)
        expect(result.collectedAmount, greaterThanOrEqualTo(0));
      });

      test('should handle buildings with different levels', () {
        final highLevelBuilding = building.copyWith(
          level: 5,
          lastCollectionTime: testTime.subtract(const Duration(hours: 1)),
        );

        final result = useCase.execute(
          building: highLevelBuilding,
          playerEconomy: playerEconomy,
          currentTime: testTime,
        );

        // Higher level = more production
        expect(result.collectedAmount, greaterThan(15)); // More than level 1
      });
    });
  });
}
