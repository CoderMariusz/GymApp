import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/components/gesture_handler.dart';

void main() {
  group('GestureHandler', () {
    late GestureHandler handler;

    setUp(() {
      handler = GestureHandler();
    });

    test('should initialize with default properties', () {
      expect(handler.doubleTapTimeThreshold, 300);
      expect(handler.panThreshold, 5.0);
      expect(handler.onTap, isNull);
      expect(handler.onDoubleTap, isNull);
      expect(handler.onPanUpdate, isNull);
      expect(handler.onZoom, isNull);
    });

    test('should accept callbacks in constructor', () {
      var tapCalled = false;
      var doubleTapCalled = false;
      var panUpdateCalled = false;
      var zoomCalled = false;

      handler = GestureHandler(
        onTap: (pos) => tapCalled = true,
        onDoubleTap: (pos) => doubleTapCalled = true,
        onPanUpdate: (delta) => panUpdateCalled = true,
        onZoom: (scale) => zoomCalled = true,
      );

      expect(handler.onTap, isNotNull);
      expect(handler.onDoubleTap, isNotNull);
      expect(handler.onPanUpdate, isNotNull);
      expect(handler.onZoom, isNotNull);
    });

    test('should reset internal state', () {
      handler.reset();

      // After reset, all internal state should be cleared
      // This is mainly to ensure no crashes and proper cleanup
      expect(() => handler.reset(), returnsNormally);
    });

    test('should have configurable thresholds', () {
      handler = GestureHandler(
        doubleTapTimeThreshold: 500,
        panThreshold: 10.0,
      );

      expect(handler.doubleTapTimeThreshold, 500);
      expect(handler.panThreshold, 10.0);
    });

    test('should allow setting callbacks after construction', () {
      expect(handler.onTap, isNull);

      handler.onTap = (pos) {
        // Callback logic
      };

      expect(handler.onTap, isNotNull);
    });

    test('should allow removing callbacks', () {
      handler.onTap = (pos) {
        // Callback logic
      };
      expect(handler.onTap, isNotNull);

      handler.onTap = null;
      expect(handler.onTap, isNull);
    });
  });

  group('GestureHandler - Callback Types', () {
    test('TapCallback should accept Vector2 position', () {
      TapCallback callback = (Vector2 position) {
        expect(position, isA<Vector2>());
      };

      callback(Vector2(100, 200));
    });

    test('PanCallback should accept Vector2 delta', () {
      PanCallback callback = (Vector2 delta) {
        expect(delta, isA<Vector2>());
      };

      callback(Vector2(10, 20));
    });

    test('ZoomCallback should accept double scale', () {
      ZoomCallback callback = (double scale) {
        expect(scale, isA<double>());
      };

      callback(1.5);
    });
  });

  group('GestureHandler - Integration', () {
    test('should handle multiple gesture types', () {
      var tapCount = 0;
      var doubleTapCount = 0;
      var panCount = 0;
      var zoomCount = 0;

      handler = GestureHandler(
        onTap: (pos) => tapCount++,
        onDoubleTap: (pos) => doubleTapCount++,
        onPanUpdate: (delta) => panCount++,
        onZoom: (scale) => zoomCount++,
      );

      // Simulate tap
      handler.onTap?.call(Vector2(100, 100));
      expect(tapCount, 1);

      // Simulate double tap
      handler.onDoubleTap?.call(Vector2(100, 100));
      expect(doubleTapCount, 1);

      // Simulate pan
      handler.onPanUpdate?.call(Vector2(10, 10));
      expect(panCount, 1);

      // Simulate zoom
      handler.onZoom?.call(0.5);
      expect(zoomCount, 1);
    });

    test('should capture gesture data correctly', () {
      Vector2? capturedTapPosition;
      Vector2? capturedPanDelta;
      double? capturedZoomScale;

      handler = GestureHandler(
        onTap: (pos) => capturedTapPosition = pos,
        onPanUpdate: (delta) => capturedPanDelta = delta,
        onZoom: (scale) => capturedZoomScale = scale,
      );

      final tapPos = Vector2(150, 250);
      handler.onTap?.call(tapPos);
      expect(capturedTapPosition, tapPos);

      final panDelta = Vector2(25, 35);
      handler.onPanUpdate?.call(panDelta);
      expect(capturedPanDelta, panDelta);

      const zoomScale = 1.8;
      handler.onZoom?.call(zoomScale);
      expect(capturedZoomScale, zoomScale);
    });
  });

  group('GestureHandler - Edge Cases', () {
    test('should handle zero pan delta', () {
      var panCalled = false;
      Vector2? capturedDelta;

      handler = GestureHandler(
        onPanUpdate: (delta) {
          panCalled = true;
          capturedDelta = delta;
        },
      );

      handler.onPanUpdate?.call(Vector2.zero());

      expect(panCalled, true);
      expect(capturedDelta, Vector2.zero());
    });

    test('should handle negative zoom scale', () {
      var zoomCalled = false;
      double? capturedScale;

      handler = GestureHandler(
        onZoom: (scale) {
          zoomCalled = true;
          capturedScale = scale;
        },
      );

      handler.onZoom?.call(-0.5);

      expect(zoomCalled, true);
      expect(capturedScale, -0.5);
    });

    test('should handle very large position values', () {
      var tapCalled = false;
      Vector2? capturedPosition;

      handler = GestureHandler(
        onTap: (pos) {
          tapCalled = true;
          capturedPosition = pos;
        },
      );

      final largePos = Vector2(999999, 999999);
      handler.onTap?.call(largePos);

      expect(tapCalled, true);
      expect(capturedPosition, largePos);
    });
  });

  group('GestureHandler - Callback Chains', () {
    test('should support multiple callbacks in sequence', () {
      final events = <String>[];

      handler = GestureHandler(
        onPanStart: (delta) => events.add('panStart'),
        onPanUpdate: (delta) => events.add('panUpdate'),
        onPanEnd: (velocity) => events.add('panEnd'),
      );

      handler.onPanStart?.call(Vector2.zero());
      handler.onPanUpdate?.call(Vector2(10, 10));
      handler.onPanUpdate?.call(Vector2(20, 20));
      handler.onPanEnd?.call(Vector2(5, 5));

      expect(events, ['panStart', 'panUpdate', 'panUpdate', 'panEnd']);
    });
  });
}
