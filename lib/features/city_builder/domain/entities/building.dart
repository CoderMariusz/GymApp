import 'package:freezed_annotation/freezed_annotation.dart';

part 'building.freezed.dart';
part 'building.g.dart';

/// Represents a building in the city that can produce resources
@freezed
class Building with _$Building {
  const Building._();

  const factory Building({
    required String id,
    required String type, // e.g., 'gold_mine', 'wood_mill', 'stone_quarry'
    required int level,
    required String name,
    required String description,
    required Map<String, int> productionRates, // resource_type -> amount_per_hour
    required Map<String, int> upgradeCosts, // resource_type -> cost_amount
    required int upgradeTimeSeconds,
    required DateTime? lastCollectionTime,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Building;

  factory Building.fromJson(Map<String, dynamic> json) =>
      _$BuildingFromJson(json);

  /// Calculate resources produced since last collection
  Map<String, int> calculateProducedResources(DateTime currentTime) {
    if (lastCollectionTime == null) {
      return {};
    }

    final hoursSinceLastCollection =
        currentTime.difference(lastCollectionTime!).inSeconds / 3600.0;

    final produced = <String, int>{};
    productionRates.forEach((resourceType, ratePerHour) {
      produced[resourceType] = (ratePerHour * hoursSinceLastCollection).floor();
    });

    return produced;
  }

  /// Check if building can be upgraded based on available resources
  bool canUpgrade(Map<String, int> availableResources) {
    for (final entry in upgradeCosts.entries) {
      final requiredAmount = entry.value;
      final availableAmount = availableResources[entry.key] ?? 0;
      if (availableAmount < requiredAmount) {
        return false;
      }
    }
    return true;
  }

  /// Get the next level building with updated stats
  Building upgrade() {
    return copyWith(
      level: level + 1,
      // Production increases by 20% per level
      productionRates: productionRates.map(
        (key, value) => MapEntry(key, (value * 1.2).floor()),
      ),
      // Upgrade cost increases by 50% per level
      upgradeCosts: upgradeCosts.map(
        (key, value) => MapEntry(key, (value * 1.5).floor()),
      ),
      // Upgrade time increases by 10% per level
      upgradeTimeSeconds: (upgradeTimeSeconds * 1.1).floor(),
      updatedAt: DateTime.now(),
    );
  }
}
