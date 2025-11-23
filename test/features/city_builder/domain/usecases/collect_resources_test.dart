import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/city_builder/domain/entities/building.dart';
import 'package:lifeos/features/city_builder/domain/entities/player_economy.dart';
import 'package:lifeos/features/city_builder/domain/usecases/collect_resources.dart';

void main() {
  group('CollectResourcesUseCase', () {
    late CollectResourcesUseCase useCase;
    late Building testBuilding;
    late PlayerEconomy testEconomy;
    final baseTime = DateTime(2025, 1, 1, 12, 0, 0);

    setUp(() {
      useCase = CollectResourcesUseCase();

      testBuilding = Building(
        id: 'building_1',
        type: 'gold_mine',
        level: 1,
        name: 'Gold Mine',
        description: 'Produces gold',
        productionRates: {'gold': 100}, // 100 gold per hour
        upgradeCosts: {'wood': 50},
        upgradeTimeSeconds: 60,
        lastCollectionTime: baseTime,
        createdAt: baseTime,
      );

      testEconomy = PlayerEconomy(
        id: 'economy_1',
        playerId: 'player_1',
        resources: {'gold': 500},
        createdAt: baseTime,
      );
    });

    group('execute - basic functionality', () {
      test('should successfully collect resources after 1 hour', () {
        final currentTime = baseTime.add(const Duration(hours: 1));

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.playerEconomy.resources['gold'], 600); // 500 + 100
            expect(data.collectedResources['gold'], 100);
            expect(data.building.lastCollectionTime, currentTime);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should collect correct amount after 2 hours', () {
        final currentTime = baseTime.add(const Duration(hours: 2));

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.collectedResources['gold'], 200);
            expect(data.playerEconomy.resources['gold'], 700); // 500 + 200
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should collect correct amount after 30 minutes', () {
        final currentTime = baseTime.add(const Duration(minutes: 30));

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.collectedResources['gold'], 50); // 100 * 0.5
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should use current time when not specified', () {
        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        expect(result.isSuccess, isTrue);
      });

      test('should update building lastCollectionTime', () {
        final currentTime = baseTime.add(const Duration(hours: 1));

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.building.lastCollectionTime, currentTime);
            expect(data.building.updatedAt, currentTime);
          },
          failure: (_) => fail('Should succeed'),
        );
      });
    });

    group('execute - multiple resources', () {
      test('should collect multiple resource types', () {
        final multiResourceBuilding = testBuilding.copyWith(
          productionRates: {
            'gold': 100,
            'wood': 50,
            'stone': 25,
          },
        );

        final economy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {
            'gold': 500,
            'wood': 200,
            'stone': 100,
          },
          createdAt: baseTime,
        );

        final currentTime = baseTime.add(const Duration(hours: 1));

        final result = useCase.execute(
          building: multiResourceBuilding,
          playerEconomy: economy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.collectedResources['gold'], 100);
            expect(data.collectedResources['wood'], 50);
            expect(data.collectedResources['stone'], 25);
            expect(data.playerEconomy.resources['gold'], 600);
            expect(data.playerEconomy.resources['wood'], 250);
            expect(data.playerEconomy.resources['stone'], 125);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should add new resource types to economy', () {
        final economy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {}, // No resources initially
          createdAt: baseTime,
        );

        final currentTime = baseTime.add(const Duration(hours: 1));

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: economy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.playerEconomy.resources['gold'], 100);
          },
          failure: (_) => fail('Should succeed'),
        );
      });
    });

    group('execute - edge cases', () {
      test('should fail when no resources available (lastCollectionTime is null)', () {
        final buildingWithoutCollection = testBuilding.copyWith(
          lastCollectionTime: null,
        );

        final result = useCase.execute(
          building: buildingWithoutCollection,
          playerEconomy: testEconomy,
          currentTime: baseTime.add(const Duration(hours: 1)),
        );

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('Should fail'),
          failure: (exception) {
            expect(exception, isA<NoResourcesAvailableException>());
          },
        );
      });

      test('should fail when production amount is zero', () {
        final currentTime = baseTime; // Same time as last collection

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('Should fail'),
          failure: (exception) {
            expect(exception, isA<NoResourcesAvailableException>());
          },
        );
      });

      test('should handle very small time differences', () {
        final currentTime = baseTime.add(const Duration(seconds: 1));

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            // 100 gold per hour = ~0.0277 gold per second, floored to 0
            expect(data.collectedResources['gold'], 0);
          },
          failure: (exception) {
            expect(exception, isA<NoResourcesAvailableException>());
          },
        );
      });

      test('should handle very large time differences', () {
        final currentTime = baseTime.add(const Duration(days: 7));

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            // 100 gold per hour * 24 hours * 7 days = 16,800 gold
            expect(data.collectedResources['gold'], 16800);
          },
          failure: (_) => fail('Should succeed'),
        );
      });
    });

    group('execute - immutability', () {
      test('should not modify original building', () {
        final originalLastCollection = testBuilding.lastCollectionTime;
        final currentTime = baseTime.add(const Duration(hours: 1));

        useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        expect(testBuilding.lastCollectionTime, originalLastCollection);
      });

      test('should not modify original economy', () {
        final originalGold = testEconomy.resources['gold'];
        final currentTime = baseTime.add(const Duration(hours: 1));

        useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        expect(testEconomy.resources['gold'], originalGold);
      });
    });

    group('executeBatch', () {
      late List<Building> testBuildings;

      setUp(() {
        testBuildings = [
          Building(
            id: 'building_1',
            type: 'gold_mine',
            level: 1,
            name: 'Gold Mine',
            description: 'Produces gold',
            productionRates: {'gold': 100},
            upgradeCosts: {},
            upgradeTimeSeconds: 60,
            lastCollectionTime: baseTime,
            createdAt: baseTime,
          ),
          Building(
            id: 'building_2',
            type: 'wood_mill',
            level: 1,
            name: 'Wood Mill',
            description: 'Produces wood',
            productionRates: {'wood': 50},
            upgradeCosts: {},
            upgradeTimeSeconds: 60,
            lastCollectionTime: baseTime,
            createdAt: baseTime,
          ),
          Building(
            id: 'building_3',
            type: 'stone_quarry',
            level: 1,
            name: 'Stone Quarry',
            description: 'Produces stone',
            productionRates: {'stone': 25},
            upgradeCosts: {},
            upgradeTimeSeconds: 60,
            lastCollectionTime: baseTime,
            createdAt: baseTime,
          ),
        ];
      });

      test('should collect from all buildings', () {
        final currentTime = baseTime.add(const Duration(hours: 1));

        final result = useCase.executeBatch(
          buildings: testBuildings,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.buildings.length, 3);
            expect(data.totalCollectedResources['gold'], 100);
            expect(data.totalCollectedResources['wood'], 50);
            expect(data.totalCollectedResources['stone'], 25);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should aggregate resources from multiple buildings of same type', () {
        final buildings = [
          testBuildings[0], // gold mine: 100 gold/hour
          testBuildings[0].copyWith(id: 'building_1b'), // another gold mine
        ];

        final currentTime = baseTime.add(const Duration(hours: 1));

        final result = useCase.executeBatch(
          buildings: buildings,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.totalCollectedResources['gold'], 200); // 100 + 100
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should handle empty buildings list', () {
        final result = useCase.executeBatch(
          buildings: [],
          playerEconomy: testEconomy,
          currentTime: baseTime.add(const Duration(hours: 1)),
        );

        result.when(
          success: (data) {
            expect(data.buildings, isEmpty);
            expect(data.totalCollectedResources, isEmpty);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should continue processing after individual failures', () {
        final buildings = [
          testBuildings[0], // valid
          testBuildings[1].copyWith(lastCollectionTime: null), // invalid
          testBuildings[2], // valid
        ];

        final currentTime = baseTime.add(const Duration(hours: 1));

        final result = useCase.executeBatch(
          buildings: buildings,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.successCount, 2);
            expect(data.failureCount, 1);
            expect(data.hasErrors, isTrue);
            expect(data.errors.containsKey('building_2'), isTrue);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should update player economy cumulatively', () {
        final economy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {
            'gold': 100,
            'wood': 50,
            'stone': 25,
          },
          createdAt: baseTime,
        );

        final currentTime = baseTime.add(const Duration(hours: 1));

        final result = useCase.executeBatch(
          buildings: testBuildings,
          playerEconomy: economy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.playerEconomy.resources['gold'], 200); // 100 + 100
            expect(data.playerEconomy.resources['wood'], 100); // 50 + 50
            expect(data.playerEconomy.resources['stone'], 50); // 25 + 25
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should preserve building order', () {
        final currentTime = baseTime.add(const Duration(hours: 1));

        final result = useCase.executeBatch(
          buildings: testBuildings,
          playerEconomy: testEconomy,
          currentTime: currentTime,
        );

        result.when(
          success: (data) {
            expect(data.buildings[0].id, 'building_1');
            expect(data.buildings[1].id, 'building_2');
            expect(data.buildings[2].id, 'building_3');
          },
          failure: (_) => fail('Should succeed'),
        );
      });
    });

    group('CollectResourcesResult', () {
      test('should contain all expected data', () {
        final result = CollectResourcesResult(
          playerEconomy: testEconomy,
          building: testBuilding,
          collectedResources: {'gold': 100},
        );

        expect(result.playerEconomy, testEconomy);
        expect(result.building, testBuilding);
        expect(result.collectedResources, {'gold': 100});
      });
    });

    group('BatchCollectResourcesResult', () {
      test('should correctly report success/failure counts', () {
        final result = BatchCollectResourcesResult(
          playerEconomy: testEconomy,
          buildings: [testBuilding],
          totalCollectedResources: {'gold': 100},
          errors: {'building_2': NoResourcesAvailableException(buildingId: 'building_2')},
        );

        expect(result.successCount, 1);
        expect(result.failureCount, 1);
        expect(result.hasErrors, isTrue);
      });

      test('should report no errors when all succeed', () {
        final result = BatchCollectResourcesResult(
          playerEconomy: testEconomy,
          buildings: [testBuilding],
          totalCollectedResources: {'gold': 100},
          errors: {},
        );

        expect(result.hasErrors, isFalse);
        expect(result.failureCount, 0);
      });
    });

    group('Exceptions', () {
      test('NoResourcesAvailableException should have descriptive message', () {
        final exception = NoResourcesAvailableException(buildingId: 'building_1');

        expect(exception.toString(), contains('building_1'));
        expect(exception.toString(), contains('No resources available'));
      });

      test('BuildingNotFoundException should have descriptive message', () {
        final exception = BuildingNotFoundException(buildingId: 'building_1');

        expect(exception.toString(), contains('building_1'));
        expect(exception.toString(), contains('not found'));
      });
    });
  });
}
