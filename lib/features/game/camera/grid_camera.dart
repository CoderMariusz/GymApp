import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Zoom level for the camera
enum ZoomLevel {
  /// City view - zoomed out to see entire grid
  city(0.5),

  /// Building view - zoomed in to see individual buildings
  building(1.5);

  const ZoomLevel(this.scale);

  /// Zoom scale factor
  final double scale;
}

/// Camera configuration for grid-based games
class GridCamera extends CameraComponent {
  GridCamera({
    required this.worldSize,
    ZoomLevel initialZoom = ZoomLevel.city,
    Vector2? initialPosition,
    this.minZoom = 0.3,
    this.maxZoom = 3.0,
    this.zoomSmoothness = 0.15,
    this.panSmoothness = 0.2,
  })  : _currentZoomLevel = initialZoom,
        _targetZoom = initialZoom.scale,
        _currentZoom = initialZoom.scale {
    // Set initial viewport
    viewport = FixedResolutionViewport(resolution: worldSize);

    // Initialize camera position
    if (initialPosition != null) {
      _targetPosition = initialPosition;
      _currentPosition = initialPosition;
    }
  }

  /// Size of the game world
  final Vector2 worldSize;

  /// Minimum zoom scale
  final double minZoom;

  /// Maximum zoom scale
  final double maxZoom;

  /// Smoothness of zoom transitions (0.0 = instant, 1.0 = very slow)
  final double zoomSmoothness;

  /// Smoothness of pan transitions (0.0 = instant, 1.0 = very slow)
  final double panSmoothness;

  /// Current zoom level
  ZoomLevel _currentZoomLevel;
  ZoomLevel get currentZoomLevel => _currentZoomLevel;

  /// Target zoom scale (for smooth transitions)
  double _targetZoom;
  double get targetZoom => _targetZoom;

  /// Current zoom scale (interpolated)
  double _currentZoom;
  double get currentZoom => _currentZoom;

  /// Target camera position (for smooth panning)
  Vector2 _targetPosition = Vector2.zero();
  Vector2 get targetPosition => _targetPosition;

  /// Current camera position (interpolated)
  Vector2 _currentPosition = Vector2.zero();
  Vector2 get currentPosition => _currentPosition;

  /// Whether camera is currently animating
  bool get isAnimating =>
      (_currentZoom - _targetZoom).abs() > 0.01 ||
      (_currentPosition - _targetPosition).length > 0.5;

  @override
  void update(double dt) {
    super.update(dt);

    // Smooth zoom interpolation
    final zoomDiff = _targetZoom - _currentZoom;
    if (zoomDiff.abs() > 0.001) {
      _currentZoom += zoomDiff * (1 - zoomSmoothness);
      viewfinder.zoom = _currentZoom;
    } else {
      _currentZoom = _targetZoom;
    }

    // Smooth position interpolation
    final positionDiff = _targetPosition - _currentPosition;
    if (positionDiff.length > 0.1) {
      _currentPosition += positionDiff * (1 - panSmoothness);
      viewfinder.position = _currentPosition;
    } else {
      _currentPosition = _targetPosition.clone();
    }
  }

  /// Set zoom to a specific level
  void setZoomLevel(ZoomLevel level, {bool animate = true}) {
    _currentZoomLevel = level;
    _targetZoom = level.scale.clamp(minZoom, maxZoom);

    if (!animate) {
      _currentZoom = _targetZoom;
      viewfinder.zoom = _currentZoom;
    }
  }

  /// Toggle between city and building view
  void toggleZoom({bool animate = true}) {
    final newLevel = _currentZoomLevel == ZoomLevel.city
        ? ZoomLevel.building
        : ZoomLevel.city;
    setZoomLevel(newLevel, animate: animate);
  }

  /// Set zoom to a custom scale
  void setCustomZoom(double zoom, {bool animate = true}) {
    _targetZoom = zoom.clamp(minZoom, maxZoom);

    if (!animate) {
      _currentZoom = _targetZoom;
      viewfinder.zoom = _currentZoom;
    }
  }

  /// Zoom in by a delta amount
  void zoomIn(double delta, {bool animate = true}) {
    setCustomZoom(_targetZoom + delta, animate: animate);
  }

  /// Zoom out by a delta amount
  void zoomOut(double delta, {bool animate = true}) {
    setCustomZoom(_targetZoom - delta, animate: animate);
  }

  /// Move camera to a specific position
  void moveTo(Vector2 position, {bool animate = true}) {
    _targetPosition = _clampPosition(position);

    if (!animate) {
      _currentPosition = _targetPosition.clone();
      viewfinder.position = _currentPosition;
    }
  }

  /// Pan camera by a delta
  void pan(Vector2 delta, {bool animate = true}) {
    moveTo(_targetPosition + delta, animate: animate);
  }

  /// Snap camera to grid position
  void snapToGrid(Vector2 gridPosition, double tileSize) {
    final worldPosition = Vector2(
      gridPosition.x * tileSize,
      gridPosition.y * tileSize,
    );
    moveTo(worldPosition, animate: true);
  }

  /// Focus camera on a specific world position with zoom
  void focusOn(Vector2 position, {ZoomLevel? zoomLevel, bool animate = true}) {
    moveTo(position, animate: animate);
    if (zoomLevel != null) {
      setZoomLevel(zoomLevel, animate: animate);
    }
  }

  /// Clamp camera position to world bounds
  Vector2 _clampPosition(Vector2 position) {
    // Get viewport size in world coordinates
    final viewportWorldSize = worldSize / _currentZoom;

    // Calculate bounds
    final minX = viewportWorldSize.x / 2;
    final maxX = worldSize.x - viewportWorldSize.x / 2;
    final minY = viewportWorldSize.y / 2;
    final maxY = worldSize.y - viewportWorldSize.y / 2;

    return Vector2(
      position.x.clamp(minX, maxX),
      position.y.clamp(minY, maxY),
    );
  }

  /// Get visible area in world coordinates
  Rect getVisibleWorldArea() {
    final viewportWorldSize = worldSize / _currentZoom;
    final halfSize = viewportWorldSize / 2;

    return Rect.fromLTWH(
      _currentPosition.x - halfSize.x,
      _currentPosition.y - halfSize.y,
      viewportWorldSize.x,
      viewportWorldSize.y,
    );
  }

  /// Convert screen position to world position
  Vector2 screenToWorld(Vector2 screenPosition) {
    // Account for zoom and camera position
    final viewportCenter = worldSize / 2;
    final offset = (screenPosition - viewportCenter) / _currentZoom;
    return _currentPosition + offset;
  }

  /// Convert world position to screen position
  Vector2 worldToScreen(Vector2 worldPosition) {
    // Account for zoom and camera position
    final viewportCenter = worldSize / 2;
    final offset = (worldPosition - _currentPosition) * _currentZoom;
    return viewportCenter + offset;
  }

  /// Shake camera (for effects)
  void shake({
    double intensity = 10.0,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    // TODO: Implement camera shake effect
    // This would require a more complex shake system with decay
  }

  /// Reset camera to default position and zoom
  void reset({bool animate = true}) {
    setZoomLevel(ZoomLevel.city, animate: animate);
    moveTo(worldSize / 2, animate: animate);
  }
}
