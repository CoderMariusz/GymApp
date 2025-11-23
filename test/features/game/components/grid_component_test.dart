import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/components/grid_component.dart';

void main() {
  group('GridComponent - Orthogonal', () {
    late GridComponent grid;

    setUp(() {
      grid = GridComponent(
        gridWidth: 10,
        gridHeight: 10,
        tileSize: 64.0,
        gridType: GridType.orthogonal,
      );
    });

    test('should initialize with correct properties', () {
      expect(grid.gridWidth, 10);
      expect(grid.gridHeight, 10);
      expect(grid.tileSize, 64.0);
      expect(grid.gridType, GridType.orthogonal);
      expect(grid.showGrid, true);
    });

    test('should convert grid to screen coordinates (orthogonal)', () {
      final pos1 = grid.gridToScreen(0, 0);
      expect(pos1.x, 0);
      expect(pos1.y, 0);

      final pos2 = grid.gridToScreen(5, 5);
      expect(pos2.x, 320.0); // 5 * 64
      expect(pos2.y, 320.0); // 5 * 64

      final pos3 = grid.gridToScreen(10, 10);
      expect(pos3.x, 640.0); // 10 * 64
      expect(pos3.y, 640.0); // 10 * 64
    });

    test('should convert screen to grid coordinates (orthogonal)', () {
      final grid1 = grid.screenToGrid(Vector2(0, 0));
      expect(grid1.x, 0);
      expect(grid1.y, 0);

      final grid2 = grid.screenToGrid(Vector2(320, 320));
      expect(grid2.x, 5); // 320 / 64 = 5
      expect(grid2.y, 5);

      final grid3 = grid.screenToGrid(Vector2(100, 200));
      expect(grid3.x, 1); // 100 / 64 = 1.5 -> floor = 1
      expect(grid3.y, 3); // 200 / 64 = 3.125 -> floor = 3
    });

    test('should validate grid positions', () {
      expect(grid.isValidGridPosition(0, 0), true);
      expect(grid.isValidGridPosition(5, 5), true);
      expect(grid.isValidGridPosition(9, 9), true);

      expect(grid.isValidGridPosition(-1, 0), false);
      expect(grid.isValidGridPosition(0, -1), false);
      expect(grid.isValidGridPosition(10, 5), false); // Out of bounds
      expect(grid.isValidGridPosition(5, 10), false); // Out of bounds
      expect(grid.isValidGridPosition(15, 15), false);
    });

    test('should calculate grid center', () {
      final center = grid.getGridCenter();
      expect(center.x, 320.0); // (10 / 2) * 64 = 320
      expect(center.y, 320.0);
    });

    test('should calculate grid bounds (orthogonal)', () {
      final bounds = grid.getGridBounds();
      expect(bounds.left, 0);
      expect(bounds.top, 0);
      expect(bounds.width, 640.0); // 10 * 64
      expect(bounds.height, 640.0); // 10 * 64
    });

    test('should calculate visible bounds for spatial culling', () {
      final visible = grid.getVisibleBounds(
        cameraPosition: Vector2(100, 100),
        viewportSize: Vector2(200, 200),
        padding: 1.0,
      );

      expect(visible.minX, greaterThanOrEqualTo(0));
      expect(visible.minY, greaterThanOrEqualTo(0));
      expect(visible.maxX, lessThan(grid.gridWidth));
      expect(visible.maxY, lessThan(grid.gridHeight));
    });
  });

  group('GridComponent - Isometric', () {
    late GridComponent grid;

    setUp(() {
      grid = GridComponent(
        gridWidth: 10,
        gridHeight: 10,
        tileSize: 64.0,
        gridType: GridType.isometric,
      );
    });

    test('should convert grid to screen coordinates (isometric)', () {
      // Origin (0,0) should be at (0, 0)
      final pos1 = grid.gridToScreen(0, 0);
      expect(pos1.x, 0);
      expect(pos1.y, 0);

      // Test isometric formula
      // screenX = (gridX - gridY) * tileSize / 2
      // screenY = (gridX + gridY) * tileSize / 4

      final pos2 = grid.gridToScreen(4, 0);
      expect(pos2.x, 128.0); // (4 - 0) * 64 / 2 = 128
      expect(pos2.y, 64.0); // (4 + 0) * 64 / 4 = 64

      final pos3 = grid.gridToScreen(0, 4);
      expect(pos3.x, -128.0); // (0 - 4) * 64 / 2 = -128
      expect(pos3.y, 64.0); // (0 + 4) * 64 / 4 = 64

      final pos4 = grid.gridToScreen(2, 2);
      expect(pos4.x, 0.0); // (2 - 2) * 64 / 2 = 0
      expect(pos4.y, 64.0); // (2 + 2) * 64 / 4 = 64
    });

    test('should convert screen to grid coordinates (isometric)', () {
      // Origin
      final grid1 = grid.screenToGrid(Vector2(0, 0));
      expect(grid1.x, 0);
      expect(grid1.y, 0);

      // Test inverse isometric formula
      final grid2 = grid.screenToGrid(Vector2(128, 64));
      expect(grid2.x, 4);
      expect(grid2.y, 0);

      final grid3 = grid.screenToGrid(Vector2(-128, 64));
      expect(grid3.x, 0);
      expect(grid3.y, 4);
    });

    test('isometric: grid -> screen -> grid should be consistent', () {
      // Test round-trip conversion
      final originalGrid = Vector2(5, 3);
      final screen = grid.gridToScreen(5, 3);
      final backToGrid = grid.screenToGrid(screen);

      expect(backToGrid.x, originalGrid.x);
      expect(backToGrid.y, originalGrid.y);
    });

    test('should calculate grid bounds (isometric)', () {
      final bounds = grid.getGridBounds();

      // Isometric grid creates a diamond shape
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));

      // The bounds should contain all corner points
      final topLeft = grid.gridToScreen(0, 0);
      final topRight = grid.gridToScreen(10, 0);
      final bottomLeft = grid.gridToScreen(0, 10);
      final bottomRight = grid.gridToScreen(10, 10);

      expect(bounds.contains(topLeft.toOffset()), true);
      expect(bounds.contains(topRight.toOffset()), true);
      expect(bounds.contains(bottomLeft.toOffset()), true);
      expect(bounds.contains(bottomRight.toOffset()), true);
    });
  });

  group('GridComponent - Spatial Culling', () {
    test('should calculate correct visible bounds for culling', () {
      final grid = GridComponent(
        gridWidth: 100,
        gridHeight: 100,
        tileSize: 64.0,
        gridType: GridType.orthogonal,
      );

      // Camera viewing center of grid
      final visible = grid.getVisibleBounds(
        cameraPosition: Vector2(3200, 3200), // Center of 100x100 grid
        viewportSize: Vector2(640, 640), // 10x10 tiles visible
        padding: 2.0,
      );

      // With padding of 2, we should see roughly 12-14 tiles in each direction
      final visibleWidth = visible.maxX - visible.minX;
      final visibleHeight = visible.maxY - visible.minY;

      expect(visibleWidth, lessThan(20)); // Should cull most tiles
      expect(visibleHeight, lessThan(20));
      expect(visibleWidth, greaterThan(8)); // But show enough with padding
      expect(visibleHeight, greaterThan(8));
    });

    test('should clamp visible bounds to grid limits', () {
      final grid = GridComponent(
        gridWidth: 10,
        gridHeight: 10,
        tileSize: 64.0,
        gridType: GridType.orthogonal,
      );

      // Camera viewing corner (should clamp)
      final visible = grid.getVisibleBounds(
        cameraPosition: Vector2(-100, -100), // Outside grid
        viewportSize: Vector2(640, 640),
        padding: 5.0, // Large padding
      );

      // Should be clamped to grid bounds
      expect(visible.minX, greaterThanOrEqualTo(0));
      expect(visible.minY, greaterThanOrEqualTo(0));
      expect(visible.maxX, lessThan(grid.gridWidth));
      expect(visible.maxY, lessThan(grid.gridHeight));
    });
  });
}
