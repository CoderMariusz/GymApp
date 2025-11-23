import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';

/// Callback for tap events with grid position
typedef TapCallback = void Function(Vector2 gridPosition);

/// Callback for pan/swipe events
typedef PanCallback = void Function(Vector2 delta);

/// Callback for zoom events
typedef ZoomCallback = void Function(double scale);

/// Component that handles all gesture inputs for the game
class GestureHandler extends Component
    with
        TapCallbacks,
        DoubleTapCallbacks,
        PanDetector,
        ScaleDetector,
        ScrollDetector {
  GestureHandler({
    this.onTap,
    this.onDoubleTap,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onZoom,
    this.onScroll,
    this.doubleTapTimeThreshold = 300,
    this.panThreshold = 5.0,
  });

  /// Callback for single tap
  TapCallback? onTap;

  /// Callback for double tap (toggle zoom)
  TapCallback? onDoubleTap;

  /// Callback for pan start
  PanCallback? onPanStart;

  /// Callback for pan update
  PanCallback? onPanUpdate;

  /// Callback for pan end
  PanCallback? onPanEnd;

  /// Callback for pinch zoom
  ZoomCallback? onZoom;

  /// Callback for scroll wheel zoom
  ZoomCallback? onScroll;

  /// Maximum time between taps to register as double tap (ms)
  final int doubleTapTimeThreshold;

  /// Minimum distance to register as pan (pixels)
  final double panThreshold;

  // Internal state
  DateTime? _lastTapTime;
  Vector2? _lastTapPosition;
  Vector2? _panStartPosition;
  bool _isPanning = false;
  double _lastScale = 1.0;

  @override
  void onTapDown(TapDownEvent event) {
    final now = DateTime.now();
    final position = event.localPosition;

    // Check for double tap
    if (_lastTapTime != null && _lastTapPosition != null) {
      final timeDiff = now.difference(_lastTapTime!).inMilliseconds;
      final distanceDiff = (position - _lastTapPosition!).length;

      if (timeDiff < doubleTapTimeThreshold && distanceDiff < 20) {
        // Double tap detected
        _handleDoubleTap(position);
        _lastTapTime = null;
        _lastTapPosition = null;
        return;
      }
    }

    // Single tap - wait to see if it becomes a double tap
    _lastTapTime = now;
    _lastTapPosition = position;

    // Schedule single tap callback after threshold
    Future.delayed(Duration(milliseconds: doubleTapTimeThreshold), () {
      if (_lastTapTime == now && !_isPanning) {
        _handleTap(position);
      }
    });
  }

  void _handleTap(Vector2 position) {
    onTap?.call(position);
  }

  void _handleDoubleTap(Vector2 position) {
    onDoubleTap?.call(position);
  }

  @override
  void onPanStart(DragStartEvent event) {
    _panStartPosition = event.localPosition;
    _isPanning = false; // Not panning until we exceed threshold
  }

  @override
  void onPanUpdate(DragUpdateEvent event) {
    if (_panStartPosition == null) return;

    final delta = event.localDelta;

    // Check if we've exceeded pan threshold
    if (!_isPanning) {
      final totalDelta = event.localPosition - _panStartPosition!;
      if (totalDelta.length > panThreshold) {
        _isPanning = true;
        onPanStart?.call(delta);
      }
    }

    if (_isPanning) {
      onPanUpdate?.call(delta);
    }
  }

  @override
  void onPanEnd(DragEndEvent event) {
    if (_isPanning) {
      final velocity = event.velocity;
      final velocityVector = Vector2(velocity.x, velocity.y);
      onPanEnd?.call(velocityVector);
    }

    _panStartPosition = null;
    _isPanning = false;
  }

  @override
  void onPanCancel() {
    _panStartPosition = null;
    _isPanning = false;
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    _lastScale = 1.0;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    // Only handle pinch zoom, not rotation
    final scale = info.scale.global;
    final scaleDelta = scale - _lastScale;

    if (scaleDelta.abs() > 0.01) {
      onZoom?.call(scaleDelta);
      _lastScale = scale;
    }
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    _lastScale = 1.0;
  }

  @override
  void onScroll(PointerScrollEvent event) {
    // Mouse wheel scroll for zoom
    final scrollDelta = event.scrollDelta.dy;

    // Normalize scroll delta (different devices have different scales)
    final zoomDelta = -scrollDelta / 1000;

    onScroll?.call(zoomDelta);
  }

  /// Reset gesture handler state
  void reset() {
    _lastTapTime = null;
    _lastTapPosition = null;
    _panStartPosition = null;
    _isPanning = false;
    _lastScale = 1.0;
  }
}
