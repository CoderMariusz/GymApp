import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/city_builder/domain/entities/building.dart';
import 'package:lifeos/features/city_builder/domain/entities/player_economy.dart';
import 'package:lifeos/features/city_builder/domain/usecases/upgrade_building.dart';

void main() {
  group('UpgradeBuildingUseCase', () {
    late UpgradeBuildingUseCase useCase;
    late Building testBuilding;
    late PlayerEconomy testEconomy;
    final baseTime = DateTime(2025, 1, 1, 12, 0, 0);

    setUp(() {
      useCase = UpgradeBuildingUseCase();

      testBuilding = Building(
        id: 'building_1',
        type: 'gold_mine',
        level: 1,
        name: 'Gold Mine',
        description: 'Produces gold',
        productionRates: {'gold': 100},
        upgradeCosts: {'wood': 50, 'stone': 50},
        upgradeTimeSeconds: 60,
        lastCollectionTime: baseTime,
        createdAt: baseTime,
      );

      testEconomy = PlayerEconomy(
        id: 'economy_1',
        playerId: 'player_1',
        resources: {
          'gold': 1000,
          'wood': 500,
          'stone': 500,
        },
        createdAt: baseTime,
      );
    });

    group('execute - basic functionality', () {
      test('should successfully upgrade building', () {
        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        result.when(
          success: (data) {
            expect(data.building.level, 2);
            expect(data.newLevel, 2);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should deduct upgrade costs from economy', () {
        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        result.when(
          success: (data) {
            expect(data.playerEconomy.resources['wood'], 450); // 500 - 50
            expect(data.playerEconomy.resources['stone'], 450); // 500 - 50
            expect(data.playerEconomy.resources['gold'], 1000); // unchanged
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should return correct resourcesSpent', () {
        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        result.when(
          success: (data) {
            expect(data.resourcesSpent['wood'], 50);
            expect(data.resourcesSpent['stone'], 50);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should increase production rates', () {
        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        result.when(
          success: (data) {
            final expectedRate = (100 * 1.2).floor(); // 120
            expect(data.building.productionRates['gold'], expectedRate);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should increase upgrade costs for next level', () {
        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        result.when(
          success: (data) {
            final expectedCost = (50 * 1.5).floor(); // 75
            expect(data.building.upgradeCosts['wood'], expectedCost);
            expect(data.building.upgradeCosts['stone'], expectedCost);
          },
          failure: (_) => fail('Should succeed'),
        );
      });
    });

    group('execute - insufficient resources', () {
      test('should fail when player lacks all resources', () {
        final poorEconomy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {'gold': 100},
          createdAt: baseTime,
        );

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: poorEconomy,
        );

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('Should fail'),
          failure: (exception) {
            expect(exception, isA<InsufficientResourcesException>());
          },
        );
      });

      test('should fail when player lacks one resource type', () {
        final partialEconomy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {
            'wood': 500,
            'stone': 40, // Not enough stone
          },
          createdAt: baseTime,
        );

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: partialEconomy,
        );

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('Should fail'),
          failure: (exception) {
            expect(exception, isA<InsufficientResourcesException>());
          },
        );
      });

      test('should succeed when player has exactly enough resources', () {
        final exactEconomy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {
            'wood': 50,
            'stone': 50,
          },
          createdAt: baseTime,
        );

        final result = useCase.execute(
          building: testBuilding,
          playerEconomy: exactEconomy,
        );

        expect(result.isSuccess, isTrue);
      });
    });

    group('execute - max level', () {
      test('should fail when building is at max level', () {
        final maxLevelBuilding = testBuilding.copyWith(level: 50);

        final result = useCase.execute(
          building: maxLevelBuilding,
          playerEconomy: testEconomy,
          maxLevel: 50,
        );

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('Should fail'),
          failure: (exception) {
            expect(exception, isA<MaxLevelReachedException>());
          },
        );
      });

      test('should use custom max level', () {
        final highLevelBuilding = testBuilding.copyWith(level: 10);

        final result = useCase.execute(
          building: highLevelBuilding,
          playerEconomy: testEconomy,
          maxLevel: 10,
        );

        expect(result.isFailure, isTrue);
      });

      test('should succeed when building is below max level', () {
        final lowLevelBuilding = testBuilding.copyWith(level: 5);

        final result = useCase.execute(
          building: lowLevelBuilding,
          playerEconomy: testEconomy,
          maxLevel: 50,
        );

        expect(result.isSuccess, isTrue);
      });
    });

    group('execute - immutability', () {
      test('should not modify original building', () {
        final originalLevel = testBuilding.level;

        useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        expect(testBuilding.level, originalLevel);
      });

      test('should not modify original economy', () {
        final originalWood = testEconomy.resources['wood'];

        useCase.execute(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        expect(testEconomy.resources['wood'], originalWood);
      });
    });

    group('preview', () {
      test('should return canUpgrade=true when resources are sufficient', () {
        final preview = useCase.preview(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        expect(preview.canUpgrade, isTrue);
        expect(preview.reason, isNull);
        expect(preview.missingResources, isEmpty);
        expect(preview.nextLevelStats, isNotNull);
      });

      test('should return canUpgrade=false when resources insufficient', () {
        final poorEconomy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {'wood': 10, 'stone': 10},
          createdAt: baseTime,
        );

        final preview = useCase.preview(
          building: testBuilding,
          playerEconomy: poorEconomy,
        );

        expect(preview.canUpgrade, isFalse);
        expect(preview.reason, UpgradeBlockReason.insufficientResources);
        expect(preview.missingResources['wood'], 40);
        expect(preview.missingResources['stone'], 40);
      });

      test('should return canUpgrade=false when max level reached', () {
        final maxLevelBuilding = testBuilding.copyWith(level: 50);

        final preview = useCase.preview(
          building: maxLevelBuilding,
          playerEconomy: testEconomy,
          maxLevel: 50,
        );

        expect(preview.canUpgrade, isFalse);
        expect(preview.reason, UpgradeBlockReason.maxLevel);
        expect(preview.nextLevelStats, isNull);
      });

      test('should include next level stats when upgrade is possible', () {
        final preview = useCase.preview(
          building: testBuilding,
          playerEconomy: testEconomy,
        );

        expect(preview.nextLevelStats, isNotNull);
        expect(preview.nextLevelStats!.level, 2);
        expect(preview.nextLevelStats!.productionRates['gold'], 120);
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
            upgradeCosts: {'wood': 50, 'stone': 50},
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
            upgradeCosts: {'wood': 30, 'stone': 30},
            upgradeTimeSeconds: 60,
            lastCollectionTime: baseTime,
            createdAt: baseTime,
          ),
        ];
      });

      test('should upgrade all buildings when resources sufficient', () {
        final richEconomy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {
            'wood': 1000,
            'stone': 1000,
          },
          createdAt: baseTime,
        );

        final result = useCase.executeBatch(
          buildings: testBuildings,
          playerEconomy: richEconomy,
        );

        result.when(
          success: (data) {
            expect(data.buildings.length, 2);
            expect(data.buildings[0].level, 2);
            expect(data.buildings[1].level, 2);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should aggregate total resources spent', () {
        final richEconomy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {
            'wood': 1000,
            'stone': 1000,
          },
          createdAt: baseTime,
        );

        final result = useCase.executeBatch(
          buildings: testBuildings,
          playerEconomy: richEconomy,
        );

        result.when(
          success: (data) {
            expect(data.totalResourcesSpent['wood'], 80); // 50 + 30
            expect(data.totalResourcesSpent['stone'], 80); // 50 + 30
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should stop upgrading when resources run out', () {
        final limitedEconomy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {
            'wood': 55, // Enough for first, not second
            'stone': 55,
          },
          createdAt: baseTime,
        );

        final result = useCase.executeBatch(
          buildings: testBuildings,
          playerEconomy: limitedEconomy,
        );

        result.when(
          success: (data) {
            expect(data.successCount, 1);
            expect(data.failureCount, 1);
            expect(data.hasErrors, isTrue);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should handle empty buildings list', () {
        final result = useCase.executeBatch(
          buildings: [],
          playerEconomy: testEconomy,
        );

        result.when(
          success: (data) {
            expect(data.buildings, isEmpty);
            expect(data.totalResourcesSpent, isEmpty);
          },
          failure: (_) => fail('Should succeed'),
        );
      });

      test('should track errors for failed upgrades', () {
        final poorEconomy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {'wood': 10, 'stone': 10},
          createdAt: baseTime,
        );

        final result = useCase.executeBatch(
          buildings: testBuildings,
          playerEconomy: poorEconomy,
        );

        result.when(
          success: (data) {
            expect(data.errors.length, 2);
            expect(data.errors['building_1'], isA<InsufficientResourcesException>());
            expect(data.errors['building_2'], isA<InsufficientResourcesException>());
          },
          failure: (_) => fail('Should succeed'),
        );
      });
    });

    group('Exceptions', () {
      test('MaxLevelReachedException should have descriptive message', () {
        final exception = MaxLevelReachedException(
          buildingId: 'building_1',
          currentLevel: 50,
          maxLevel: 50,
        );

        expect(exception.toString(), contains('building_1'));
        expect(exception.toString(), contains('max level'));
        expect(exception.toString(), contains('50'));
      });
    });
  });
}
