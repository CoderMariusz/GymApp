import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource.freezed.dart';
part 'resource.g.dart';

/// Represents a resource type in the game (gold, wood, stone, etc.)
@freezed
class Resource with _$Resource {
  const Resource._();

  const factory Resource({
    required String id,
    required String type, // 'gold', 'wood', 'stone', 'food', etc.
    required String name,
    required String description,
    required String iconPath,
    @Default(1000) int maxStorage, // Maximum amount that can be stored
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Resource;

  factory Resource.fromJson(Map<String, dynamic> json) =>
      _$ResourceFromJson(json);

  /// Common resource types
  static Resource gold({required String id}) => Resource(
        id: id,
        type: 'gold',
        name: 'Gold',
        description: 'Primary currency for upgrades and purchases',
        iconPath: 'assets/resources/gold.png',
        maxStorage: 10000,
        createdAt: DateTime.now(),
      );

  static Resource wood({required String id}) => Resource(
        id: id,
        type: 'wood',
        name: 'Wood',
        description: 'Essential building material',
        iconPath: 'assets/resources/wood.png',
        maxStorage: 5000,
        createdAt: DateTime.now(),
      );

  static Resource stone({required String id}) => Resource(
        id: id,
        type: 'stone',
        name: 'Stone',
        description: 'Durable construction material',
        iconPath: 'assets/resources/stone.png',
        maxStorage: 5000,
        createdAt: DateTime.now(),
      );

  static Resource food({required String id}) => Resource(
        id: id,
        type: 'food',
        name: 'Food',
        description: 'Sustains population growth',
        iconPath: 'assets/resources/food.png',
        maxStorage: 3000,
        createdAt: DateTime.now(),
      );
}
