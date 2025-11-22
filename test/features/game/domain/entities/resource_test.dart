import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';

void main() {
  group('ResourceType', () {
    test('should have correct values and display names', () {
      expect(ResourceType.gold.value, 'gold');
      expect(ResourceType.gold.displayName, 'Gold');
      expect(ResourceType.wood.value, 'wood');
      expect(ResourceType.stone.value, 'stone');
      expect(ResourceType.food.value, 'food');
      expect(ResourceType.gems.value, 'gems');
    });

    test('should create ResourceType from string', () {
      expect(ResourceType.fromString('gold'), ResourceType.gold);
      expect(ResourceType.fromString('wood'), ResourceType.wood);
      expect(ResourceType.fromString('stone'), ResourceType.stone);
      expect(ResourceType.fromString('invalid'), ResourceType.gold); // Default
    });
  });

  group('Resource', () {
    test('should create resource with amount and capacity', () {
      const resource = Resource(
        type: ResourceType.gold,
        amount: 100,
        capacity: 1000,
      );

      expect(resource.type, ResourceType.gold);
      expect(resource.amount, 100);
      expect(resource.capacity, 1000);
    });

    test('should check if has enough amount', () {
      const resource = Resource(
        type: ResourceType.gold,
        amount: 100,
        capacity: 1000,
      );

      expect(resource.hasAmount(50), isTrue);
      expect(resource.hasAmount(100), isTrue);
      expect(resource.hasAmount(101), isFalse);
    });

    test('should detect if would exceed capacity', () {
      const resource = Resource(
        type: ResourceType.gold,
        amount: 900,
        capacity: 1000,
      );

      expect(resource.wouldExceedCapacity(50), isFalse);
      expect(resource.wouldExceedCapacity(100), isFalse);
      expect(resource.wouldExceedCapacity(101), isTrue);
    });

    test('should handle no capacity limit (capacity = 0)', () {
      const resource = Resource(
        type: ResourceType.gold,
        amount: 100,
        capacity: 0, // No limit
      );

      expect(resource.wouldExceedCapacity(999999), isFalse);
      expect(resource.isAtCapacity, isFalse);
      expect(resource.availableSpace, -1);
    });

    test('should add amount respecting capacity', () {
      const resource = Resource(
        type: ResourceType.gold,
        amount: 900,
        capacity: 1000,
      );

      final updated1 = resource.add(50);
      expect(updated1.amount, 950);

      final updated2 = resource.add(200); // Would exceed capacity
      expect(updated2.amount, 1000); // Clamped to capacity

      final updated3 = resource.add(-10); // Negative delta
      expect(updated3.amount, 900); // No change
    });

    test('should add amount without capacity limit', () {
      const resource = Resource(
        type: ResourceType.gold,
        amount: 100,
        capacity: 0, // No limit
      );

      final updated = resource.add(999999);
      expect(updated.amount, 1000099);
    });

    test('should subtract amount (cannot go below 0)', () {
      const resource = Resource(
        type: ResourceType.gold,
        amount: 100,
        capacity: 1000,
      );

      final updated1 = resource.subtract(50);
      expect(updated1.amount, 50);

      final updated2 = resource.subtract(200); // Would go below 0
      expect(updated2.amount, 0); // Clamped to 0

      final updated3 = resource.subtract(-10); // Negative delta
      expect(updated3.amount, 100); // No change
    });

    test('should detect if resource is at capacity', () {
      const resource1 = Resource(
        type: ResourceType.gold,
        amount: 1000,
        capacity: 1000,
      );
      expect(resource1.isAtCapacity, isTrue);

      const resource2 = Resource(
        type: ResourceType.gold,
        amount: 999,
        capacity: 1000,
      );
      expect(resource2.isAtCapacity, isFalse);

      const resource3 = Resource(
        type: ResourceType.gold,
        amount: 1000,
        capacity: 0, // No capacity limit
      );
      expect(resource3.isAtCapacity, isFalse);
    });

    test('should detect if resource is empty', () {
      const resource1 = Resource(
        type: ResourceType.gold,
        amount: 0,
        capacity: 1000,
      );
      expect(resource1.isEmpty, isTrue);

      const resource2 = Resource(
        type: ResourceType.gold,
        amount: 1,
        capacity: 1000,
      );
      expect(resource2.isEmpty, isFalse);
    });

    test('should calculate available space', () {
      const resource1 = Resource(
        type: ResourceType.gold,
        amount: 700,
        capacity: 1000,
      );
      expect(resource1.availableSpace, 300);

      const resource2 = Resource(
        type: ResourceType.gold,
        amount: 1000,
        capacity: 1000,
      );
      expect(resource2.availableSpace, 0);

      const resource3 = Resource(
        type: ResourceType.gold,
        amount: 100,
        capacity: 0, // No limit
      );
      expect(resource3.availableSpace, -1);
    });

    test('should calculate fill percentage', () {
      const resource1 = Resource(
        type: ResourceType.gold,
        amount: 500,
        capacity: 1000,
      );
      expect(resource1.fillPercentage, 0.5);

      const resource2 = Resource(
        type: ResourceType.gold,
        amount: 1000,
        capacity: 1000,
      );
      expect(resource2.fillPercentage, 1.0);

      const resource3 = Resource(
        type: ResourceType.gold,
        amount: 0,
        capacity: 1000,
      );
      expect(resource3.fillPercentage, 0.0);

      const resource4 = Resource(
        type: ResourceType.gold,
        amount: 100,
        capacity: 0, // No limit
      );
      expect(resource4.fillPercentage, 0.0);
    });
  });
}
