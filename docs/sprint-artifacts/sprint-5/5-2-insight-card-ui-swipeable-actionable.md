# Story 5.2: Insight Card UI (Swipeable, Actionable)
**Epic:** 5 - Cross-Module Intelligence | **P0** | **3 SP** | **drafted**

## AC
1. ✅ Insight card on Home tab (top of feed)
2. ✅ Gradient background (Module A color → Module B color, e.g., Mind purple → Fitness orange)
3. ✅ Module icons shown (🏋️ Fitness + 🧠 Mind)
4. ✅ Insight title + description (clear, concise)
5. ✅ Recommendation + CTA (e.g., "Switch to light workout" button)
6. ✅ Swipe left → Dismiss, Swipe right → Save for later
7. ✅ Tap CTA → Opens relevant module with pre-filled action
8. ✅ Max 1 insight/day
9. ✅ View dismissed insights in history

**FRs:** FR82, FR83

## Tech
```dart
class InsightCard extends StatelessWidget {
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(insight.id),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          saveForLater(insight);
        } else {
          dismissInsight(insight);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.orange], // Mind → Fitness
          ),
        ),
        child: Column([
          Text(insight.title),
          Text(insight.description),
          ElevatedButton(
            onPressed: () => executeAction(insight.cta),
            child: Text(insight.cta),
          ),
        ]),
      ),
    );
  }
}
```
**Dependencies:** 5.1 | **Coverage:** 80%+
