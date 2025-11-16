# GymApp - Sprint 2 Backlog

**Sprint Number:** 2
**Sprint Duration:** 2 weeks (10 working days)
**Sprint Dates:** [After Sprint 1 completion]
**Team:** Solo Developer (Mariusz)
**Sprint Goal:** Complete Epic 1 (Foundation & Infrastructure) with Riverpod state management, navigation routing, and design system

---

## Sprint Goal

**Primary Goal:**
> "By the end of Sprint 2, GymApp has complete technical foundation with Riverpod state management implemented, navigation infrastructure with go_router, and comprehensive design system with custom components - fully enabling Epic 2 (Authentication) and Epic 4 (Workout Logging) development."

**Success Criteria:**
- ✅ Riverpod 2.x integrated with provider patterns and code generation
- ✅ go_router navigation with 10+ routes defined and auth guards
- ✅ Design system with Light/Dark themes and 6+ custom components
- ✅ Bottom navigation bar implemented (Home, Workouts, Progress, Profile)
- ✅ Accessibility compliance (WCAG AA, screen reader support)
- ✅ **BONUS:** High-priority deferred items from Sprint 1 completed

---

## Team Capacity

### Capacity Calculation

| Team Member | Role | Availability | Velocity (SP/day) | Sprint Capacity |
|-------------|------|--------------|-------------------|-----------------|
| **Mariusz** | Full-Stack Developer | 10 days × 8 hours = 80 hours | 2 SP/day | **20 Story Points** |

**Assumptions:**
- Solo developer working full-time on GymApp
- 8-hour working days
- Velocity: 2 SP/day (based on Sprint 1 performance)
- No major holidays or planned time off during sprint

**Capacity Adjustment Factors:**
- **Sprint 1 Velocity:** Adjust based on actual Sprint 1 completion rate
- **Lessons Learned:** Apply improvements from Sprint 1 retrospective
- **Committed Capacity:** **16 SP** (conservative, with 4 SP buffer)

---

## Sprint Backlog

### Epic 1: Foundation & Infrastructure (Continued)

**Total Epic Points:** 40 SP
**Sprint 1 Completed:** 11 SP (Stories 1.1-1.3)
**Sprint 2 Allocation:** 16 SP (Stories 1.4-1.6)
**Remaining for Sprint 3:** 13 SP (Stories 1.7-1.8 + deferred items)

| Story ID | Story Title | Story Points | Priority | Status |
|----------|-------------|--------------|----------|--------|
| **1.4** | State Management with Riverpod Architecture | **5 SP** | P0 - CRITICAL | 📋 To Do |
| **1.5** | Navigation and Routing Infrastructure | **3 SP** | P0 - CRITICAL | 📋 To Do |
| **1.6** | Design System and Theming | **8 SP** | P0 - CRITICAL | 📋 To Do |

**Sprint 2 Total:** **16 Story Points**

---

### 🔄 **Sprint 1 Deferred Items (Optional Stretch Goals)**

If Sprint 2 completes ahead of schedule, pull in these high-priority items:

| Item ID | Item Title | Story Points | Priority | Status |
|---------|------------|--------------|----------|--------|
| **D1** | UserPreferences Table (for Epic 2 Settings) | **1 SP** | HIGH | 📋 Stretch Goal |
| **D2** | Persistent File Storage (Drift: in-memory → file) | **0.5 SP** | MEDIUM | 📋 Stretch Goal |
| **D3** | Exercise Library Expansion (100 → 500 exercises) | **2 SP** | LOW-MEDIUM | 📋 Stretch Goal |

**Deferred Items Total:** **3.5 SP** (only if main stories complete early)

---

## Story Details & Estimates

---

### Story 1.4: State Management with Riverpod Architecture

**Story Points:** **5 SP**

**Estimation Rationale:**
- **Complexity:** MEDIUM-HIGH - Riverpod patterns, code generation, provider structure
- **Uncertainty:** LOW-MEDIUM - Well-documented, but requires careful architecture
- **Effort:** ~2 days (Riverpod setup + providers + code generation + examples)

**Tasks (Implementation Breakdown):**

1. ✅ Add Riverpod dependencies to `pubspec.yaml`
   ```yaml
   dependencies:
     flutter_riverpod: ^2.4.9
     riverpod_annotation: ^2.3.3

   dev_dependencies:
     riverpod_generator: ^2.3.9
     build_runner: ^2.4.7
   ```

2. ✅ Wrap `MaterialApp` with `ProviderScope` in `main.dart`
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

     runApp(
       ProviderScope(
         child: MyApp(),
       ),
     );
   }
   ```

3. ✅ Create core global providers in `/lib/core/providers/`
   - `database_provider.dart` - Provides AppDatabase instance
   - `firebase_auth_provider.dart` - Provides FirebaseAuth stream
   - `firestore_provider.dart` - Provides Firestore instance

4. ✅ Implement example providers with code generation
   ```dart
   // lib/core/providers/database_provider.dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:gymapp/core/database/app_database.dart';

   part 'database_provider.g.dart';

   @riverpod
   AppDatabase appDatabase(AppDatabaseRef ref) {
     return AppDatabase();
   }
   ```

5. ✅ Create repository providers (data access layer)
   ```dart
   // lib/features/workout/providers/workout_repository_provider.dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:gymapp/features/workout/repositories/workout_repository.dart';
   import 'package:gymapp/core/providers/database_provider.dart';

   part 'workout_repository_provider.g.dart';

   @riverpod
   WorkoutRepository workoutRepository(WorkoutRepositoryRef ref) {
     final database = ref.watch(appDatabaseProvider);
     return WorkoutRepository(database: database);
   }
   ```

6. ✅ Implement StateNotifier pattern for mutable state
   ```dart
   // lib/features/workout/providers/active_workout_provider.dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:gymapp/features/workout/models/workout_session.dart';

   part 'active_workout_provider.g.dart';

   @riverpod
   class ActiveWorkout extends _$ActiveWorkout {
     @override
     WorkoutSession? build() {
       return null; // Initial state: no active workout
     }

     Future<void> startWorkout() async {
       final repo = ref.read(workoutRepositoryProvider);
       final session = await repo.createWorkoutSession();
       state = session;
     }

     void finishWorkout() {
       state = null;
     }
   }
   ```

7. ✅ Implement FutureProvider for async data
   ```dart
   // lib/features/workout/providers/workout_history_provider.dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';

   part 'workout_history_provider.g.dart';

   @riverpod
   Future<List<WorkoutSession>> workoutHistory(WorkoutHistoryRef ref) async {
     final repo = ref.watch(workoutRepositoryProvider);
     return repo.getRecentWorkouts(limit: 20);
   }
   ```

8. ✅ Implement StreamProvider for real-time Firestore data
   ```dart
   // lib/core/providers/auth_state_provider.dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:firebase_auth/firebase_auth.dart';

   part 'auth_state_provider.g.dart';

   @riverpod
   Stream<User?> authState(AuthStateRef ref) {
     return FirebaseAuth.instance.authStateChanges();
   }
   ```

9. ✅ Setup ProviderObserver for debugging
   ```dart
   // lib/core/providers/provider_observer.dart
   class AppProviderObserver extends ProviderObserver {
     @override
     void didUpdateProvider(
       ProviderBase provider,
       Object? previousValue,
       Object? newValue,
       ProviderContainer container,
     ) {
       debugPrint('[PROVIDER] ${provider.name ?? provider.runtimeType}: $newValue');
     }
   }

   // main.dart
   runApp(
     ProviderScope(
       observers: [AppProviderObserver()],
       child: MyApp(),
     ),
   );
   ```

10. ✅ Run code generation
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

11. ✅ Create example ConsumerWidget
    ```dart
    // lib/features/workout/screens/workout_history_screen.dart
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:gymapp/features/workout/providers/workout_history_provider.dart';

    class WorkoutHistoryScreen extends ConsumerWidget {
      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final workoutHistoryAsync = ref.watch(workoutHistoryProvider);

        return Scaffold(
          appBar: AppBar(title: Text('Workout History')),
          body: workoutHistoryAsync.when(
            data: (workouts) => ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) => ListTile(
                title: Text('Workout ${workouts[index].id}'),
                subtitle: Text(workouts[index].startTime.toString()),
              ),
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        );
      }
    }
    ```

**Acceptance Criteria:**
- [ ] `flutter_riverpod` package integrated with `ProviderScope` in `main.dart`
- [ ] Code generation working (`riverpod_generator` configured)
- [ ] 3 global providers created (database, auth, firestore)
- [ ] 3 provider patterns demonstrated:
  - [ ] StateNotifier for mutable state (ActiveWorkoutProvider)
  - [ ] FutureProvider for async data (WorkoutHistoryProvider)
  - [ ] StreamProvider for real-time data (AuthStateProvider)
- [ ] ProviderObserver configured for debugging
- [ ] Example ConsumerWidget implemented (WorkoutHistoryScreen)
- [ ] Code builds successfully after `build_runner`
- [ ] Provider naming convention documented

**Definition of Done:**
- [ ] All acceptance criteria met (100%)
- [ ] Code compiles without errors
- [ ] Example screens demonstrate all 3 provider patterns
- [ ] Riverpod architecture documented in `docs/riverpod-patterns.md`
- [ ] Code committed and pushed

**Prerequisites:** Sprint 1 complete (Stories 1.1-1.3)

---

### Story 1.5: Navigation and Routing Infrastructure

**Story Points:** **3 SP**

**Estimation Rationale:**
- **Complexity:** MEDIUM - go_router setup, route definitions, auth guards
- **Uncertainty:** LOW - Well-documented package
- **Effort:** ~1 day (Router config + route definitions + navigation bar)

**Tasks (Implementation Breakdown):**

1. ✅ Add go_router dependency
   ```yaml
   dependencies:
     go_router: ^13.0.0
   ```

2. ✅ Create router configuration in `/lib/core/router/app_router.dart`
   ```dart
   import 'package:go_router/go_router.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:gymapp/core/providers/auth_state_provider.dart';

   final goRouterProvider = Provider<GoRouter>((ref) {
     final authState = ref.watch(authStateProvider);

     return GoRouter(
       initialLocation: '/',
       redirect: (context, state) {
         final isLoggedIn = authState.value != null;
         final isGoingToLogin = state.location == '/login';

         // Redirect to login if not authenticated
         if (!isLoggedIn && !isGoingToLogin) {
           return '/login';
         }

         // Redirect to home if logged in and trying to access login
         if (isLoggedIn && isGoingToLogin) {
           return '/';
         }

         return null; // No redirect
       },
       routes: [
         // Public routes
         GoRoute(
           path: '/login',
           builder: (context, state) => LoginScreen(),
         ),
         GoRoute(
           path: '/signup',
           builder: (context, state) => SignupScreen(),
         ),
         GoRoute(
           path: '/onboarding',
           builder: (context, state) => OnboardingScreen(),
         ),

         // Authenticated routes with shell (bottom nav)
         ShellRoute(
           builder: (context, state, child) => ScaffoldWithNavBar(child: child),
           routes: [
             GoRoute(
               path: '/',
               builder: (context, state) => HomeScreen(),
             ),
             GoRoute(
               path: '/workout',
               builder: (context, state) => ActiveWorkoutScreen(),
               routes: [
                 GoRoute(
                   path: 'history',
                   builder: (context, state) => WorkoutHistoryScreen(),
                 ),
                 GoRoute(
                   path: ':id',
                   builder: (context, state) {
                     final id = int.parse(state.params['id']!);
                     return WorkoutDetailScreen(workoutId: id);
                   },
                 ),
               ],
             ),
             GoRoute(
               path: '/progress',
               builder: (context, state) => ProgressScreen(),
             ),
             GoRoute(
               path: '/profile',
               builder: (context, state) => ProfileScreen(),
             ),
             GoRoute(
               path: '/exercises',
               builder: (context, state) => ExerciseLibraryScreen(),
             ),
           ],
         ),
       ],
     );
   });
   ```

3. ✅ Update `main.dart` to use go_router
   ```dart
   class MyApp extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final router = ref.watch(goRouterProvider);

       return MaterialApp.router(
         title: 'GymApp',
         routerConfig: router,
         debugShowCheckedModeBanner: false,
       );
     }
   }
   ```

4. ✅ Create bottom navigation bar shell
   ```dart
   // lib/shared/widgets/scaffold_with_nav_bar.dart
   class ScaffoldWithNavBar extends StatelessWidget {
     final Widget child;

     ScaffoldWithNavBar({required this.child});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         body: child,
         bottomNavigationBar: BottomNavigationBar(
           currentIndex: _calculateSelectedIndex(context),
           onTap: (index) => _onItemTapped(index, context),
           type: BottomNavigationBarType.fixed,
           items: [
             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
             BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
             BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
           ],
         ),
       );
     }

     int _calculateSelectedIndex(BuildContext context) {
       final location = GoRouter.of(context).location;
       if (location.startsWith('/workout')) return 1;
       if (location.startsWith('/progress')) return 2;
       if (location.startsWith('/profile')) return 3;
       return 0; // Home
     }

     void _onItemTapped(int index, BuildContext context) {
       switch (index) {
         case 0:
           context.go('/');
           break;
         case 1:
           context.go('/workout');
           break;
         case 2:
           context.go('/progress');
           break;
         case 3:
           context.go('/profile');
           break;
       }
     }
   }
   ```

5. ✅ Create placeholder screens for all routes
   - `lib/features/auth/screens/login_screen.dart`
   - `lib/features/auth/screens/signup_screen.dart`
   - `lib/features/auth/screens/onboarding_screen.dart`
   - `lib/features/home/screens/home_screen.dart`
   - `lib/features/workout/screens/active_workout_screen.dart`
   - `lib/features/workout/screens/workout_history_screen.dart`
   - `lib/features/workout/screens/workout_detail_screen.dart`
   - `lib/features/progress/screens/progress_screen.dart`
   - `lib/features/profile/screens/profile_screen.dart`
   - `lib/features/exercise/screens/exercise_library_screen.dart`

6. ✅ Test navigation flows
   - Navigate between bottom nav tabs
   - Test auth guard (redirect to login when not authenticated)
   - Test deep links (workout/:id)
   - Test back button behavior

**Acceptance Criteria:**
- [ ] go_router package integrated
- [ ] 10+ routes defined (login, signup, onboarding, home, workout, progress, profile, exercises, etc.)
- [ ] Auth guard redirects to /login if not authenticated
- [ ] Bottom navigation bar with 4 tabs (Home, Workout, Progress, Profile)
- [ ] Deep linking works (can navigate to /workout/:id)
- [ ] All placeholder screens created (minimal UI)
- [ ] Navigation between screens works on iOS and Android
- [ ] Back button behavior respects platform conventions

**Definition of Done:**
- [ ] All routes functional
- [ ] Auth guard tested (manually or with tests)
- [ ] Navigation documented in `docs/navigation-structure.md`
- [ ] Code committed and pushed

**Prerequisites:** Story 1.4 (Riverpod for auth state integration)

---

### Story 1.6: Design System and Theming

**Story Points:** **8 SP**

**Estimation Rationale:**
- **Complexity:** HIGH - Custom components, theming, accessibility, responsive design
- **Uncertainty:** MEDIUM - Design decisions require iteration
- **Effort:** ~3-4 days (Theme setup + 6 custom components + accessibility + testing)

**Tasks (Implementation Breakdown):**

1. ✅ Create theme configuration in `/lib/core/theme/app_theme.dart`
   ```dart
   import 'package:flutter/material.dart';

   class AppTheme {
     // Color palette
     static const Color primaryColor = Color(0xFFFF6B35); // Nike orange-inspired
     static const Color successColor = Color(0xFF4CAF50);
     static const Color warningColor = Color(0xFFFFC107);
     static const Color errorColor = Color(0xFFF44336);

     // Light theme
     static ThemeData lightTheme = ThemeData(
       useMaterial3: true,
       colorScheme: ColorScheme.fromSeed(
         seedColor: primaryColor,
         brightness: Brightness.light,
       ),
       appBarTheme: AppBarTheme(
         backgroundColor: primaryColor,
         foregroundColor: Colors.white,
       ),
     );

     // Dark theme
     static ThemeData darkTheme = ThemeData(
       useMaterial3: true,
       colorScheme: ColorScheme.fromSeed(
         seedColor: primaryColor,
         brightness: Brightness.dark,
       ),
       appBarTheme: AppBarTheme(
         backgroundColor: primaryColor,
         foregroundColor: Colors.white,
       ),
     );
   }
   ```

2. ✅ Apply theme in `main.dart`
   ```dart
   MaterialApp.router(
     theme: AppTheme.lightTheme,
     darkTheme: AppTheme.darkTheme,
     themeMode: ThemeMode.system, // Follow system settings
     routerConfig: router,
   );
   ```

3. ✅ Create custom `AppButton` component
   ```dart
   // lib/shared/widgets/app_button.dart
   class AppButton extends StatelessWidget {
     final String label;
     final VoidCallback onPressed;
     final AppButtonType type;
     final bool isLoading;

     AppButton({
       required this.label,
       required this.onPressed,
       this.type = AppButtonType.primary,
       this.isLoading = false,
     });

     @override
     Widget build(BuildContext context) {
       return SizedBox(
         height: 48, // Minimum 44dp touch target
         child: ElevatedButton(
           onPressed: isLoading ? null : onPressed,
           style: _buttonStyle(context, type),
           child: isLoading
               ? SizedBox(
                   height: 20,
                   width: 20,
                   child: CircularProgressIndicator(strokeWidth: 2),
                 )
               : Text(label),
         ),
       );
     }

     ButtonStyle _buttonStyle(BuildContext context, AppButtonType type) {
       switch (type) {
         case AppButtonType.primary:
           return ElevatedButton.styleFrom(
             backgroundColor: Theme.of(context).colorScheme.primary,
             foregroundColor: Colors.white,
           );
         case AppButtonType.secondary:
           return ElevatedButton.styleFrom(
             backgroundColor: Colors.transparent,
             foregroundColor: Theme.of(context).colorScheme.primary,
             side: BorderSide(color: Theme.of(context).colorScheme.primary),
           );
         case AppButtonType.text:
           return TextButton.styleFrom();
       }
     }
   }

   enum AppButtonType { primary, secondary, text }
   ```

4. ✅ Create custom `AppTextField` component
   ```dart
   // lib/shared/widgets/app_text_field.dart
   class AppTextField extends StatelessWidget {
     final String label;
     final String? hintText;
     final TextEditingController? controller;
     final String? Function(String?)? validator;
     final bool obscureText;
     final TextInputType keyboardType;

     AppTextField({
       required this.label,
       this.hintText,
       this.controller,
       this.validator,
       this.obscureText = false,
       this.keyboardType = TextInputType.text,
     });

     @override
     Widget build(BuildContext context) {
       return TextFormField(
         controller: controller,
         obscureText: obscureText,
         keyboardType: keyboardType,
         validator: validator,
         decoration: InputDecoration(
           labelText: label,
           hintText: hintText,
           border: OutlineInputBorder(),
           filled: true,
           fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
         ),
       );
     }
   }
   ```

5. ✅ Create custom `AppCard` component
   ```dart
   // lib/shared/widgets/app_card.dart
   class AppCard extends StatelessWidget {
     final Widget child;
     final VoidCallback? onTap;
     final EdgeInsets? padding;

     AppCard({
       required this.child,
       this.onTap,
       this.padding,
     });

     @override
     Widget build(BuildContext context) {
       return Card(
         elevation: 2,
         clipBehavior: Clip.antiAlias,
         child: InkWell(
           onTap: onTap,
           child: Padding(
             padding: padding ?? EdgeInsets.all(16),
             child: child,
           ),
         ),
       );
     }
   }
   ```

6. ✅ Create custom `LoadingIndicator` component
   ```dart
   // lib/shared/widgets/loading_indicator.dart
   class LoadingIndicator extends StatelessWidget {
     final String? message;

     LoadingIndicator({this.message});

     @override
     Widget build(BuildContext context) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             CircularProgressIndicator(),
             if (message != null) ...[
               SizedBox(height: 16),
               Text(message!, style: Theme.of(context).textTheme.bodyMedium),
             ],
           ],
         ),
       );
     }
   }
   ```

7. ✅ Create custom `EmptyState` component
   ```dart
   // lib/shared/widgets/empty_state.dart
   class EmptyState extends StatelessWidget {
     final IconData icon;
     final String title;
     final String message;
     final Widget? action;

     EmptyState({
       required this.icon,
       required this.title,
       required this.message,
       this.action,
     });

     @override
     Widget build(BuildContext context) {
       return Center(
         child: Padding(
           padding: EdgeInsets.all(32),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(icon, size: 64, color: Colors.grey),
               SizedBox(height: 16),
               Text(
                 title,
                 style: Theme.of(context).textTheme.headlineSmall,
                 textAlign: TextAlign.center,
               ),
               SizedBox(height: 8),
               Text(
                 message,
                 style: Theme.of(context).textTheme.bodyMedium,
                 textAlign: TextAlign.center,
               ),
               if (action != null) ...[
                 SizedBox(height: 24),
                 action!,
               ],
             ],
           ),
         ),
       );
     }
   }
   ```

8. ✅ Create custom `AppBottomSheet` helper
   ```dart
   // lib/shared/widgets/app_bottom_sheet.dart
   class AppBottomSheet {
     static Future<T?> show<T>(
       BuildContext context, {
       required Widget child,
       String? title,
     }) {
       return showModalBottomSheet<T>(
         context: context,
         isScrollControlled: true,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
         ),
         builder: (context) => Padding(
           padding: EdgeInsets.only(
             bottom: MediaQuery.of(context).viewInsets.bottom,
           ),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               if (title != null) ...[
                 Padding(
                   padding: EdgeInsets.all(16),
                   child: Text(
                     title,
                     style: Theme.of(context).textTheme.titleLarge,
                   ),
                 ),
                 Divider(),
               ],
               child,
             ],
           ),
         ),
       );
     }
   }
   ```

9. ✅ Add semantic labels for accessibility
   ```dart
   // Example: AppButton with semantic label
   Semantics(
     label: 'Start workout button',
     button: true,
     child: AppButton(label: 'Start Workout', onPressed: () {}),
   );
   ```

10. ✅ Test accessibility
    - Run Accessibility Scanner (Android)
    - Test with VoiceOver (iOS) / TalkBack (Android)
    - Verify color contrast ratios (≥4.5:1)
    - Verify touch targets (≥44x44dp)

11. ✅ Create design system documentation
    - Create `docs/design-system.md`
    - Document color palette, typography, spacing, components
    - Include usage examples for each component

**Acceptance Criteria:**
- [ ] Light and Dark themes implemented
- [ ] 6 custom components created:
  - [ ] AppButton (primary, secondary, text variants)
  - [ ] AppTextField (with validation support)
  - [ ] AppCard (with onTap support)
  - [ ] LoadingIndicator (with optional message)
  - [ ] EmptyState (with icon, title, message, action)
  - [ ] AppBottomSheet (helper function)
- [ ] WCAG AA color contrast ratios verified (≥4.5:1)
- [ ] All interactive elements have semantic labels
- [ ] Touch targets ≥44x44dp
- [ ] Design system documented in `docs/design-system.md`
- [ ] Components tested on iOS and Android
- [ ] Dark mode works correctly

**Definition of Done:**
- [ ] All components functional and accessible
- [ ] Accessibility tests passed (manual testing with screen reader)
- [ ] Design system documented
- [ ] Code committed and pushed

**Prerequisites:** Story 1.1 (project initialized)

---

## Sprint 1 Deferred Items (Stretch Goals)

Only pull in these if Sprint 2 main stories complete early!

---

### D1: UserPreferences Table

**Story Points:** **1 SP**

**Purpose:** Store user settings (needed for Epic 2: Settings)

**Tasks:**
1. ✅ Add UserPreferences table to Drift schema
2. ✅ Update AppDatabase to v2 (migration from v1)
3. ✅ Create UserPreferencesDao
4. ✅ Write unit tests
5. ✅ Update `docs/database-migrations.md` with v1 → v2 migration

**Time Estimate:** ~4 hours

---

### D2: Persistent File Storage

**Story Points:** **0.5 SP**

**Purpose:** Switch Drift from in-memory to persistent file (needed for Epic 4: Workout Logging)

**Tasks:**
1. ✅ Change `AppDatabase._openConnection()` from `NativeDatabase.memory()` to `NativeDatabase.createQueryExecutor('gymapp.db')`
2. ✅ Test database persists across app restarts
3. ✅ Update documentation

**Time Estimate:** ~2 hours

---

### D3: Exercise Library Expansion

**Story Points:** **2 SP**

**Purpose:** Expand from 100 to 500 exercises

**Tasks:**
1. ✅ Research/find open-source exercise database
2. ✅ Convert to GymApp JSON format
3. ✅ Create `assets/data/exercises_full.json` (500+ exercises)
4. ✅ Update seeding logic to load full library
5. ✅ Test exercise search with 500+ exercises

**Time Estimate:** ~8 hours

---

## Sprint 2 Ceremonies

### Daily Standup (Solo Developer Adaptation)
**Frequency:** Every morning (5 minutes)
**Format:** Written log

**Example:**
```
2025-01-30 Standup:
- ✅ Completed: Story 1.4 (Riverpod setup, 3 providers working)
- 🎯 Today: Story 1.5 (go_router setup, route definitions)
- ⚠️ Blockers: None
```

### Sprint Review (End of Sprint)
**Date:** Last day of Sprint 2
**Duration:** 1 hour

**Demo:**
1. Show Riverpod providers in action (auth state, workout history)
2. Navigate between screens (bottom nav, deep links)
3. Show Light/Dark theme switching
4. Demonstrate custom components (AppButton, AppCard, etc.)
5. Show accessibility (VoiceOver/TalkBack)

### Sprint Retrospective
**Date:** Same day as Sprint Review
**Duration:** 30 minutes

**Questions:**
1. What went well in Sprint 2?
2. What didn't go well?
3. What improvements for Sprint 3?
4. Velocity: Did we hit 16 SP target?

---

## Sprint Dependencies

| Story | Depends On | Blocks |
|-------|------------|--------|
| **1.4** | Sprint 1 (1.1-1.3) | 1.5 (auth guards), Epic 2 (Auth) |
| **1.5** | 1.4 (Riverpod for auth state) | Epic 2 (Auth screens need routes) |
| **1.6** | 1.1 (project initialized) | All future UI work |

**Critical Path:** 1.4 → 1.5 → Epic 2

---

## Sprint Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Riverpod code generation issues** | Medium | Medium | Allow extra time (2 hours), use `--delete-conflicting-outputs` flag |
| **Design system iteration** | High | Low | Start with basic components, refine in later sprints |
| **Accessibility compliance** | Medium | Medium | Test early with screen reader, use built-in Semantics widgets |
| **Story 1.6 too large** | Medium | High | If running late, defer EmptyState + AppBottomSheet to Sprint 3 |

---

## Definition of Done (Sprint 2)

A story is considered "Done" when:

### Code Quality
- [ ] Code compiles without errors or warnings
- [ ] Riverpod code generation runs successfully
- [ ] All custom components work on iOS and Android
- [ ] No hardcoded values (use theme values)

### Testing
- [ ] Manual testing on iOS and Android simulators
- [ ] Accessibility testing with screen reader
- [ ] Dark mode tested
- [ ] Navigation flows tested

### Documentation
- [ ] Riverpod patterns documented (`docs/riverpod-patterns.md`)
- [ ] Navigation structure documented (`docs/navigation-structure.md`)
- [ ] Design system documented (`docs/design-system.md`)
- [ ] Code comments for complex provider logic

### Integration
- [ ] Code committed to Git with meaningful messages
- [ ] Code pushed to GitHub
- [ ] CI/CD pipeline passes

---

## Sprint 2 Success Checklist

At the end of Sprint 2, verify:

**Epic 1 Foundation Complete:**
- [ ] Stories 1.1-1.6 completed (27 SP total across Sprint 1-2) ✅
- [ ] Remaining: Stories 1.7-1.8 for Sprint 3 (8 SP)

**Code Deliverables:**
- [ ] Riverpod integrated with 6+ providers ✅
- [ ] go_router with 10+ routes and bottom nav ✅
- [ ] Design system with Light/Dark themes ✅
- [ ] 6 custom components (AppButton, AppTextField, AppCard, etc.) ✅

**Documentation Deliverables:**
- [ ] `docs/riverpod-patterns.md` ✅
- [ ] `docs/navigation-structure.md` ✅
- [ ] `docs/design-system.md` ✅
- [ ] `docs/sprint-2-retrospective.md` ✅

**Stretch Goals (Optional):**
- [ ] UserPreferences table added (D1) 🎁
- [ ] Persistent file storage (D2) 🎁
- [ ] 500 exercises loaded (D3) 🎁

**If ALL main checkboxes checked:** **Sprint 2 COMPLETE!** 🎉

---

## Next Steps: Sprint 3 Preview

After Sprint 2, Sprint 3 will include:
- **Story 1.7:** Error Handling (3 SP)
- **Story 1.8:** Analytics (5 SP)
- **Epic 2:** Begin Authentication (Stories 2.1-2.3, ~8 SP)

**Or skip to Epic 4: Workout Logging** (if auth not needed yet)

**Total Sprint 3 Estimated:** ~16 SP

---

## Sprint Tracking

### Burndown Chart

| Day | Planned Remaining | Actual Remaining | Notes |
|-----|-------------------|------------------|-------|
| Day 1 (Mon) | 16 SP | 16 SP | Sprint starts |
| Day 2 (Tue) | 14 SP | — | |
| Day 3 (Wed) | 12 SP | — | |
| Day 4 (Thu) | 10 SP | — | |
| Day 5 (Fri) | 8 SP | — | End of Week 1 |
| Day 6 (Mon) | 6 SP | — | |
| Day 7 (Tue) | 4 SP | — | |
| Day 8 (Wed) | 2 SP | — | |
| Day 9 (Thu) | 1 SP | — | |
| Day 10 (Fri) | 0 SP | — | Sprint ends |

---

## Stakeholder Sign-Off

**Sprint Planning Approval:**

| Role | Name | Date | Approval |
|------|------|------|----------|
| **Product Owner** | Mariusz | [Pending] | ⬜ Approved |
| **Scrum Master** | Claude (BMAD SM Agent) | 2025-01-15 | ✅ Approved |
| **Development Team** | Mariusz | [Pending] | ⬜ Approved |

**Notes:**
- Sprint 2 scope is realistic (16 SP, same as Sprint 1 simplified)
- All 3 stories complete Epic 1 foundation (enabling Epic 2 & Epic 4)
- Deferred items available as stretch goals if ahead of schedule

---

**Sprint 2 Status:** 📋 **READY TO START** (after Sprint 1 completion)

**Document Version:** 1.0
**Last Updated:** 2025-01-15
**BMAD Phase:** Implementation - Sprint 2 Planning Complete

---

**END OF SPRINT 2 BACKLOG**
