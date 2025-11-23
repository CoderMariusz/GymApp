import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/city_builder/domain/entities/building.dart';

void main() {
  group('Building Entity', () {
    late Building testBuilding;
    final baseTime = DateTime(2025, 1, 1, 12, 0, 0);

    setUp(() {
      testBuilding = Building(
        id: 'building_1',
        type: 'gold_mine',
        level: 1,
        name: 'Gold Mine',
        description: 'Produces gold over time',
        productionRates: {'gold': 100}, // 100 gold per hour
        upgradeCosts: {'wood': 50, 'stone': 50},
        upgradeTimeSeconds: 60,
        lastCollectionTime: baseTime,
        createdAt: baseTime,
      );
    });

    group('calculateProducedResources', () {
      test('should calculate correct resources after 1 hour', () {
        final currentTime = baseTime.add(const Duration(hours: 1));
        final produced = testBuilding.calculateProducedResources(currentTime);

        expect(produced['gold'], 100);
      });

      test('should calculate correct resources after 2 hours', () {
        final currentTime = baseTime.add(const Duration(hours: 2));
        final produced = testBuilding.calculateProducedResources(currentTime);

        expect(produced['gold'], 200);
      });

      test('should calculate correct resources after 30 minutes', () {
        final currentTime = baseTime.add(const Duration(minutes: 30));
        final produced = testBuilding.calculateProducedResources(currentTime);

        expect(produced['gold'], 50);
      });

      test('should return empty map when lastCollectionTime is null', () {
        final buildingWithoutCollection = testBuilding.copyWith(
          lastCollectionTime: null,
        );
        final produced = buildingWithoutCollection.calculateProducedResources(
          baseTime.add(const Duration(hours: 1)),
        );

        expect(produced, isEmpty);
      });

      test('should handle multiple resource types', () {
        final multiResourceBuilding = testBuilding.copyWith(
          productionRates: {
            'gold': 100,
            'wood': 50,
            'stone': 25,
          },
        );

        final currentTime = baseTime.add(const Duration(hours: 1));
        final produced =
            multiResourceBuilding.calculateProducedResources(currentTime);

        expect(produced['gold'], 100);
        expect(produced['wood'], 50);
        expect(produced['stone'], 25);
      });

      test('should floor fractional resource amounts', () {
        final currentTime = baseTime.add(const Duration(minutes: 33)); // 0.55 hours
        final produced = testBuilding.calculateProducedResources(currentTime);

        // 100 * 0.55 = 55, but should be floored
        expect(produced['gold'], 55);
      });
    });

    group('canUpgrade', () {
      test('should return true when player has enough resources', () {
        final availableResources = {'wood': 100, 'stone': 100};
        expect(testBuilding.canUpgrade(availableResources), isTrue);
      });

      test('should return true when player has exactly enough resources', () {
        final availableResources = {'wood': 50, 'stone': 50};
        expect(testBuilding.canUpgrade(availableResources), isTrue);
      });

      test('should return false when player lacks one resource type', () {
        final availableResources = {'wood': 50, 'stone': 40};
        expect(testBuilding.canUpgrade(availableResources), isFalse);
      });

      test('should return false when player lacks all resources', () {
        final availableResources = {'wood': 0, 'stone': 0};
        expect(testBuilding.canUpgrade(availableResources), isFalse);
      });

      test('should return false when resource type is missing from available', () {
        final availableResources = {'wood': 100}; // missing stone
        expect(testBuilding.canUpgrade(availableResources), isFalse);
      });

      test('should handle empty upgrade costs', () {
        final freeUpgradeBuilding = testBuilding.copyWith(upgradeCosts: {});
        final availableResources = {'wood': 0};
        expect(freeUpgradeBuilding.canUpgrade(availableResources), isTrue);
      });
    });

    group('upgrade', () {
      test('should increase building level by 1', () {
        final upgraded = testBuilding.upgrade();
        expect(upgraded.level, testBuilding.level + 1);
      });

      test('should increase production rates by 20%', () {
        final upgraded = testBuilding.upgrade();
        final expectedGoldRate = (100 * 1.2).floor(); // 120

        expect(upgraded.productionRates['gold'], expectedGoldRate);
      });

      test('should increase upgrade costs by 50%', () {
        final upgraded = testBuilding.upgrade();
        final expectedWoodCost = (50 * 1.5).floor(); // 75
        final expectedStoneCost = (50 * 1.5).floor(); // 75

        expect(upgraded.upgradeCosts['wood'], expectedWoodCost);
        expect(upgraded.upgradeCosts['stone'], expectedStoneCost);
      });

      test('should increase upgrade time by 10%', () {
        final upgraded = testBuilding.upgrade();
        final expectedTime = (60 * 1.1).floor(); // 66

        expect(upgraded.upgradeTimeSeconds, expectedTime);
      });

      test('should update updatedAt timestamp', () {
        final upgraded = testBuilding.upgrade();
        expect(upgraded.updatedAt, isNotNull);
        expect(upgraded.updatedAt!.isAfter(baseTime), isTrue);
      });

      test('should preserve other fields', () {
        final upgraded = testBuilding.upgrade();

        expect(upgraded.id, testBuilding.id);
        expect(upgraded.type, testBuilding.type);
        expect(upgraded.name, testBuilding.name);
        expect(upgraded.description, testBuilding.description);
      });

      test('should handle multiple upgrades correctly', () {
        final upgraded1 = testBuilding.upgrade();
        final upgraded2 = upgraded1.upgrade();
        final upgraded3 = upgraded2.upgrade();

        expect(upgraded3.level, 4);
        // Level 1 -> 2: 100 * 1.2 = 120
        // Level 2 -> 3: 120 * 1.2 = 144
        // Level 3 -> 4: 144 * 1.2 = 172
        expect(upgraded3.productionRates['gold'], 172);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testBuilding.toJson();

        expect(json['id'], 'building_1');
        expect(json['type'], 'gold_mine');
        expect(json['level'], 1);
        expect(json['name'], 'Gold Mine');
      });

      test('should deserialize from JSON correctly', () {
        final json = testBuilding.toJson();
        final deserialized = Building.fromJson(json);

        expect(deserialized.id, testBuilding.id);
        expect(deserialized.type, testBuilding.type);
        expect(deserialized.level, testBuilding.level);
        expect(deserialized.productionRates, testBuilding.productionRates);
      });

      test('should handle round-trip serialization', () {
        final json = testBuilding.toJson();
        final deserialized = Building.fromJson(json);
        final json2 = deserialized.toJson();

        expect(json2, equals(json));
      });
    });

    group('copyWith', () {
      test('should copy with modified fields', () {
        final copied = testBuilding.copyWith(
          level: 5,
          name: 'Upgraded Gold Mine',
        );

        expect(copied.level, 5);
        expect(copied.name, 'Upgraded Gold Mine');
        expect(copied.id, testBuilding.id);
        expect(copied.type, testBuilding.type);
      });

      test('should not modify original', () {
        final originalLevel = testBuilding.level;
        testBuilding.copyWith(level: 10);

        expect(testBuilding.level, originalLevel);
      });
    });
  });
}
