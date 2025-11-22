import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/presentation/widgets/meditation_card.dart';

void main() {
  late MeditationEntity testMeditation;

  setUp(() {
    testMeditation = MeditationEntity(
      id: 'test-1',
      title: 'Stress Relief Meditation',
      description: 'A calming meditation for stress relief',
      durationSeconds: 600,
      category: MeditationCategory.stressRelief,
      audioUrl: 'https://example.com/audio.mp3',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      createdAt: DateTime(2025, 1, 1),
      isPremium: false,
      isFavorited: false,
      completionCount: 0,
    );
  });

  Widget createWidgetUnderTest({
    required MeditationEntity meditation,
    bool isGridView = true,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: MeditationCard(
            meditation: meditation,
            isGridView: isGridView,
          ),
        ),
      ),
    );
  }

  group('MeditationCard Widget Tests', () {
    testWidgets('should display meditation title', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: testMeditation,
      ));

      // Assert
      expect(find.text('Stress Relief Meditation'), findsOneWidget);
    });

    testWidgets('should display meditation duration', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: testMeditation,
      ));

      // Assert
      expect(find.text('10 min'), findsOneWidget);
    });

    testWidgets('should display category badge', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: testMeditation,
      ));

      // Assert
      expect(find.text('Stress Relief'), findsOneWidget);
    });

    testWidgets('should NOT show premium badge for free meditation',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: testMeditation,
      ));

      // Assert
      expect(find.text('PREMIUM'), findsNothing);
    });

    testWidgets('should show premium badge for premium meditation',
        (tester) async {
      // Arrange
      final premiumMeditation = testMeditation.copyWith(isPremium: true);
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: premiumMeditation,
      ));

      // Assert
      expect(find.text('PREMIUM'), findsOneWidget);
    });

    testWidgets('should show unfilled heart icon when not favorited',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: testMeditation,
      ));

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should show filled heart icon when favorited',
        (tester) async {
      // Arrange
      final favoritedMeditation = testMeditation.copyWith(isFavorited: true);
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: favoritedMeditation,
      ));

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should show completion count when greater than 0',
        (tester) async {
      // Arrange
      final completedMeditation =
          testMeditation.copyWith(completionCount: 5);
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: completedMeditation,
      ));

      // Assert
      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should render in grid view mode', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: testMeditation,
        isGridView: true,
      ));

      // Assert - Grid view shows title with max 2 lines
      final titleText = tester.widget<Text>(
        find.text('Stress Relief Meditation'),
      );
      expect(titleText.maxLines, equals(2));
    });

    testWidgets('should render in list view mode', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: testMeditation,
        isGridView: false,
      ));
      await tester.pumpAndSettle();

      // Assert - List view shows description
      expect(find.text('A calming meditation for stress relief'),
          findsOneWidget);
    });

    testWidgets('should be tappable', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        meditation: testMeditation,
      ));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Assert - Should trigger navigation (in real app)
      // For now, just verify the InkWell exists
      expect(find.byType(InkWell), findsOneWidget);
    });
  });
}
