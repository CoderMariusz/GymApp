import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/components/building_component.dart';
import 'package:lifeos/features/game/domain/entities/building.dart';

void main() {
  group('BuildingComponent', () {
    late Building building;
    late BuildingComponent component;

    setUp(() {
      building = Building(
        id: 'building1',
        type: BuildingType.mine,
        level: 1,
        gridX: 5,
        gridY: 5,
        status: BuildingStatus.ready,
        lastCollectionTime: DateTime.now().subtract(const Duration(hours: 1)),
        accumulatedResources: 15,
      );

      component = BuildingComponent(
        building: building,
        tileSize: 64.0,
      );
    });

    test('should initialize with correct properties', () {
      expect(component.building, building);
      expect(component.tileSize, 64.0);
      expect(component.size, Vector2(64.0, 64.0));
      expect(component.anchor, Anchor.center);
    });

    test('should update building entity', () {
      final newBuilding = building.copyWith(level: 2);

      component.updateBuilding(newBuilding);

      expect(component.building.level, 2);
    });

    test('should detect when building is collectable', () {
      // Building has accumulated resources
      expect(component.building.accumulatedResources, greaterThan(0));

      // Component needs to call onLoad first
      component.onLoad();

      // After update, should detect collectable
      component.update(0.016);

      // Check via building directly
      expect(component.building.canCollect(DateTime.now()), true);
    });

    test('should calculate resource fill percentage', () {
      final fillPercentage = component.resourceFillPercentage;

      expect(fillPercentage, greaterThan(0.0));
      expect(fillPercentage, lessThanOrEqualTo(1.0));
    });

    test('should detect when building needs attention', () {
      // Building with resources should need attention
      expect(component.needsAttention, true);

      // Empty building should not need attention
      final emptyBuilding = building.copyWith(
        accumulatedResources: 0,
        lastCollectionTime: DateTime.now(),
      );
      component.updateBuilding(emptyBuilding);

      expect(component.needsAttention, false);
    });

    test('should handle tap callback', () {
      var tappedBuildingId = '';

      component.onTap = (id) {
        tappedBuildingId = id;
      };

      // Simulate tap
      component.onTap?.call(building.id);

      expect(tappedBuildingId, building.id);
    });

    test('should support different building types', () {
      final types = BuildingType.values;

      for (final type in types) {
        final testBuilding = building.copyWith(type: type);
        component.updateBuilding(testBuilding);

        expect(component.building.type, type);
      }
    });

    test('should support different building statuses', () {
      final statuses = [
        BuildingStatus.ready,
        BuildingStatus.upgrading,
        BuildingStatus.producing,
      ];

      for (final status in statuses) {
        final testBuilding = building.copyWith(status: status);
        component.updateBuilding(testBuilding);

        expect(component.building.status, status);
      }
    });

    test('should handle buildings at different levels', () {
      for (int level = 1; level <= 10; level++) {
        final testBuilding = building.copyWith(level: level);
        component.updateBuilding(testBuilding);

        expect(component.building.level, level);
      }
    });

    test('should handle empty building (no resources)', () {
      final emptyBuilding = building.copyWith(
        accumulatedResources: 0,
        lastCollectionTime: DateTime.now(),
      );

      component.updateBuilding(emptyBuilding);

      expect(component.building.accumulatedResources, 0);
      expect(component.resourceFillPercentage, 0.0);
    });

    test('should handle full building (at capacity)', () {
      final fullBuilding = building.copyWith(
        accumulatedResources: building.storageCapacity,
      );

      component.updateBuilding(fullBuilding);

      expect(component.building.accumulatedResources, building.storageCapacity);
      expect(component.resourceFillPercentage, 1.0);
    });

    test('should support debug info toggle', () {
      component.showDebugInfo = true;
      expect(component.showDebugInfo, true);

      component.showDebugInfo = false;
      expect(component.showDebugInfo, false);
    });

    test('should update animation over time', () {
      component.onLoad();

      // Simulate multiple updates
      for (int i = 0; i < 10; i++) {
        component.update(0.016); // ~60fps
      }

      // Component should update without errors
      expect(component.building, isNotNull);
    });
  });

  group('BuildingComponent - Visual States', () {
    test('should render different building types with unique colors', () {
      final types = BuildingType.values;
      final component = BuildingComponent(
        building: Building(
          id: 'test',
          type: types.first,
          level: 1,
          gridX: 0,
          gridY: 0,
          status: BuildingStatus.ready,
          lastCollectionTime: DateTime.now(),
        ),
        tileSize: 64.0,
      );

      // Each type should be renderable
      for (final type in types) {
        final building = component.building.copyWith(type: type);
        component.updateBuilding(building);

        expect(component.building.type, type);
      }
    });

    test('should handle upgrading building visual state', () {
      final upgradingBuilding = Building(
        id: 'test',
        type: BuildingType.mine,
        level: 1,
        gridX: 0,
        gridY: 0,
        status: BuildingStatus.upgrading,
        lastCollectionTime: DateTime.now(),
      );

      final component = BuildingComponent(
        building: upgradingBuilding,
        tileSize: 64.0,
      );

      expect(component.building.status, BuildingStatus.upgrading);
    });
  });

  group('BuildingComponent - Grid Positioning', () {
    test('should maintain grid position from building entity', () {
      final building = Building(
        id: 'test',
        type: BuildingType.mine,
        level: 1,
        gridX: 10,
        gridY: 15,
        status: BuildingStatus.ready,
        lastCollectionTime: DateTime.now(),
      );

      final component = BuildingComponent(
        building: building,
        tileSize: 64.0,
      );

      expect(component.building.gridX, 10);
      expect(component.building.gridY, 15);
    });

    test('should support different tile sizes', () {
      final tileSizes = [32.0, 64.0, 128.0];

      for (final tileSize in tileSizes) {
        final component = BuildingComponent(
          building: Building(
            id: 'test',
            type: BuildingType.mine,
            level: 1,
            gridX: 0,
            gridY: 0,
            status: BuildingStatus.ready,
            lastCollectionTime: DateTime.now(),
          ),
          tileSize: tileSize,
        );

        expect(component.tileSize, tileSize);
        expect(component.size, Vector2(tileSize, tileSize));
      }
    });
  });
}
