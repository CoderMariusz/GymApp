import 'package:lifeos/features/game/domain/entities/building.dart';

/// Asset paths for building sprites
class BuildingAssets {
  BuildingAssets._();

  /// Base path for game assets
  static const String basePath = 'assets/game';

  /// Get sprite path for building type and level
  static String getBuildingSprite({
    required BuildingType type,
    required int level,
    required BuildingStatus status,
  }) {
    final typeName = type.value;
    final statusSuffix = status == BuildingStatus.upgrading ? '_upgrading' : '';

    return '$basePath/buildings/${typeName}_level_${level}$statusSuffix.png';
  }

  /// Get all sprite paths for a building type (all levels)
  static List<String> getAllSpritesForType(BuildingType type) {
    final sprites = <String>[];

    for (int level = 1; level <= 10; level++) {
      sprites.add(getBuildingSprite(
        type: type,
        level: level,
        status: BuildingStatus.ready,
      ));

      sprites.add(getBuildingSprite(
        type: type,
        level: level,
        status: BuildingStatus.upgrading,
      ));
    }

    return sprites;
  }

  /// Get all sprite paths for all building types
  static List<String> getAllBuildingSprites() {
    final allSprites = <String>[];

    for (final type in BuildingType.values) {
      allSprites.addAll(getAllSpritesForType(type));
    }

    return allSprites;
  }

  /// Get resource icon path
  static String getResourceIcon(String resourceType) {
    return '$basePath/resources/${resourceType}_icon.png';
  }

  /// Get UI element path
  static String getUIElement(String elementName) {
    return '$basePath/ui/$elementName.png';
  }
}

/// Asset loading result
class AssetLoadResult {
  const AssetLoadResult({
    required this.loaded,
    required this.total,
    required this.errors,
  });

  final int loaded;
  final int total;
  final List<String> errors;

  bool get isComplete => loaded == total;
  double get progress => total > 0 ? loaded / total : 0.0;
  bool get hasErrors => errors.isNotEmpty;
}

/// Mock asset loader for testing and development
/// In production, this would use Flame's asset loading system
class GameAssetLoader {
  final Map<String, bool> _loadedAssets = {};
  final List<String> _errors = [];

  /// Load all game assets
  Future<AssetLoadResult> loadAllAssets() async {
    final allAssets = BuildingAssets.getAllBuildingSprites();

    for (final assetPath in allAssets) {
      await _loadAsset(assetPath);
    }

    return AssetLoadResult(
      loaded: _loadedAssets.length,
      total: allAssets.length,
      errors: List.from(_errors),
    );
  }

  /// Load specific asset
  Future<void> _loadAsset(String path) async {
    // Simulate asset loading delay
    await Future.delayed(const Duration(milliseconds: 1));

    // Mock successful load
    _loadedAssets[path] = true;
  }

  /// Check if asset is loaded
  bool isAssetLoaded(String path) {
    return _loadedAssets[path] ?? false;
  }

  /// Get load progress
  double get loadProgress {
    if (_loadedAssets.isEmpty) return 0.0;
    return _loadedAssets.length / BuildingAssets.getAllBuildingSprites().length;
  }

  /// Clear all loaded assets
  void clear() {
    _loadedAssets.clear();
    _errors.clear();
  }
}
