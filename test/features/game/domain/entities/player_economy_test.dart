import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/domain/entities/player_economy.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';

void main() {
  group('PlayerEconomy', () {
    late PlayerEconomy playerEconomy;

    setUp(() {
      playerEconomy = PlayerEconomy(
        playerId: 'player123',
        resources: {
          ResourceType.gold: const Resource(
            type: ResourceType.gold,
            amount: 100,
            capacity: 1000,
          ),
          ResourceType.wood: const Resource(
            type: ResourceType.wood,
            amount: 50,
            capacity: 500,
          ),
        },
        lastUpdated: DateTime(2024, 1, 1),
      );
    });

    test('should create player economy with resources', () {
      expect(playerEconomy.playerId, 'player123');
      expect(playerEconomy.resources.length, 2);
      expect(playerEconomy.lastUpdated, DateTime(2024, 1, 1));
    });

    test('should get specific resource', () {
      final gold = playerEconomy.getResource(ResourceType.gold);
      expect(gold.type, ResourceType.gold);
      expect(gold.amount, 100);
      expect(gold.capacity, 1000);
    });

    test('should return empty resource for non-existent type', () {
      final stone = playerEconomy.getResource(ResourceType.stone);
      expect(stone.type, ResourceType.stone);
      expect(stone.amount, 0);
      expect(stone.capacity, 0);
    });

    test('should get resource amount', () {
      expect(playerEconomy.getResourceAmount(ResourceType.gold), 100);
      expect(playerEconomy.getResourceAmount(ResourceType.wood), 50);
      expect(playerEconomy.getResourceAmount(ResourceType.stone), 0);
    });

    test('should check if can afford cost', () {
      final canAfford1 = playerEconomy.canAfford({
        ResourceType.gold: 50,
        ResourceType.wood: 30,
      });
      expect(canAfford1, isTrue);

      final canAfford2 = playerEconomy.canAfford({
        ResourceType.gold: 150, // Not enough
      });
      expect(canAfford2, isFalse);

      final canAfford3 = playerEconomy.canAfford({
        ResourceType.gold: 50,
        ResourceType.wood: 60, // Not enough wood
      });
      expect(canAfford3, isFalse);

      final canAfford4 = playerEconomy.canAfford({
        ResourceType.stone: 10, // Don't have stone
      });
      expect(canAfford4, isFalse);
    });

    test('should add resources', () {
      final updated = playerEconomy.addResources({
        ResourceType.gold: 50,
        ResourceType.wood: 25,
      });

      expect(updated.getResourceAmount(ResourceType.gold), 150);
      expect(updated.getResourceAmount(ResourceType.wood), 75);
      expect(updated.lastUpdated.isAfter(playerEconomy.lastUpdated), isTrue);
    });

    test('should add single resource', () {
      final updated = playerEconomy.addResource(ResourceType.gold, 100);

      expect(updated.getResourceAmount(ResourceType.gold), 200);
      expect(updated.getResourceAmount(ResourceType.wood), 50); // Unchanged
    });

    test('should add new resource type', () {
      final updated = playerEconomy.addResource(ResourceType.stone, 75);

      expect(updated.getResourceAmount(ResourceType.stone), 75);
      expect(updated.resources.containsKey(ResourceType.stone), isTrue);
    });

    test('should subtract resources', () {
      final updated = playerEconomy.subtractResources({
        ResourceType.gold: 30,
        ResourceType.wood: 20,
      });

      expect(updated.getResourceAmount(ResourceType.gold), 70);
      expect(updated.getResourceAmount(ResourceType.wood), 30);
      expect(updated.lastUpdated.isAfter(playerEconomy.lastUpdated), isTrue);
    });

    test('should subtract single resource', () {
      final updated = playerEconomy.subtractResource(ResourceType.gold, 25);

      expect(updated.getResourceAmount(ResourceType.gold), 75);
      expect(updated.getResourceAmount(ResourceType.wood), 50); // Unchanged
    });

    test('should not go below zero when subtracting', () {
      final updated = playerEconomy.subtractResource(ResourceType.gold, 200);

      expect(updated.getResourceAmount(ResourceType.gold), 0);
    });

    test('should update resource capacity', () {
      final updated = playerEconomy.updateCapacity(ResourceType.gold, 2000);

      final gold = updated.getResource(ResourceType.gold);
      expect(gold.capacity, 2000);
      expect(gold.amount, 100); // Amount unchanged
    });

    test('should detect if any resource is at capacity', () {
      expect(playerEconomy.hasResourceAtCapacity, isFalse);

      final atCapacity = playerEconomy.addResource(ResourceType.gold, 900);
      expect(atCapacity.hasResourceAtCapacity, isTrue);
    });

    test('should count resource types', () {
      expect(playerEconomy.resourceTypesCount, 2);

      final withStone = playerEconomy.addResource(ResourceType.stone, 50);
      expect(withStone.resourceTypesCount, 3);
    });

    test('should create initial economy for new player', () {
      final initial = PlayerEconomy.initial('newPlayer123');

      expect(initial.playerId, 'newPlayer123');
      expect(initial.resources.length, 5); // All resource types

      expect(initial.getResourceAmount(ResourceType.gold), 100);
      expect(initial.getResourceAmount(ResourceType.wood), 50);
      expect(initial.getResourceAmount(ResourceType.stone), 50);
      expect(initial.getResourceAmount(ResourceType.food), 100);
      expect(initial.getResourceAmount(ResourceType.gems), 0);

      expect(initial.getResource(ResourceType.gold).capacity, 1000);
      expect(initial.getResource(ResourceType.wood).capacity, 500);
      expect(initial.getResource(ResourceType.stone).capacity, 500);
      expect(initial.getResource(ResourceType.food).capacity, 1000);
      expect(initial.getResource(ResourceType.gems).capacity, 100);
    });
  });
}
