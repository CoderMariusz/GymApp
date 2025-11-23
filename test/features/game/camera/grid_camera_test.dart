import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/camera/grid_camera.dart';

void main() {
  group('ZoomLevel', () {
    test('should have correct scale values', () {
      expect(ZoomLevel.city.scale, 0.5);
      expect(ZoomLevel.building.scale, 1.5);
    });
  });

  group('GridCamera', () {
    late GridCamera camera;
    final worldSize = Vector2(1000, 1000);

    setUp(() {
      camera = GridCamera(
        worldSize: worldSize,
        initialZoom: ZoomLevel.city,
        zoomSmoothness: 0.0, // Instant for testing
        panSmoothness: 0.0, // Instant for testing
      );
    });

    test('should initialize with correct properties', () {
      expect(camera.worldSize, worldSize);
      expect(camera.currentZoomLevel, ZoomLevel.city);
      expect(camera.currentZoom, 0.5);
      expect(camera.minZoom, 0.3);
      expect(camera.maxZoom, 3.0);
    });

    test('should set zoom level', () {
      camera.setZoomLevel(ZoomLevel.building, animate: false);

      expect(camera.currentZoomLevel, ZoomLevel.building);
      expect(camera.targetZoom, 1.5);
      expect(camera.currentZoom, 1.5);
    });

    test('should toggle between zoom levels', () {
      expect(camera.currentZoomLevel, ZoomLevel.city);

      camera.toggleZoom(animate: false);
      expect(camera.currentZoomLevel, ZoomLevel.building);

      camera.toggleZoom(animate: false);
      expect(camera.currentZoomLevel, ZoomLevel.city);
    });

    test('should set custom zoom', () {
      camera.setCustomZoom(2.0, animate: false);

      expect(camera.targetZoom, 2.0);
      expect(camera.currentZoom, 2.0);
    });

    test('should clamp custom zoom to min/max', () {
      camera.setCustomZoom(0.1, animate: false); // Below min
      expect(camera.currentZoom, 0.3); // Clamped to min

      camera.setCustomZoom(5.0, animate: false); // Above max
      expect(camera.currentZoom, 3.0); // Clamped to max
    });

    test('should zoom in and out', () {
      camera.setCustomZoom(1.0, animate: false);

      camera.zoomIn(0.5, animate: false);
      expect(camera.currentZoom, 1.5);

      camera.zoomOut(0.3, animate: false);
      expect(camera.currentZoom, 1.2);
    });

    test('should move camera to position', () {
      final targetPos = Vector2(500, 500);
      camera.moveTo(targetPos, animate: false);

      expect(camera.targetPosition, targetPos);
      expect(camera.currentPosition, targetPos);
    });

    test('should pan camera by delta', () {
      final initialPos = Vector2(500, 500);
      camera.moveTo(initialPos, animate: false);

      final delta = Vector2(100, 50);
      camera.pan(delta, animate: false);

      expect(camera.currentPosition.x, 600);
      expect(camera.currentPosition.y, 550);
    });

    test('should snap to grid position', () {
      final gridPos = Vector2(5, 5);
      final tileSize = 64.0;

      camera.snapToGrid(gridPos, tileSize);

      // Should move to gridPos * tileSize
      expect(camera.targetPosition.x, 320); // 5 * 64
      expect(camera.targetPosition.y, 320); // 5 * 64
    });

    test('should focus on position with zoom', () {
      final targetPos = Vector2(700, 700);

      camera.focusOn(
        targetPos,
        zoomLevel: ZoomLevel.building,
        animate: false,
      );

      expect(camera.currentPosition, targetPos);
      expect(camera.currentZoomLevel, ZoomLevel.building);
    });

    test('should calculate visible world area', () {
      camera.setZoomLevel(ZoomLevel.city, animate: false);
      camera.moveTo(Vector2(500, 500), animate: false);

      final visibleArea = camera.getVisibleWorldArea();

      expect(visibleArea.width, greaterThan(0));
      expect(visibleArea.height, greaterThan(0));

      // At zoom 0.5, visible area should be 2x world size
      expect(visibleArea.width, 2000); // 1000 / 0.5
      expect(visibleArea.height, 2000);
    });

    test('should detect when camera is animating', () {
      camera = GridCamera(
        worldSize: worldSize,
        initialZoom: ZoomLevel.city,
        zoomSmoothness: 0.5, // Smooth animation
        panSmoothness: 0.5,
      );

      expect(camera.isAnimating, false);

      // Start zoom animation
      camera.setZoomLevel(ZoomLevel.building, animate: true);
      expect(camera.isAnimating, true);
    });

    test('should smooth zoom over time', () {
      camera = GridCamera(
        worldSize: worldSize,
        initialZoom: ZoomLevel.city,
        zoomSmoothness: 0.5,
        panSmoothness: 0.0,
      );

      final initialZoom = camera.currentZoom;
      camera.setZoomLevel(ZoomLevel.building, animate: true);

      // Simulate update
      camera.update(0.016); // ~60fps

      // Zoom should have changed but not reached target yet
      expect(camera.currentZoom, greaterThan(initialZoom));
      expect(camera.currentZoom, lessThan(camera.targetZoom));
    });

    test('should smooth pan over time', () {
      camera = GridCamera(
        worldSize: worldSize,
        initialZoom: ZoomLevel.city,
        zoomSmoothness: 0.0,
        panSmoothness: 0.5,
      );

      final initialPos = Vector2(500, 500);
      camera.moveTo(initialPos, animate: false);

      final targetPos = Vector2(700, 700);
      camera.moveTo(targetPos, animate: true);

      // Simulate update
      camera.update(0.016);

      // Position should have changed but not reached target yet
      expect(camera.currentPosition.x, greaterThan(initialPos.x));
      expect(camera.currentPosition.x, lessThan(targetPos.x));
    });

    test('should reset camera to default state', () {
      // Move and zoom camera
      camera.setCustomZoom(2.5, animate: false);
      camera.moveTo(Vector2(100, 100), animate: false);

      // Reset
      camera.reset(animate: false);

      expect(camera.currentZoomLevel, ZoomLevel.city);
      expect(camera.currentZoom, 0.5);
      expect(camera.currentPosition, worldSize / 2);
    });

    test('should convert screen to world coordinates', () {
      camera.setCustomZoom(1.0, animate: false);
      camera.moveTo(Vector2(500, 500), animate: false);

      final screenPos = Vector2(600, 600);
      final worldPos = camera.screenToWorld(screenPos);

      // At zoom 1.0 and camera at center, offset should be direct
      expect(worldPos.x, closeTo(600, 1));
      expect(worldPos.y, closeTo(600, 1));
    });

    test('should convert world to screen coordinates', () {
      camera.setCustomZoom(1.0, animate: false);
      camera.moveTo(Vector2(500, 500), animate: false);

      final worldPos = Vector2(600, 600);
      final screenPos = camera.worldToScreen(worldPos);

      expect(screenPos.x, closeTo(600, 1));
      expect(screenPos.y, closeTo(600, 1));
    });

    test('world -> screen -> world conversion should be consistent', () {
      camera.setCustomZoom(1.5, animate: false);
      camera.moveTo(Vector2(400, 400), animate: false);

      final originalWorld = Vector2(700, 700);
      final screen = camera.worldToScreen(originalWorld);
      final backToWorld = camera.screenToWorld(screen);

      expect(backToWorld.x, closeTo(originalWorld.x, 1));
      expect(backToWorld.y, closeTo(originalWorld.y, 1));
    });
  });

  group('GridCamera - Position Clamping', () {
    test('should clamp camera position to world bounds', () {
      final worldSize = Vector2(1000, 1000);
      final camera = GridCamera(
        worldSize: worldSize,
        initialZoom: ZoomLevel.city,
        panSmoothness: 0.0,
      );

      // Try to move beyond world bounds
      camera.moveTo(Vector2(-500, -500), animate: false);

      // Should be clamped
      expect(camera.currentPosition.x, greaterThanOrEqualTo(0));
      expect(camera.currentPosition.y, greaterThanOrEqualTo(0));

      // Try upper bounds
      camera.moveTo(Vector2(2000, 2000), animate: false);

      expect(camera.currentPosition.x, lessThanOrEqualTo(worldSize.x));
      expect(camera.currentPosition.y, lessThanOrEqualTo(worldSize.y));
    });
  });
}
