import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';

part 'building.freezed.dart';

/// Building type enumeration
enum BuildingType {
  mine('mine', 'Mine', ResourceType.gold),
  lumberMill('lumber_mill', 'Lumber Mill', ResourceType.wood),
  quarry('quarry', 'Quarry', ResourceType.stone),
  farm('farm', 'Farm', ResourceType.food),
  gemMine('gem_mine', 'Gem Mine', ResourceType.gems);

  const BuildingType(this.value, this.displayName, this.producedResource);

  final String value;
  final String displayName;
  final ResourceType producedResource;

  static BuildingType fromString(String value) {
    return BuildingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BuildingType.mine,
    );
  }
}

/// Building status
enum BuildingStatus {
  /// Building is ready to collect resources
  ready,

  /// Building is producing resources
  producing,

  /// Building is being upgraded
  upgrading,
}

/// Domain entity representing a game building
@freezed
class Building with _$Building {
  const factory Building({
    required String id,
    required BuildingType type,
    required int level,
    required int gridX,
    required int gridY,
    required BuildingStatus status,
    required DateTime lastCollectionTime,
    @Default(0) int accumulatedResources,
  }) = _Building;

  const Building._();

  /// Get production rate per hour based on level
  int get productionRatePerHour {
    // Base production increases with level
    // Formula: baseRate * level * 1.5
    const baseRate = 10;
    return (baseRate * level * 1.5).round();
  }

  /// Get production rate per second
  double get productionRatePerSecond {
    return productionRatePerHour / 3600.0;
  }

  /// Get storage capacity based on level
  int get storageCapacity {
    // Formula: 100 * level * level
    return 100 * level * level;
  }

  /// Get upgrade cost for next level
  Map<ResourceType, int> get upgradeCost {
    // Cost increases exponentially with level
    final baseCost = 50;
    final multiplier = level * level;

    return {
      ResourceType.gold: baseCost * multiplier,
      ResourceType.wood: (baseCost * 0.5 * multiplier).round(),
      ResourceType.stone: (baseCost * 0.5 * multiplier).round(),
    };
  }

  /// Get upgrade duration in seconds
  int get upgradeDurationSeconds {
    // Formula: 60 * level (1 minute per level)
    return 60 * level;
  }

  /// Calculate accumulated resources since last collection
  int calculateAccumulatedResources(DateTime now) {
    final timeDiff = now.difference(lastCollectionTime);
    final secondsElapsed = timeDiff.inSeconds;
    final produced = (secondsElapsed * productionRatePerSecond).floor();

    // Clamp to storage capacity
    final total = accumulatedResources + produced;
    return total.clamp(0, storageCapacity);
  }

  /// Check if building is ready to collect
  bool canCollect(DateTime now) {
    return status == BuildingStatus.ready &&
        calculateAccumulatedResources(now) > 0;
  }

  /// Check if building is at storage capacity
  bool isAtCapacity(DateTime now) {
    return calculateAccumulatedResources(now) >= storageCapacity;
  }

  /// Collect accumulated resources
  Building collect(DateTime now) {
    final collected = calculateAccumulatedResources(now);

    return copyWith(
      accumulatedResources: 0,
      lastCollectionTime: now,
    );
  }

  /// Start upgrading the building
  Building startUpgrade() {
    return copyWith(
      status: BuildingStatus.upgrading,
    );
  }

  /// Complete upgrade (increases level)
  Building completeUpgrade() {
    return copyWith(
      level: level + 1,
      status: BuildingStatus.ready,
    );
  }

  /// Get max level
  static const int maxLevel = 10;

  /// Check if building can be upgraded
  bool get canUpgrade => level < maxLevel && status == BuildingStatus.ready;

  /// Get resource type produced by this building
  ResourceType get producedResourceType => type.producedResource;

  /// Calculate time until storage is full
  Duration? timeUntilFull(DateTime now) {
    if (isAtCapacity(now)) return Duration.zero;

    final current = calculateAccumulatedResources(now);
    final remaining = storageCapacity - current;
    final secondsToFill = remaining / productionRatePerSecond;

    return Duration(seconds: secondsToFill.ceil());
  }

  /// Get fill percentage (0.0 to 1.0)
  double getFillPercentage(DateTime now) {
    final accumulated = calculateAccumulatedResources(now);
    return (accumulated / storageCapacity).clamp(0.0, 1.0);
  }
}
