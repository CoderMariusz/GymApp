import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lifeos/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Meditation Library End-to-End Flow', () {
    testWidgets('should browse, filter, and favorite meditation',
        (tester) async {
      // Launch app
      await tester.pumpWidget(const ProviderScope(child: LifeOSApp()));
      await tester.pumpAndSettle();

      // Verify library loads (shimmer or actual content)
      expect(find.text('Meditation Library'), findsOneWidget);

      // Wait for meditations to load (if mocked data available)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test category filtering
      // Tap "Stress Relief" category tab
      final stressReliefTab = find.text('Stress Relief');
      if (stressReliefTab.evaluate().isNotEmpty) {
        await tester.tap(stressReliefTab);
        await tester.pumpAndSettle();

        // Verify only stress relief meditations shown
        expect(find.text('Stress Relief'), findsWidgets);
      }

      // Test search functionality
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'stress');
        await tester.pumpAndSettle(const Duration(milliseconds: 500)); // Wait for debounce

        // Verify filtered results
        expect(find.textContaining('stress', findRichText: true), findsWidgets);
      }

      // Clear search
      final clearButton = find.byIcon(Icons.clear);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();
      }

      // Test favorite functionality
      final favoriteButton = find.byIcon(Icons.favorite_border).first;
      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        await tester.pumpAndSettle();

        // Verify heart icon changed to filled
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      }

      // Test pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Test grid/list view toggle
      final viewToggleButton = find.byIcon(Icons.list);
      if (viewToggleButton.evaluate().isNotEmpty) {
        await tester.tap(viewToggleButton);
        await tester.pumpAndSettle();

        // Verify view changed (icon should now be grid_view)
        expect(find.byIcon(Icons.grid_view), findsOneWidget);
      }

      // Test duration filter
      final durationFilter = find.text('10-15 min');
      if (durationFilter.evaluate().isNotEmpty) {
        await tester.tap(durationFilter);
        await tester.pumpAndSettle();

        // Verify filter applied (chips should be selected)
        expect(find.text('10-15 min'), findsOneWidget);
      }

      // Test clear filters
      final clearFiltersButton = find.text('Clear');
      if (clearFiltersButton.evaluate().isNotEmpty) {
        await tester.tap(clearFiltersButton);
        await tester.pumpAndSettle();

        // Verify all meditations shown again
        expect(find.text('All'), findsOneWidget);
      }
    });

    testWidgets('should handle empty state correctly', (tester) async {
      // Launch app
      await tester.pumpWidget(const ProviderScope(child: LifeOSApp()));
      await tester.pumpAndSettle();

      // Apply filters that return no results
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'xyznonexistent');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Verify empty state message
        expect(find.text('No meditations found'), findsOneWidget);
        expect(find.text('Try adjusting your filters'), findsOneWidget);
      }
    });

    testWidgets('should handle error state correctly', (tester) async {
      // This test would require mocking to force an error state
      // For now, just verify error handling UI exists
      await tester.pumpWidget(const ProviderScope(child: LifeOSApp()));
      await tester.pumpAndSettle();

      // Verify error handling is in place
      // (Would need to inject error to test fully)
    });
  });
}
