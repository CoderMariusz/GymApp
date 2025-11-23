import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/game/domain/entities/building.dart';
import 'package:lifeos/features/game/systems/asset_loader.dart';

void main() {
  group('BuildingAssets', () {
    test('should generate correct sprite path for building', () {
      final path = BuildingAssets.getBuildingSprite(
        type: BuildingType.mine,
        level: 1,
        status: BuildingStatus.ready,
      );

      expect(path, 'assets/game/buildings/mine_level_1.png');
    });

    test('should generate upgrading sprite path', () {
      final path = BuildingAssets.getBuildingSprite(
        type: BuildingType.mine,
        level: 1,
        status: BuildingStatus.upgrading,
      );

      expect(path, 'assets/game/buildings/mine_level_1_upgrading.png');
    });

    test('should generate sprites for all levels', () {
      final sprites = BuildingAssets.getAllSpritesForType(BuildingType.mine);

      // 10 levels × 2 states (ready + upgrading) = 20 sprites
      expect(sprites.length, 20);
    });

    test('should generate sprites for all building types', () {
      final allSprites = BuildingAssets.getAllBuildingSprites();

      // 5 building types × 10 levels × 2 states = 100 sprites
      expect(allSprites.length, 100);
    });

    test('should generate resource icon path', () {
      final path = BuildingAssets.getResourceIcon('gold');
      expect(path, 'assets/game/resources/gold_icon.png');
    });

    test('should generate UI element path', () {
      final path = BuildingAssets.getUIElement('button_collect');
      expect(path, 'assets/game/ui/button_collect.png');
    });

    test('should include all building types in sprite list', () {
      final allSprites = BuildingAssets.getAllBuildingSprites();

      for (final type in BuildingType.values) {
        final hasType = allSprites.any((path) => path.contains(type.value));
        expect(hasType, true, reason: 'Missing sprites for ${type.value}');
      }
    });
  });

  group('AssetLoadResult', () {
    test('should calculate completion correctly', () {
      final result = AssetLoadResult(loaded: 50, total: 100, errors: []);

      expect(result.isComplete, false);
      expect(result.progress, 0.5);
      expect(result.hasErrors, false);
    });

    test('should detect when complete', () {
      final result = AssetLoadResult(loaded: 100, total: 100, errors: []);

      expect(result.isComplete, true);
      expect(result.progress, 1.0);
    });

    test('should detect errors', () {
      final result = AssetLoadResult(
        loaded: 95,
        total: 100,
        errors: ['Failed to load sprite1.png'],
      );

      expect(result.hasErrors, true);
      expect(result.errors.length, 1);
    });

    test('should handle zero total', () {
      final result = AssetLoadResult(loaded: 0, total: 0, errors: []);

      expect(result.progress, 0.0);
    });
  });

  group('GameAssetLoader', () {
    late GameAssetLoader loader;

    setUp(() {
      loader = GameAssetLoader();
    });

    test('should load all assets', () async {
      final result = await loader.loadAllAssets();

      expect(result.isComplete, true);
      expect(result.loaded, 100); // All building sprites
      expect(result.hasErrors, false);
    });

    test('should track loaded assets', () async {
      await loader.loadAllAssets();

      final path = BuildingAssets.getBuildingSprite(
        type: BuildingType.mine,
        level: 1,
        status: BuildingStatus.ready,
      );

      expect(loader.isAssetLoaded(path), true);
    });

    test('should report correct load progress', () async {
      // Start loading
      final loadFuture = loader.loadAllAssets();

      // Progress should be tracked
      expect(loader.loadProgress, greaterThanOrEqualTo(0.0));
      expect(loader.loadProgress, lessThanOrEqualTo(1.0));

      // Wait for completion
      await loadFuture;

      expect(loader.loadProgress, 1.0);
    });

    test('should clear loaded assets', () async {
      await loader.loadAllAssets();

      expect(loader.loadProgress, 1.0);

      loader.clear();

      expect(loader.loadProgress, 0.0);
    });

    test('should handle checking non-loaded asset', () {
      final isLoaded = loader.isAssetLoaded('nonexistent.png');

      expect(isLoaded, false);
    });
  });

  group('Asset Organization', () {
    test('should organize sprites by type and level', () {
      final mineSprites = BuildingAssets.getAllSpritesForType(BuildingType.mine);
      final lumberSprites = BuildingAssets.getAllSpritesForType(
        BuildingType.lumberMill,
      );

      // Each type should have same number of sprites
      expect(mineSprites.length, lumberSprites.length);

      // But different paths
      expect(mineSprites.first, isNot(equals(lumberSprites.first)));
    });

    test('should have unique paths for each asset', () {
      final allSprites = BuildingAssets.getAllBuildingSprites();
      final uniquePaths = allSprites.toSet();

      expect(uniquePaths.length, allSprites.length);
    });

    test('should use consistent naming convention', () {
      final allSprites = BuildingAssets.getAllBuildingSprites();

      for (final sprite in allSprites) {
        // All should start with base path
        expect(sprite.startsWith(BuildingAssets.basePath), true);

        // All should end with .png
        expect(sprite.endsWith('.png'), true);

        // All should contain level information
        expect(sprite.contains('_level_'), true);
      }
    });
  });
}
