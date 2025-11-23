import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:lifeos/features/game/domain/entities/building.dart';

/// Callback when building is tapped
typedef BuildingTapCallback = void Function(String buildingId);

/// Visual component representing a building in the game
class BuildingComponent extends PositionComponent with TapCallbacks {
  BuildingComponent({
    required this.building,
    required this.tileSize,
    this.onTap,
    this.showDebugInfo = false,
  }) : super(
          position: Vector2.zero(),
          size: Vector2(tileSize, tileSize),
          anchor: Anchor.center,
        );

  /// The building entity
  Building building;

  /// Size of a single tile
  final double tileSize;

  /// Callback when building is tapped
  BuildingTapCallback? onTap;

  /// Whether to show debug information
  bool showDebugInfo;

  // Visual state
  bool _isHighlighted = false;
  bool _isCollectable = false;
  double _animationTime = 0.0;

  // Sprite placeholder (would be loaded from assets)
  late Paint _buildingPaint;
  late Paint _highlightPaint;
  late Paint _collectablePaint;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Initialize paints
    _buildingPaint = Paint()..color = _getBuildingColor();

    _highlightPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    _collectablePaint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update animation time
    _animationTime += dt;

    // Check if building is collectable
    _isCollectable = building.canCollect(DateTime.now());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render building base
    _renderBuildingBase(canvas);

    // Render building sprite (placeholder)
    _renderBuildingSprite(canvas);

    // Render highlight if selected
    if (_isHighlighted) {
      _renderHighlight(canvas);
    }

    // Render collectable indicator
    if (_isCollectable) {
      _renderCollectableIndicator(canvas);
    }

    // Render debug info
    if (showDebugInfo) {
      _renderDebugInfo(canvas);
    }

    // Render level indicator
    _renderLevelIndicator(canvas);
  }

  /// Render building base (shadow/ground)
  void _renderBuildingBase(Canvas canvas) {
    final basePaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final baseRect = Rect.fromLTWH(
      -tileSize * 0.4,
      tileSize * 0.3,
      tileSize * 0.8,
      tileSize * 0.2,
    );

    canvas.drawOval(baseRect, basePaint);
  }

  /// Render building sprite (placeholder - would load from assets)
  void _renderBuildingSprite(Canvas canvas) {
    // Placeholder: draw colored rectangle representing building
    final buildingRect = Rect.fromLTWH(
      -tileSize * 0.4,
      -tileSize * 0.4,
      tileSize * 0.8,
      tileSize * 0.8,
    );

    canvas.drawRect(buildingRect, _buildingPaint);

    // Draw building icon/symbol
    _drawBuildingIcon(canvas);

    // Animate if upgrading
    if (building.status == BuildingStatus.upgrading) {
      _renderUpgradingAnimation(canvas);
    }
  }

  /// Draw building icon based on type
  void _drawBuildingIcon(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getBuildingIcon(),
        style: TextStyle(
          fontSize: tileSize * 0.3,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  /// Render highlight when selected
  void _renderHighlight(Canvas canvas) {
    final highlightRect = Rect.fromLTWH(
      -tileSize * 0.45,
      -tileSize * 0.45,
      tileSize * 0.9,
      tileSize * 0.9,
    );

    canvas.drawRect(highlightRect, _highlightPaint);
  }

  /// Render collectable indicator (pulsing green outline)
  void _renderCollectableIndicator(Canvas canvas) {
    final pulse = (0.5 + 0.5 * (1 + sin(_animationTime * 3))).clamp(0.3, 1.0);

    final collectPaint = Paint()
      ..color = Colors.green.withOpacity(pulse * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final collectRect = Rect.fromLTWH(
      -tileSize * 0.45,
      -tileSize * 0.45,
      tileSize * 0.9,
      tileSize * 0.9,
    );

    canvas.drawRect(collectRect, collectPaint);
  }

  /// Render upgrading animation (spinning effect)
  void _renderUpgradingAnimation(Canvas canvas) {
    final angle = _animationTime * 2; // Rotation speed

    canvas.save();
    canvas.rotate(angle);

    final upgradePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final radius = tileSize * 0.5;
    canvas.drawCircle(Offset.zero, radius, upgradePaint);

    canvas.restore();
  }

  /// Render level indicator
  void _renderLevelIndicator(Canvas canvas) {
    final levelText = 'L${building.level}';

    final textPainter = TextPainter(
      text: TextSpan(
        text: levelText,
        style: TextStyle(
          fontSize: tileSize * 0.15,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            const Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        tileSize * 0.25,
        -tileSize * 0.45,
      ),
    );
  }

  /// Render debug information
  void _renderDebugInfo(Canvas canvas) {
    final accumulated = building.calculateAccumulatedResources(DateTime.now());
    final debugText = '${building.type.displayName}\n'
        'Lvl: ${building.level}\n'
        'Res: $accumulated/${building.storageCapacity}\n'
        'Status: ${building.status.name}';

    final textPainter = TextPainter(
      text: TextSpan(
        text: debugText,
        style: TextStyle(
          fontSize: tileSize * 0.08,
          color: Colors.white,
          backgroundColor: Colors.black.withOpacity(0.7),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, tileSize * 0.5),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isHighlighted = true;
    onTap?.call(building.id);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isHighlighted = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isHighlighted = false;
  }

  /// Update building entity
  void updateBuilding(Building newBuilding) {
    building = newBuilding;
    _buildingPaint.color = _getBuildingColor();
  }

  /// Get building color based on type
  Color _getBuildingColor() {
    switch (building.type) {
      case BuildingType.mine:
        return Colors.amber.shade700;
      case BuildingType.lumberMill:
        return Colors.brown.shade600;
      case BuildingType.quarry:
        return Colors.grey.shade600;
      case BuildingType.farm:
        return Colors.green.shade700;
      case BuildingType.gemMine:
        return Colors.purple.shade700;
    }
  }

  /// Get building icon emoji
  String _getBuildingIcon() {
    switch (building.type) {
      case BuildingType.mine:
        return '⛏️';
      case BuildingType.lumberMill:
        return '🪓';
      case BuildingType.quarry:
        return '🪨';
      case BuildingType.farm:
        return '🌾';
      case BuildingType.gemMine:
        return '💎';
    }
  }

  /// Get building resource fill percentage
  double get resourceFillPercentage {
    return building.getFillPercentage(DateTime.now());
  }

  /// Check if building needs attention (full or ready)
  bool get needsAttention {
    return _isCollectable || building.isAtCapacity(DateTime.now());
  }
}
