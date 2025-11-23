import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/city_builder/domain/entities/resource.dart';

void main() {
  group('Resource Entity', () {
    late Resource testResource;
    final baseTime = DateTime(2025, 1, 1, 12, 0, 0);

    setUp(() {
      testResource = Resource(
        id: 'resource_1',
        type: 'gold',
        name: 'Gold',
        description: 'Primary currency',
        iconPath: 'assets/resources/gold.png',
        maxStorage: 10000,
        createdAt: baseTime,
      );
    });

    group('constructor', () {
      test('should create resource with all required fields', () {
        expect(testResource.id, 'resource_1');
        expect(testResource.type, 'gold');
        expect(testResource.name, 'Gold');
        expect(testResource.description, 'Primary currency');
        expect(testResource.iconPath, 'assets/resources/gold.png');
        expect(testResource.maxStorage, 10000);
        expect(testResource.createdAt, baseTime);
      });

      test('should have null updatedAt by default', () {
        expect(testResource.updatedAt, isNull);
      });
    });

    group('factory constructors', () {
      test('gold factory should create gold resource', () {
        final gold = Resource.gold(id: 'gold_1');

        expect(gold.type, 'gold');
        expect(gold.name, 'Gold');
        expect(gold.maxStorage, 10000);
        expect(gold.iconPath, 'assets/resources/gold.png');
      });

      test('wood factory should create wood resource', () {
        final wood = Resource.wood(id: 'wood_1');

        expect(wood.type, 'wood');
        expect(wood.name, 'Wood');
        expect(wood.maxStorage, 5000);
        expect(wood.iconPath, 'assets/resources/wood.png');
      });

      test('stone factory should create stone resource', () {
        final stone = Resource.stone(id: 'stone_1');

        expect(stone.type, 'stone');
        expect(stone.name, 'Stone');
        expect(stone.maxStorage, 5000);
        expect(stone.iconPath, 'assets/resources/stone.png');
      });

      test('food factory should create food resource', () {
        final food = Resource.food(id: 'food_1');

        expect(food.type, 'food');
        expect(food.name, 'Food');
        expect(food.maxStorage, 3000);
        expect(food.iconPath, 'assets/resources/food.png');
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testResource.toJson();

        expect(json['id'], 'resource_1');
        expect(json['type'], 'gold');
        expect(json['name'], 'Gold');
        expect(json['maxStorage'], 10000);
      });

      test('should deserialize from JSON correctly', () {
        final json = testResource.toJson();
        final deserialized = Resource.fromJson(json);

        expect(deserialized.id, testResource.id);
        expect(deserialized.type, testResource.type);
        expect(deserialized.name, testResource.name);
        expect(deserialized.maxStorage, testResource.maxStorage);
      });

      test('should handle round-trip serialization', () {
        final json = testResource.toJson();
        final deserialized = Resource.fromJson(json);
        final json2 = deserialized.toJson();

        expect(json2, equals(json));
      });
    });

    group('copyWith', () {
      test('should copy with modified fields', () {
        final copied = testResource.copyWith(
          name: 'Shiny Gold',
          maxStorage: 20000,
        );

        expect(copied.name, 'Shiny Gold');
        expect(copied.maxStorage, 20000);
        expect(copied.id, testResource.id);
        expect(copied.type, testResource.type);
      });

      test('should not modify original', () {
        final originalName = testResource.name;
        testResource.copyWith(name: 'New Name');

        expect(testResource.name, originalName);
      });
    });
  });
}
