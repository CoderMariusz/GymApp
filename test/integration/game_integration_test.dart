import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/components/grid_component.dart';
import 'package:lifeos/features/game/domain/entities/building.dart';
import 'package:lifeos/features/game/domain/entities/player_economy.dart';
import 'package:lifeos/features/game/domain/entities/resource.dart';
import 'package:lifeos/features/game/domain/usecases/collect_resources.dart';
import 'package:lifeos/features/game/domain/usecases/upgrade_building.dart';
import 'package:lifeos/features/game/game_world.dart';

/// Full integration test for EPIC-01 gameplay loop
///
/// This test validates the complete feature:
/// 1. Grid system + Camera
/// 2. Building placement
/// 3. Resource production & collection
/// 4. Building upgrades
/// 5. Economy management
void main() {
  group('EPIC-01 Integration Test - Full Gameplay Loop', () {
    late GameWorld gameWorld;
    late PlayerEconomy playerEconomy;
    late DateTime testTime;

    setUp(() {
      testTime = DateTime(2024, 1, 1, 12, 0, 0);

      // Initialize game world with grid
      gameWorld = GameWorld(
        gridWidth: 20,
        gridHeight: 20,
        tileSize: 64.0,
        gridType: GridType.orthogonal,
      );

      // Initialize player economy
      playerEconomy = PlayerEconomy.initial('player1');
    });

    test('Complete Gameplay Loop: Build → Produce → Collect → Upgrade', () async {
      // Initialize game world
      await gameWorld.onLoad();

      // STEP 1: Place initial buildings on grid
      final mine = Building(
        id: 'mine1',
        type: BuildingType.mine,
        level: 1,
        gridX: 5,
        gridY: 5,
        status: BuildingStatus.ready,
        lastCollectionTime: testTime,
        accumulatedResources: 0,
      );

      final lumberMill = Building(
        id: 'lumber1',
        type: BuildingType.lumberMill,
        level: 1,
        gridX: 7,
        gridY: 5,
        status: BuildingStatus.ready,
        lastCollectionTime: testTime,
        accumulatedResources: 0,
      );

      gameWorld.addBuilding(mine);
      gameWorld.addBuilding(lumberMill);

      expect(gameWorld.buildingCount, 2);
      expect(gameWorld.isPositionOccupied(5, 5), true);
      expect(gameWorld.isPositionOccupied(7, 5), true);
      expect(gameWorld.isPositionOccupied(10, 10), false);

      // STEP 2: Simulate time passage (resources accumulate)
      final oneHourLater = testTime.add(const Duration(hours: 1));

      final updatedMine = mine.copyWith(
        lastCollectionTime: testTime,
      );

      gameWorld.buildings['mine1'] = updatedMine;

      final accumulated = updatedMine.calculateAccumulatedResources(oneHourLater);
      expect(accumulated, 15); // Level 1 mine produces 15/hour

      // STEP 3: Collect resources from buildings
      gameWorld.playerEconomy = playerEconomy;

      final initialGold = gameWorld.playerEconomy.getResourceAmount(
        ResourceType.gold,
      );

      // Collect from mine
      gameWorld.collectFromBuilding('mine1');

      final afterCollectGold = gameWorld.playerEconomy.getResourceAmount(
        ResourceType.gold,
      );

      expect(afterCollectGold, greaterThan(initialGold));

      // STEP 4: Collect from all buildings
      final beforeCollectAll = gameWorld.getTotalResources();

      gameWorld.collectFromAllBuildings();

      final afterCollectAll = gameWorld.getTotalResources();

      expect(afterCollectAll, greaterThanOrEqualTo(beforeCollectAll));

      // STEP 5: Verify economy was updated
      expect(
        gameWorld.playerEconomy.getResourceAmount(ResourceType.gold),
        greaterThan(playerEconomy.getResourceAmount(ResourceType.gold)),
      );

      // STEP 6: Upgrade a building
      // First, give player enough resources
      gameWorld.playerEconomy = gameWorld.playerEconomy
          .addResource(ResourceType.gold, 500)
          .addResource(ResourceType.wood, 500)
          .addResource(ResourceType.stone, 500);

      final beforeUpgradeGold = gameWorld.playerEconomy.getResourceAmount(
        ResourceType.gold,
      );

      final upgradeSuccess = gameWorld.startBuildingUpgrade('mine1');

      expect(upgradeSuccess, true);

      final afterUpgradeGold = gameWorld.playerEconomy.getResourceAmount(
        ResourceType.gold,
      );

      // Gold should be deducted
      expect(afterUpgradeGold, lessThan(beforeUpgradeGold));

      // Building should be upgrading
      final upgradingMine = gameWorld.buildings['mine1']!;
      expect(upgradingMine.status, BuildingStatus.upgrading);

      // STEP 7: Complete upgrade
      final upgradeStartTime = DateTime.now();
      final upgradeCompleteTime = upgradeStartTime.add(
        Duration(seconds: upgradingMine.upgradeDurationSeconds),
      );

      final completeSuccess = gameWorld.completeBuildingUpgrade(
        'mine1',
        upgradeStartTime,
      );

      expect(completeSuccess, true);

      final upgradedMine = gameWorld.buildings['mine1']!;
      expect(upgradedMine.level, 2);
      expect(upgradedMine.status, BuildingStatus.ready);

      // STEP 8: Verify upgraded building produces more
      final level2ProductionRate = upgradedMine.productionRatePerHour;
      expect(level2ProductionRate, 30); // Level 2 = 10 * 2 * 1.5

      // STEP 9: Test grid coordinate conversions
      final gridPos = gameWorld.gridComponent.gridToScreen(5, 5);
      final backToGrid = gameWorld.gridComponent.screenToGrid(gridPos);

      expect(backToGrid.x, 5);
      expect(backToGrid.y, 5);

      // STEP 10: Verify spatial culling works
      final visibleBounds = gameWorld.gridComponent.getVisibleBounds(
        cameraPosition: Vector2(320, 320),
        viewportSize: Vector2(640, 640),
      );

      expect(visibleBounds.minX, greaterThanOrEqualTo(0));
      expect(visibleBounds.maxX, lessThan(gameWorld.gridWidth));

      // STEP 11: Test camera zoom
      gameWorld.gridCamera.setZoomLevel(ZoomLevel.building, animate: false);
      expect(gameWorld.gridCamera.currentZoomLevel, ZoomLevel.building);

      gameWorld.gridCamera.toggleZoom(animate: false);
      expect(gameWorld.gridCamera.currentZoomLevel, ZoomLevel.city);
    });

    test('Multi-Building Production and Collection Loop', () async {
      await gameWorld.onLoad();

      // Place multiple buildings of different types
      final buildings = [
        Building(
          id: 'mine1',
          type: BuildingType.mine,
          level: 1,
          gridX: 5,
          gridY: 5,
          status: BuildingStatus.ready,
          lastCollectionTime: testTime,
          accumulatedResources: 20,
        ),
        Building(
          id: 'lumber1',
          type: BuildingType.lumberMill,
          level: 1,
          gridX: 7,
          gridY: 5,
          status: BuildingStatus.ready,
          lastCollectionTime: testTime,
          accumulatedResources: 15,
        ),
        Building(
          id: 'quarry1',
          type: BuildingType.quarry,
          level: 1,
          gridX: 9,
          gridY: 5,
          status: BuildingStatus.ready,
          lastCollectionTime: testTime,
          accumulatedResources: 25,
        ),
      ];

      for (final building in buildings) {
        gameWorld.addBuilding(building);
      }

      expect(gameWorld.buildingCount, 3);

      // Collect from all
      gameWorld.playerEconomy = PlayerEconomy.initial('player1');
      gameWorld.collectFromAllBuildings();

      // Verify different resource types were collected
      final gold = gameWorld.playerEconomy.getResourceAmount(ResourceType.gold);
      final wood = gameWorld.playerEconomy.getResourceAmount(ResourceType.wood);
      final stone = gameWorld.playerEconomy.getResourceAmount(ResourceType.stone);

      expect(gold, greaterThan(100)); // Initial + collected
      expect(wood, greaterThan(50)); // Initial + collected
      expect(stone, greaterThan(50)); // Initial + collected
    });

    test('Building Upgrade Chain: Level 1 → Level 5', () async {
      await gameWorld.onLoad();

      var building = Building(
        id: 'mine1',
        type: BuildingType.mine,
        level: 1,
        gridX: 5,
        gridY: 5,
        status: BuildingStatus.ready,
        lastCollectionTime: testTime,
        accumulatedResources: 0,
      );

      gameWorld.addBuilding(building);

      // Give player massive resources for testing
      gameWorld.playerEconomy = PlayerEconomy.initial('player1')
          .addResource(ResourceType.gold, 50000)
          .addResource(ResourceType.wood, 50000)
          .addResource(ResourceType.stone, 50000);

      // Upgrade from level 1 to level 5
      for (int targetLevel = 2; targetLevel <= 5; targetLevel++) {
        final upgradeSuccess = gameWorld.startBuildingUpgrade('mine1');
        expect(upgradeSuccess, true);

        final upgradeStartTime = DateTime.now();
        gameWorld.completeBuildingUpgrade('mine1', upgradeStartTime);

        final currentBuilding = gameWorld.buildings['mine1']!;
        expect(currentBuilding.level, targetLevel);
      }

      final finalBuilding = gameWorld.buildings['mine1']!;
      expect(finalBuilding.level, 5);
      expect(finalBuilding.productionRatePerHour, 75); // 10 * 5 * 1.5
      expect(finalBuilding.storageCapacity, 2500); // 100 * 5 * 5
    });

    test('Grid Placement Validation', () async {
      await gameWorld.onLoad();

      final building1 = Building(
        id: 'mine1',
        type: BuildingType.mine,
        level: 1,
        gridX: 5,
        gridY: 5,
        status: BuildingStatus.ready,
        lastCollectionTime: testTime,
      );

      gameWorld.addBuilding(building1);

      // Position should be occupied
      expect(gameWorld.isPositionOccupied(5, 5), true);

      // Adjacent positions should be free
      expect(gameWorld.isPositionOccupied(6, 5), false);
      expect(gameWorld.isPositionOccupied(5, 6), false);

      // Validate grid positions
      expect(gameWorld.gridComponent.isValidGridPosition(5, 5), true);
      expect(gameWorld.gridComponent.isValidGridPosition(-1, 0), false);
      expect(gameWorld.gridComponent.isValidGridPosition(100, 100), false);
    });

    test('Camera and Grid Coordinate System Integration', () async {
      await gameWorld.onLoad();

      // Test orthogonal grid conversion
      final gridPos = Vector2(10, 10);
      final screenPos = gameWorld.gridComponent.gridToScreen(
        gridPos.x.toInt(),
        gridPos.y.toInt(),
      );
      final backToGrid = gameWorld.gridComponent.screenToGrid(screenPos);

      expect(backToGrid.x, 10);
      expect(backToGrid.y, 10);

      // Test camera focus
      gameWorld.gridCamera.focusOn(
        screenPos,
        zoomLevel: ZoomLevel.building,
        animate: false,
      );

      expect(gameWorld.gridCamera.targetPosition, screenPos);
      expect(gameWorld.gridCamera.currentZoomLevel, ZoomLevel.building);
    });

    test('Resource Production Over Time', () async {
      await gameWorld.onLoad();

      final building = Building(
        id: 'mine1',
        type: BuildingType.mine,
        level: 3,
        gridX: 5,
        gridY: 5,
        status: BuildingStatus.ready,
        lastCollectionTime: testTime,
        accumulatedResources: 0,
      );

      gameWorld.addBuilding(building);

      // Level 3 production rate: 10 * 3 * 1.5 = 45 per hour
      expect(building.productionRatePerHour, 45);

      // After 2 hours
      final twoHoursLater = testTime.add(const Duration(hours: 2));
      final accumulated = building.calculateAccumulatedResources(twoHoursLater);

      expect(accumulated, 90); // 45 * 2

      // Storage capacity at level 3: 100 * 3 * 3 = 900
      expect(building.storageCapacity, 900);
      expect(accumulated, lessThan(building.storageCapacity));
    });

    test('Buildings Needing Attention Detection', () async {
      await gameWorld.onLoad();

      // Building with resources (needs attention)
      final readyBuilding = Building(
        id: 'mine1',
        type: BuildingType.mine,
        level: 1,
        gridX: 5,
        gridY: 5,
        status: BuildingStatus.ready,
        lastCollectionTime: testTime.subtract(const Duration(hours: 2)),
        accumulatedResources: 30,
      );

      // Building upgrading (doesn't need attention for collection)
      final upgradingBuilding = Building(
        id: 'lumber1',
        type: BuildingType.lumberMill,
        level: 1,
        gridX: 7,
        gridY: 5,
        status: BuildingStatus.upgrading,
        lastCollectionTime: testTime,
        accumulatedResources: 0,
      );

      gameWorld.addBuilding(readyBuilding);
      gameWorld.addBuilding(upgradingBuilding);

      final needingAttention = gameWorld.getBuildingsNeedingAttention();

      expect(needingAttention.length, greaterThan(0));
      expect(needingAttention.any((b) => b.id == 'mine1'), true);
    });

    test('Complete Game Session: 10 Buildings, Multiple Upgrades, Collections', () async {
      await gameWorld.onLoad();

      // Scenario: Player manages 10 buildings over simulated time
      gameWorld.playerEconomy = PlayerEconomy.initial('player1')
          .addResource(ResourceType.gold, 100000)
          .addResource(ResourceType.wood, 100000)
          .addResource(ResourceType.stone, 100000);

      // Place 10 buildings
      for (int i = 0; i < 10; i++) {
        final building = Building(
          id: 'building$i',
          type: BuildingType.values[i % BuildingType.values.length],
          level: 1,
          gridX: i * 2,
          gridY: 5,
          status: BuildingStatus.ready,
          lastCollectionTime: testTime,
          accumulatedResources: i * 5,
        );

        gameWorld.addBuilding(building);
      }

      expect(gameWorld.buildingCount, 10);

      // Collect from all buildings
      final beforeCollect = gameWorld.getTotalResources();
      gameWorld.collectFromAllBuildings();
      final afterCollect = gameWorld.getTotalResources();

      expect(afterCollect, greaterThan(beforeCollect));

      // Upgrade 5 buildings
      int upgradeCount = 0;
      for (final buildingId in gameWorld.buildings.keys.take(5)) {
        if (gameWorld.startBuildingUpgrade(buildingId)) {
          upgradeCount++;
        }
      }

      expect(upgradeCount, 5);

      // Complete all upgrades
      final now = DateTime.now();
      for (final buildingId in gameWorld.buildings.keys.take(5)) {
        gameWorld.completeBuildingUpgrade(buildingId, now);
      }

      // Verify upgrades
      int level2Count = 0;
      for (final building in gameWorld.buildings.values) {
        if (building.level == 2) level2Count++;
      }

      expect(level2Count, 5);
    });
  });
}
