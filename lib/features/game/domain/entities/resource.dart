import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource.freezed.dart';

/// Resource types available in the game
enum ResourceType {
  gold('gold', 'Gold'),
  wood('wood', 'Wood'),
  stone('stone', 'Stone'),
  food('food', 'Food'),
  gems('gems', 'Gems');

  const ResourceType(this.value, this.displayName);

  final String value;
  final String displayName;

  static ResourceType fromString(String value) {
    return ResourceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ResourceType.gold,
    );
  }
}

/// Domain entity representing a game resource
@freezed
class Resource with _$Resource {
  const factory Resource({
    required ResourceType type,
    required int amount,
    @Default(0) int capacity,
  }) = _Resource;

  const Resource._();

  /// Check if resource has enough amount
  bool hasAmount(int required) => amount >= required;

  /// Check if adding amount would exceed capacity
  bool wouldExceedCapacity(int delta) {
    if (capacity == 0) return false; // No capacity limit
    return amount + delta > capacity;
  }

  /// Add amount to resource (respects capacity)
  Resource add(int delta) {
    if (delta <= 0) return this;

    final newAmount = capacity > 0
        ? (amount + delta).clamp(0, capacity)
        : amount + delta;

    return copyWith(amount: newAmount);
  }

  /// Subtract amount from resource (can't go below 0)
  Resource subtract(int delta) {
    if (delta <= 0) return this;

    final newAmount = (amount - delta).clamp(0, amount);
    return copyWith(amount: newAmount);
  }

  /// Check if resource is at capacity
  bool get isAtCapacity => capacity > 0 && amount >= capacity;

  /// Check if resource is empty
  bool get isEmpty => amount == 0;

  /// Get available space (returns -1 if no capacity limit)
  int get availableSpace {
    if (capacity == 0) return -1;
    return capacity - amount;
  }

  /// Get fill percentage (0.0 to 1.0, returns 0.0 if no capacity)
  double get fillPercentage {
    if (capacity == 0) return 0.0;
    return (amount / capacity).clamp(0.0, 1.0);
  }
}
