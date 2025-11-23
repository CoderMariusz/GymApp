import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' show Colors;

/// Grid type enumeration
enum GridType {
  /// Standard orthogonal grid (square tiles)
  orthogonal,

  /// Isometric grid (diamond-shaped tiles)
  isometric,
}

/// Component that renders and manages a grid system
class GridComponent extends Component {
  GridComponent({
    required this.gridWidth,
    required this.gridHeight,
    required this.tileSize,
    this.gridType = GridType.orthogonal,
    this.showGrid = true,
    this.gridColor = const Color(0x40FFFFFF),
    this.gridLineWidth = 1.0,
  });

  /// Number of tiles horizontally
  final int gridWidth;

  /// Number of tiles vertically
  final int gridHeight;

  /// Size of each tile in pixels
  final double tileSize;

  /// Type of grid (orthogonal or isometric)
  final GridType gridType;

  /// Whether to show grid lines
  bool showGrid;

  /// Color of grid lines
  Color gridColor;

  /// Width of grid lines
  double gridLineWidth;

  /// Paint for grid lines
  late final Paint _gridPaint;

  @override
  void onLoad() {
    super.onLoad();
    _gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = gridLineWidth
      ..style = PaintingStyle.stroke;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!showGrid) return;

    switch (gridType) {
      case GridType.orthogonal:
        _renderOrthogonalGrid(canvas);
        break;
      case GridType.isometric:
        _renderIsometricGrid(canvas);
        break;
    }
  }

  /// Render orthogonal (square) grid
  void _renderOrthogonalGrid(Canvas canvas) {
    // Vertical lines
    for (int x = 0; x <= gridWidth; x++) {
      final xPos = x * tileSize;
      canvas.drawLine(
        Offset(xPos, 0),
        Offset(xPos, gridHeight * tileSize),
        _gridPaint,
      );
    }

    // Horizontal lines
    for (int y = 0; y <= gridHeight; y++) {
      final yPos = y * tileSize;
      canvas.drawLine(
        Offset(0, yPos),
        Offset(gridWidth * tileSize, yPos),
        _gridPaint,
      );
    }
  }

  /// Render isometric (diamond) grid
  void _renderIsometricGrid(Canvas canvas) {
    // Draw diamond-shaped grid
    for (int y = 0; y <= gridHeight; y++) {
      for (int x = 0; x <= gridWidth; x++) {
        final screenPos = gridToScreen(x, y);

        // Draw horizontal diamond edges (going right-down)
        if (x < gridWidth) {
          final nextRight = gridToScreen(x + 1, y);
          canvas.drawLine(
            screenPos.toOffset(),
            nextRight.toOffset(),
            _gridPaint,
          );
        }

        // Draw vertical diamond edges (going left-down)
        if (y < gridHeight) {
          final nextDown = gridToScreen(x, y + 1);
          canvas.drawLine(
            screenPos.toOffset(),
            nextDown.toOffset(),
            _gridPaint,
          );
        }
      }
    }
  }

  /// Convert grid coordinates to screen coordinates
  Vector2 gridToScreen(int gridX, int gridY) {
    switch (gridType) {
      case GridType.orthogonal:
        return Vector2(
          gridX * tileSize,
          gridY * tileSize,
        );

      case GridType.isometric:
        // Isometric formula:
        // screenX = (gridX - gridY) * tileSize / 2
        // screenY = (gridX + gridY) * tileSize / 4
        final halfTile = tileSize / 2;
        final quarterTile = tileSize / 4;

        return Vector2(
          (gridX - gridY) * halfTile,
          (gridX + gridY) * quarterTile,
        );
    }
  }

  /// Convert screen coordinates to grid coordinates
  Vector2 screenToGrid(Vector2 screenPos) {
    switch (gridType) {
      case GridType.orthogonal:
        return Vector2(
          (screenPos.x / tileSize).floorToDouble(),
          (screenPos.y / tileSize).floorToDouble(),
        );

      case GridType.isometric:
        // Inverse isometric formula:
        // gridX = (screenX / (tileSize/2) + screenY / (tileSize/4)) / 2
        // gridY = (screenY / (tileSize/4) - screenX / (tileSize/2)) / 2
        final halfTile = tileSize / 2;
        final quarterTile = tileSize / 4;

        final tx = screenPos.x / halfTile;
        final ty = screenPos.y / quarterTile;

        return Vector2(
          ((tx + ty) / 2).floorToDouble(),
          ((ty - tx) / 2).floorToDouble(),
        );
    }
  }

  /// Check if grid coordinates are valid
  bool isValidGridPosition(int x, int y) {
    return x >= 0 && x < gridWidth && y >= 0 && y < gridHeight;
  }

  /// Get visible grid bounds for spatial culling
  /// Returns (minX, minY, maxX, maxY)
  ({int minX, int minY, int maxX, int maxY}) getVisibleBounds({
    required Vector2 cameraPosition,
    required Vector2 viewportSize,
    double padding = 2.0,
  }) {
    // Calculate corners of viewport in screen space
    final topLeft = cameraPosition;
    final bottomRight = cameraPosition + viewportSize;

    // Convert to grid coordinates
    final gridTopLeft = screenToGrid(topLeft);
    final gridBottomRight = screenToGrid(bottomRight);

    // Add padding and clamp to grid bounds
    final minX = (gridTopLeft.x - padding).floor().clamp(0, gridWidth - 1);
    final minY = (gridTopLeft.y - padding).floor().clamp(0, gridHeight - 1);
    final maxX = (gridBottomRight.x + padding).ceil().clamp(0, gridWidth - 1);
    final maxY = (gridBottomRight.y + padding).ceil().clamp(0, gridHeight - 1);

    return (minX: minX, minY: minY, maxX: maxX, maxY: maxY);
  }

  /// Get center position of grid in screen coordinates
  Vector2 getGridCenter() {
    final centerX = gridWidth ~/ 2;
    final centerY = gridHeight ~/ 2;
    return gridToScreen(centerX, centerY);
  }

  /// Get bounds of the entire grid in screen coordinates
  Rect getGridBounds() {
    switch (gridType) {
      case GridType.orthogonal:
        return Rect.fromLTWH(
          0,
          0,
          gridWidth * tileSize,
          gridHeight * tileSize,
        );

      case GridType.isometric:
        // For isometric, calculate all corners
        final topLeft = gridToScreen(0, 0);
        final topRight = gridToScreen(gridWidth, 0);
        final bottomLeft = gridToScreen(0, gridHeight);
        final bottomRight = gridToScreen(gridWidth, gridHeight);

        final minX = [topLeft.x, topRight.x, bottomLeft.x, bottomRight.x]
            .reduce((a, b) => a < b ? a : b);
        final maxX = [topLeft.x, topRight.x, bottomLeft.x, bottomRight.x]
            .reduce((a, b) => a > b ? a : b);
        final minY = [topLeft.y, topRight.y, bottomLeft.y, bottomRight.y]
            .reduce((a, b) => a < b ? a : b);
        final maxY = [topLeft.y, topRight.y, bottomLeft.y, bottomRight.y]
            .reduce((a, b) => a > b ? a : b);

        return Rect.fromLTRB(minX, minY, maxX, maxY);
    }
  }
}
