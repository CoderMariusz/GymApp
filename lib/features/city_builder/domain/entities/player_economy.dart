import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_economy.freezed.dart';
part 'player_economy.g.dart';

/// Represents the player's economic state (resources inventory)
@freezed
class PlayerEconomy with _$PlayerEconomy {
  const PlayerEconomy._();

  const factory PlayerEconomy({
    required String id,
    required String playerId,
    required Map<String, int> resources, // resource_type -> amount
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PlayerEconomy;

  factory PlayerEconomy.fromJson(Map<String, dynamic> json) =>
      _$PlayerEconomyFromJson(json);

  /// Create a new player economy with starting resources
  factory PlayerEconomy.initial({
    required String id,
    required String playerId,
  }) {
    return PlayerEconomy(
      id: id,
      playerId: playerId,
      resources: {
        'gold': 1000,
        'wood': 500,
        'stone': 500,
        'food': 300,
      },
      createdAt: DateTime.now(),
    );
  }

  /// Get amount of a specific resource
  int getResourceAmount(String resourceType) {
    return resources[resourceType] ?? 0;
  }

  /// Check if player has enough resources
  bool hasEnoughResources(Map<String, int> required) {
    for (final entry in required.entries) {
      if (getResourceAmount(entry.key) < entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Add resources to the economy
  PlayerEconomy addResources(Map<String, int> resourcesToAdd) {
    final newResources = Map<String, int>.from(resources);

    resourcesToAdd.forEach((resourceType, amount) {
      final currentAmount = newResources[resourceType] ?? 0;
      newResources[resourceType] = currentAmount + amount;
    });

    return copyWith(
      resources: newResources,
      updatedAt: DateTime.now(),
    );
  }

  /// Subtract resources from the economy
  /// Throws [InsufficientResourcesException] if not enough resources
  PlayerEconomy subtractResources(Map<String, int> resourcesToSubtract) {
    if (!hasEnoughResources(resourcesToSubtract)) {
      throw InsufficientResourcesException(
        required: resourcesToSubtract,
        available: resources,
      );
    }

    final newResources = Map<String, int>.from(resources);

    resourcesToSubtract.forEach((resourceType, amount) {
      final currentAmount = newResources[resourceType]!;
      newResources[resourceType] = currentAmount - amount;
    });

    return copyWith(
      resources: newResources,
      updatedAt: DateTime.now(),
    );
  }

  /// Get total wealth value (for leaderboard, etc.)
  /// Assumes: 1 gold = 1 value, 1 wood = 0.5 value, 1 stone = 0.5 value, 1 food = 0.3 value
  int getTotalWealth() {
    final goldValue = getResourceAmount('gold');
    final woodValue = (getResourceAmount('wood') * 0.5).floor();
    final stoneValue = (getResourceAmount('stone') * 0.5).floor();
    final foodValue = (getResourceAmount('food') * 0.3).floor();

    return goldValue + woodValue + stoneValue + foodValue;
  }
}

/// Exception thrown when player doesn't have enough resources
class InsufficientResourcesException implements Exception {
  final Map<String, int> required;
  final Map<String, int> available;

  InsufficientResourcesException({
    required this.required,
    required this.available,
  });

  @override
  String toString() {
    final missing = <String, int>{};
    required.forEach((type, amount) {
      final availableAmount = available[type] ?? 0;
      if (availableAmount < amount) {
        missing[type] = amount - availableAmount;
      }
    });

    return 'InsufficientResourcesException: Missing resources: $missing';
  }
}
