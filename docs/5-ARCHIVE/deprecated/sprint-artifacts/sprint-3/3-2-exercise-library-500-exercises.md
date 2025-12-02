# Story 3.2: Exercise Library (500+ Exercises)

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P0 | **Status:** ready-for-dev | **Effort:** 3 SP

---

## User Story
**As a** user logging workouts
**I want** to search 500+ exercises
**So that** I can track all my workouts accurately

---

## Acceptance Criteria
1. ✅ Exercise library with 500+ exercises (seeded on first launch)
2. ✅ Categories: Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other
3. ✅ Search bar with real-time filtering (<200ms)
4. ✅ Exercise details: Name, category, muscle groups, instructions
5. ✅ User can add custom exercises
6. ✅ Custom exercises saved to user's library
7. ✅ Favorite exercises (star icon) → Quick access
8. ✅ Instructions: Text description (P1: form videos)

**FRs:** FR32, FR33

---

## Technical Implementation

### Database Schema
```sql
-- Global exercises (read-only, seeded)
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  muscle_groups TEXT[], -- ['chest', 'triceps']
  instructions TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_exercises_name ON exercises USING GIN (to_tsvector('english', name));

-- User custom exercises
CREATE TABLE user_exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Favorites
CREATE TABLE exercise_favorites (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, exercise_id)
);
```

### Real-time Search
```dart
class ExerciseSearchDelegate extends SearchDelegate<Exercise> {
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Exercise>>(
      future: searchExercises(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ExerciseTile(snapshot.data![index]);
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### Seed Data (500+ exercises)
```sql
INSERT INTO exercises (name, category, muscle_groups, instructions) VALUES
  ('Bench Press', 'Chest', ARRAY['chest', 'triceps'], 'Lie on bench, lower bar to chest, press up'),
  ('Squat', 'Legs', ARRAY['quads', 'glutes'], 'Stand with bar on shoulders, squat down, stand up'),
  -- ... 498 more exercises
;
```

---

## Dependencies
**Prerequisites:** Epic 1
**Blocks:** Story 3.1 (Smart Pattern needs exercises)

**Coverage Target:** 80%+

---

## Dev Agent Record

### Context Reference

- **Story Context File:** [3-2-exercise-library-500-exercises.context.xml](./3-2-exercise-library-500-exercises.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
