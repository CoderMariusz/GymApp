import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';

part 'player_economy.freezed.dart';

/// Domain entity representing the player's economic state
@freezed
class PlayerEconomy with _$PlayerEconomy {
  const factory PlayerEconomy({
    required String playerId,
    required Map<ResourceType, Resource> resources,
    required DateTime lastUpdated,
  }) = _PlayerEconomy;

  const PlayerEconomy._();

  /// Get a specific resource
  Resource getResource(ResourceType type) {
    return resources[type] ?? Resource(type: type, amount: 0);
  }

  /// Get resource amount
  int getResourceAmount(ResourceType type) {
    return getResource(type).amount;
  }

  /// Check if player can afford a cost
  bool canAfford(Map<ResourceType, int> cost) {
    return cost.entries.every((entry) {
      final resource = getResource(entry.key);
      return resource.hasAmount(entry.value);
    });
  }

  /// Add resources to player economy
  PlayerEconomy addResources(Map<ResourceType, int> resourcesToAdd) {
    final updatedResources = Map<ResourceType, Resource>.from(resources);

    for (final entry in resourcesToAdd.entries) {
      final currentResource = getResource(entry.key);
      updatedResources[entry.key] = currentResource.add(entry.value);
    }

    return copyWith(
      resources: updatedResources,
      lastUpdated: DateTime.now(),
    );
  }

  /// Add a single resource
  PlayerEconomy addResource(ResourceType type, int amount) {
    return addResources({type: amount});
  }

  /// Subtract resources from player economy
  PlayerEconomy subtractResources(Map<ResourceType, int> resourcesToSubtract) {
    final updatedResources = Map<ResourceType, Resource>.from(resources);

    for (final entry in resourcesToSubtract.entries) {
      final currentResource = getResource(entry.key);
      updatedResources[entry.key] = currentResource.subtract(entry.value);
    }

    return copyWith(
      resources: updatedResources,
      lastUpdated: DateTime.now(),
    );
  }

  /// Subtract a single resource
  PlayerEconomy subtractResource(ResourceType type, int amount) {
    return subtractResources({type: amount});
  }

  /// Update resource capacity
  PlayerEconomy updateCapacity(ResourceType type, int newCapacity) {
    final currentResource = getResource(type);
    final updatedResource = currentResource.copyWith(capacity: newCapacity);
    final updatedResources = Map<ResourceType, Resource>.from(resources);
    updatedResources[type] = updatedResource;

    return copyWith(
      resources: updatedResources,
      lastUpdated: DateTime.now(),
    );
  }

  /// Check if any resource is at capacity
  bool get hasResourceAtCapacity {
    return resources.values.any((resource) => resource.isAtCapacity);
  }

  /// Get total resource types
  int get resourceTypesCount => resources.length;

  /// Create initial economy for a new player
  factory PlayerEconomy.initial(String playerId) {
    return PlayerEconomy(
      playerId: playerId,
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
        ResourceType.stone: const Resource(
          type: ResourceType.stone,
          amount: 50,
          capacity: 500,
        ),
        ResourceType.food: const Resource(
          type: ResourceType.food,
          amount: 100,
          capacity: 1000,
        ),
        ResourceType.gems: const Resource(
          type: ResourceType.gems,
          amount: 0,
          capacity: 100,
        ),
      },
      lastUpdated: DateTime.now(),
    );
  }
}
