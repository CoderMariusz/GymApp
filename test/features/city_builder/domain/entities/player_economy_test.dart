import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/city_builder/domain/entities/player_economy.dart';

void main() {
  group('PlayerEconomy Entity', () {
    late PlayerEconomy testEconomy;
    final baseTime = DateTime(2025, 1, 1, 12, 0, 0);

    setUp(() {
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

    group('constructor', () {
      test('should create economy with all required fields', () {
        expect(testEconomy.id, 'economy_1');
        expect(testEconomy.playerId, 'player_1');
        expect(testEconomy.resources['gold'], 1000);
        expect(testEconomy.resources['wood'], 500);
        expect(testEconomy.createdAt, baseTime);
      });
    });

    group('initial factory', () {
      test('should create economy with starting resources', () {
        final economy = PlayerEconomy.initial(
          id: 'new_economy',
          playerId: 'new_player',
        );

        expect(economy.resources['gold'], 1000);
        expect(economy.resources['wood'], 500);
        expect(economy.resources['stone'], 500);
        expect(economy.resources['food'], 300);
      });
    });

    group('getResourceAmount', () {
      test('should return correct amount for existing resource', () {
        expect(testEconomy.getResourceAmount('gold'), 1000);
        expect(testEconomy.getResourceAmount('wood'), 500);
      });

      test('should return 0 for non-existing resource', () {
        expect(testEconomy.getResourceAmount('food'), 0);
      });
    });

    group('hasEnoughResources', () {
      test('should return true when player has enough resources', () {
        final required = {'gold': 500, 'wood': 300};
        expect(testEconomy.hasEnoughResources(required), isTrue);
      });

      test('should return true when player has exactly enough resources', () {
        final required = {'gold': 1000, 'wood': 500};
        expect(testEconomy.hasEnoughResources(required), isTrue);
      });

      test('should return false when player lacks one resource', () {
        final required = {'gold': 1001, 'wood': 500};
        expect(testEconomy.hasEnoughResources(required), isFalse);
      });

      test('should return false when resource type does not exist', () {
        final required = {'food': 100};
        expect(testEconomy.hasEnoughResources(required), isFalse);
      });

      test('should return true for empty requirements', () {
        final required = <String, int>{};
        expect(testEconomy.hasEnoughResources(required), isTrue);
      });
    });

    group('addResources', () {
      test('should add resources to existing types', () {
        final updated = testEconomy.addResources({'gold': 500});

        expect(updated.resources['gold'], 1500);
        expect(updated.resources['wood'], 500); // unchanged
      });

      test('should add new resource types', () {
        final updated = testEconomy.addResources({'food': 200});

        expect(updated.resources['food'], 200);
        expect(updated.resources['gold'], 1000); // unchanged
      });

      test('should handle multiple resource types', () {
        final updated = testEconomy.addResources({
          'gold': 100,
          'wood': 50,
          'stone': 25,
        });

        expect(updated.resources['gold'], 1100);
        expect(updated.resources['wood'], 550);
        expect(updated.resources['stone'], 525);
      });

      test('should not modify original economy', () {
        testEconomy.addResources({'gold': 500});

        expect(testEconomy.resources['gold'], 1000);
      });

      test('should update updatedAt timestamp', () {
        final updated = testEconomy.addResources({'gold': 100});

        expect(updated.updatedAt, isNotNull);
        expect(updated.updatedAt!.isAfter(baseTime), isTrue);
      });
    });

    group('subtractResources', () {
      test('should subtract resources from existing types', () {
        final updated = testEconomy.subtractResources({'gold': 500});

        expect(updated.resources['gold'], 500);
      });

      test('should handle multiple resource types', () {
        final updated = testEconomy.subtractResources({
          'gold': 100,
          'wood': 50,
        });

        expect(updated.resources['gold'], 900);
        expect(updated.resources['wood'], 450);
      });

      test('should throw when insufficient resources', () {
        expect(
          () => testEconomy.subtractResources({'gold': 1001}),
          throwsA(isA<InsufficientResourcesException>()),
        );
      });

      test('should throw when resource type does not exist', () {
        expect(
          () => testEconomy.subtractResources({'food': 100}),
          throwsA(isA<InsufficientResourcesException>()),
        );
      });

      test('should not modify original economy', () {
        testEconomy.subtractResources({'gold': 100});

        expect(testEconomy.resources['gold'], 1000);
      });

      test('should update updatedAt timestamp', () {
        final updated = testEconomy.subtractResources({'gold': 100});

        expect(updated.updatedAt, isNotNull);
        expect(updated.updatedAt!.isAfter(baseTime), isTrue);
      });
    });

    group('getTotalWealth', () {
      test('should calculate total wealth correctly', () {
        final economy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {
            'gold': 1000, // 1000 * 1.0 = 1000
            'wood': 1000, // 1000 * 0.5 = 500
            'stone': 1000, // 1000 * 0.5 = 500
            'food': 1000, // 1000 * 0.3 = 300
          },
          createdAt: baseTime,
        );

        final wealth = economy.getTotalWealth();
        expect(wealth, 2300);
      });

      test('should handle missing resource types', () {
        final economy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {'gold': 500},
          createdAt: baseTime,
        );

        final wealth = economy.getTotalWealth();
        expect(wealth, 500);
      });

      test('should handle zero resources', () {
        final economy = PlayerEconomy(
          id: 'economy_1',
          playerId: 'player_1',
          resources: {},
          createdAt: baseTime,
        );

        final wealth = economy.getTotalWealth();
        expect(wealth, 0);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testEconomy.toJson();

        expect(json['id'], 'economy_1');
        expect(json['playerId'], 'player_1');
        expect(json['resources'], isA<Map<String, dynamic>>());
      });

      test('should deserialize from JSON correctly', () {
        final json = testEconomy.toJson();
        final deserialized = PlayerEconomy.fromJson(json);

        expect(deserialized.id, testEconomy.id);
        expect(deserialized.playerId, testEconomy.playerId);
        expect(deserialized.resources, testEconomy.resources);
      });

      test('should handle round-trip serialization', () {
        final json = testEconomy.toJson();
        final deserialized = PlayerEconomy.fromJson(json);
        final json2 = deserialized.toJson();

        expect(json2, equals(json));
      });
    });

    group('InsufficientResourcesException', () {
      test('should contain required and available resources', () {
        final exception = InsufficientResourcesException(
          required: {'gold': 1000},
          available: {'gold': 500},
        );

        expect(exception.required, {'gold': 1000});
        expect(exception.available, {'gold': 500});
      });

      test('should have descriptive toString', () {
        final exception = InsufficientResourcesException(
          required: {'gold': 1000, 'wood': 500},
          available: {'gold': 500, 'wood': 200},
        );

        final message = exception.toString();
        expect(message, contains('InsufficientResourcesException'));
        expect(message, contains('Missing'));
      });
    });
  });
}
