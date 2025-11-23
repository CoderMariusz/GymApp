import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:lifeos/features/game/camera/grid_camera.dart';
import 'package:lifeos/features/game/components/building_component.dart';
import 'package:lifeos/features/game/components/gesture_handler.dart';
import 'package:lifeos/features/game/components/grid_component.dart';
import 'package:lifeos/features/game/domain/entities/building.dart';
import 'package:lifeos/features/game/domain/entities/player_economy.dart';
import 'package:lifeos/features/game/domain/usecases/collect_resources.dart';
import 'package:lifeos/features/game/domain/usecases/upgrade_building.dart';

/// Main game world that integrates all components
class GameWorld extends FlameGame {
  GameWorld({
    required this.gridWidth,
    required this.gridHeight,
    required this.tileSize,
    this.gridType = GridType.orthogonal,
  });

  final int gridWidth;
  final int gridHeight;
  final double tileSize;
  final GridType gridType;

  // Game state
  late PlayerEconomy playerEconomy;
  final Map<String, Building> buildings = {};
  final Map<String, BuildingComponent> buildingComponents = {};

  // Components
  late GridComponent gridComponent;
  late GridCamera gridCamera;
  late GestureHandler gestureHandler;

  // Use cases
  final collectResourcesUseCase = CollectResourcesUseCase();
  final upgradeBuildingUseCase = UpgradeBuildingUseCase();

  // Selected building
  String? selectedBuildingId;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Initialize player economy
    playerEconomy = PlayerEconomy.initial('player1');

    // Create grid component
    gridComponent = GridComponent(
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      tileSize: tileSize,
      gridType: gridType,
    );

    // Create camera
    final worldSize = Vector2(
      gridWidth * tileSize,
      gridHeight * tileSize,
    );

    gridCamera = GridCamera(
      worldSize: worldSize,
      initialZoom: ZoomLevel.city,
    );

    camera = gridCamera;

    // Add grid to world
    world.add(gridComponent);

    // Setup gesture handler
    gestureHandler = GestureHandler(
      onDoubleTap: _handleDoubleTap,
      onPanUpdate: _handlePan,
      onZoom: _handleZoom,
      onScroll: _handleScroll,
    );

    world.add(gestureHandler);
  }

  /// Add a building to the game world
  void addBuilding(Building building) {
    buildings[building.id] = building;

    // Create visual component
    final component = BuildingComponent(
      building: building,
      tileSize: tileSize,
      onTap: _handleBuildingTap,
    );

    // Position on grid
    final screenPos = gridComponent.gridToScreen(
      building.gridX,
      building.gridY,
    );
    component.position = screenPos;

    buildingComponents[building.id] = component;
    world.add(component);
  }

  /// Remove a building from the game world
  void removeBuilding(String buildingId) {
    buildings.remove(buildingId);

    final component = buildingComponents.remove(buildingId);
    component?.removeFromParent();
  }

  /// Collect resources from a building
  void collectFromBuilding(String buildingId) {
    final building = buildings[buildingId];
    if (building == null) return;

    final result = collectResourcesUseCase.execute(
      building: building,
      playerEconomy: playerEconomy,
    );

    if (result.success) {
      // Update game state
      buildings[buildingId] = result.building;
      playerEconomy = result.playerEconomy;

      // Update visual component
      buildingComponents[buildingId]?.updateBuilding(result.building);
    }
  }

  /// Collect from all ready buildings
  void collectFromAllBuildings() {
    final results = collectResourcesUseCase.collectAllReady(
      buildings: buildings.values.toList(),
      playerEconomy: playerEconomy,
    );

    // Update state for successful collections
    for (final entry in results.entries) {
      if (entry.value.success) {
        final buildingId = entry.key;
        buildings[buildingId] = entry.value.building;
        buildingComponents[buildingId]?.updateBuilding(entry.value.building);
      }
    }

    // Update player economy from last result
    if (results.isNotEmpty) {
      playerEconomy = results.values.last.playerEconomy;
    }
  }

  /// Start upgrading a building
  bool startBuildingUpgrade(String buildingId) {
    final building = buildings[buildingId];
    if (building == null) return false;

    final result = upgradeBuildingUseCase.startUpgrade(
      building: building,
      playerEconomy: playerEconomy,
    );

    if (result.success) {
      buildings[buildingId] = result.building;
      playerEconomy = result.playerEconomy;
      buildingComponents[buildingId]?.updateBuilding(result.building);
      return true;
    }

    return false;
  }

  /// Complete building upgrade
  bool completeBuildingUpgrade(String buildingId, DateTime upgradeStartTime) {
    final building = buildings[buildingId];
    if (building == null) return false;

    final completed = upgradeBuildingUseCase.completeUpgrade(
      building: building,
      upgradeStartTime: upgradeStartTime,
    );

    if (completed != null) {
      buildings[buildingId] = completed;
      buildingComponents[buildingId]?.updateBuilding(completed);
      return true;
    }

    return false;
  }

  /// Handle building tap
  void _handleBuildingTap(String buildingId) {
    selectedBuildingId = buildingId;
    // In a real game, this would show a UI panel
  }

  /// Handle double tap (toggle zoom)
  void _handleDoubleTap(Vector2 position) {
    gridCamera.toggleZoom();
  }

  /// Handle pan (move camera)
  void _handlePan(Vector2 delta) {
    // Invert delta for natural panning
    gridCamera.pan(-delta);
  }

  /// Handle pinch zoom
  void _handleZoom(double scaleDelta) {
    if (scaleDelta > 0) {
      gridCamera.zoomIn(scaleDelta * 0.5);
    } else {
      gridCamera.zoomOut(-scaleDelta * 0.5);
    }
  }

  /// Handle scroll wheel zoom
  void _handleScroll(double scrollDelta) {
    if (scrollDelta > 0) {
      gridCamera.zoomIn(scrollDelta);
    } else {
      gridCamera.zoomOut(-scrollDelta);
    }
  }

  /// Get building at grid position
  Building? getBuildingAt(int gridX, int gridY) {
    return buildings.values.firstWhere(
      (b) => b.gridX == gridX && b.gridY == gridY,
      orElse: () => throw StateError('No building found'),
    );
  }

  /// Check if position is occupied
  bool isPositionOccupied(int gridX, int gridY) {
    return buildings.values.any(
      (b) => b.gridX == gridX && b.gridY == gridY,
    );
  }

  /// Get total resource count
  int getTotalResources() {
    return playerEconomy.resources.values.fold(
      0,
      (sum, resource) => sum + resource.amount,
    );
  }

  /// Get building count
  int get buildingCount => buildings.length;

  /// Get buildings needing attention (full or ready to collect)
  List<Building> getBuildingsNeedingAttention() {
    final now = DateTime.now();
    return buildings.values.where((b) {
      return b.canCollect(now) || b.isAtCapacity(now);
    }).toList();
  }
}
