import '../../domain/entities/goal.dart';
import '../../domain/entities/morning_check_in.dart';
import '../../domain/entities/user_preferences.dart';

class CalendarEvent {
  final String title;
  final String startTime;
  final String endTime;

  CalendarEvent({
    required this.title,
    required this.startTime,
    required this.endTime,
  });
}

class DailyPlanPrompt {
  static String buildSystemPrompt() => '''
You are a personal life coach AI for LifeOS app.

Generate a realistic, achievable daily plan based on:
- User's goals (short-term & long-term)
- Morning check-in (mood, energy, sleep quality)
- Calendar events (from user's schedule)
- Past performance (completion rate, habits)
- User preferences (work hours, exercise time)

Rules:
1. Generate 6-8 tasks (realistic, not overwhelming)
2. Balance categories:
   - 30% productivity (work, learning)
   - 25% fitness (exercise, movement)
   - 20% wellness (meditation, breaks)
   - 15% personal (hobbies, relationships)
   - 10% social (friends, family)
3. Respect energy levels:
   - High-energy tasks (workouts, deep work) → Morning (7am-11am)
   - Medium-energy tasks (meetings, errands) → Midday (11am-3pm)
   - Low-energy tasks (reading, journaling) → Evening (6pm-9pm)
4. Include breaks every 2-3 hours
5. Align tasks with user's stated goals
6. Don't overlap with calendar events
7. Total task time should be 6-8 hours (rest of day is free)

Output format (JSON):
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Morning HIIT Workout",
      "description": "30 min high-intensity interval training",
      "category": "fitness",
      "priority": "high",
      "estimated_duration": 30,
      "suggested_time": "07:00",
      "energy_level": "high",
      "why": "Boosts energy and mood for the day ahead"
    }
  ],
  "daily_theme": "Focus on high-impact tasks in AM, recovery in PM",
  "motivational_quote": "The secret of getting ahead is getting started. - Mark Twain"
}

Important:
- Use realistic task durations (no 5-min workouts or 4-hour deep work sessions)
- Make tasks SPECIFIC (not "exercise" but "30 min yoga + 10 min stretching")
- Ensure variety (not 5 fitness tasks in a row)
- Consider user's mood/energy (if low, suggest gentler activities)
''';

  static String buildUserPrompt({
    required MorningCheckIn? checkIn,
    required List<Goal> goals,
    required List<CalendarEvent> events,
    required UserPreferences prefs,
    required DateTime targetDate,
  }) {
    final checkInContext = checkIn != null
        ? '''
Morning Check-In:
- Mood: ${checkIn.mood}/10 (${_interpretMood(checkIn.mood)})
- Energy: ${checkIn.energy}/10 (${_interpretEnergy(checkIn.energy)})
- Sleep: ${checkIn.sleepQuality}/10 quality, ${checkIn.sleepHours}h duration
- Notes: ${checkIn.notes ?? 'None'}
'''
        : 'No morning check-in completed yet.';

    final goalsContext = goals.isEmpty
        ? 'No active goals set.'
        : '''
Active Goals:
${goals.take(5).map((g) => '- ${g.title} (category: ${g.category.name}, deadline: ${_formatDate(g.targetDate)})').join('\n')}
''';

    final eventsContext = events.isEmpty
        ? 'No calendar events today.'
        : '''
Calendar Events:
${events.map((e) => '- ${e.startTime}-${e.endTime}: ${e.title}').join('\n')}
''';

    final prefsContext = '''
User Preferences:
- Work hours: ${prefs.workStartTime} - ${prefs.workEndTime}
- Preferred exercise time: ${prefs.preferredExerciseTime ?? 'Flexible'}
- Morning person: ${prefs.isMorningPerson ? 'Yes' : 'No'}
- Focus areas: ${prefs.focusAreas.join(', ')}
''';

    return '''
Generate a personalized daily plan for ${_formatDate(targetDate)}.

$checkInContext

$goalsContext

$eventsContext

$prefsContext

Generate today's plan (JSON format):
''';
  }

  static String _interpretMood(int mood) {
    if (mood >= 8) return 'Excellent';
    if (mood >= 6) return 'Good';
    if (mood >= 4) return 'Okay';
    return 'Low';
  }

  static String _interpretEnergy(int energy) {
    if (energy >= 8) return 'Very high';
    if (energy >= 6) return 'Good';
    if (energy >= 4) return 'Moderate';
    return 'Low';
  }

  static String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[date.weekday - 1]}, ${date.day}/${date.month}/${date.year}';
  }
}
