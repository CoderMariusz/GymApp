# FILE-MAP - Index plików projektu

> Szybki dostęp do lokalizacji kodu. Zamiast Glob/Read - sprawdź tutaj.

---

## Pages (Screens)

| Page | Ścieżka | Opis |
|------|---------|------|
| **Auth** | | |
| LoginPage | `lib/core/auth/presentation/pages/login_page.dart` | Email/password + OAuth |
| RegisterPage | `lib/core/auth/presentation/pages/register_page.dart` | Rejestracja |
| ForgotPasswordPage | `lib/core/auth/presentation/pages/forgot_password_page.dart` | Reset hasła |
| ResetPasswordPage | `lib/core/auth/presentation/pages/reset_password_page.dart` | Nowe hasło |
| **Profile** | | |
| ProfileEditPage | `lib/core/profile/presentation/pages/profile_edit_page.dart` | Edycja profilu |
| **Fitness** | | |
| WorkoutLogPage | `lib/features/fitness/presentation/pages/workout_log_page.dart` | Lista treningów |
| WorkoutLoggingPage | `lib/features/fitness/presentation/pages/workout_logging_page.dart` | Logowanie treningu |
| QuickLogPage | `lib/features/fitness/presentation/pages/quick_log_page.dart` | Szybkie logowanie |
| TemplatesPage | `lib/features/fitness/presentation/pages/templates_page.dart` | Szablony treningów |
| MeasurementsPage | `lib/features/fitness/presentation/pages/measurements_page.dart` | Pomiary ciała |
| ProgressChartsPage | `lib/features/fitness/presentation/pages/progress_charts_page.dart` | Wykresy postępu |
| **Life Coach** | | |
| DailyPlanPage | `lib/features/life_coach/presentation/pages/daily_plan_page.dart` | Plan dnia |
| DailyPlanEditPage | `lib/features/life_coach/presentation/pages/daily_plan_edit_page.dart` | Edycja planu |
| MorningCheckInPage | `lib/features/life_coach/presentation/pages/morning_check_in_page.dart` | Poranny check-in |
| EveningReflectionPage | `lib/features/life_coach/presentation/pages/evening_reflection_page.dart` | Wieczorna refleksja |
| GoalsListPage | `lib/features/life_coach/presentation/pages/goals_list_page.dart` | Lista celów |
| CreateGoalPage | `lib/features/life_coach/presentation/pages/create_goal_page.dart` | Tworzenie celu |
| GoalSuggestionsPage | `lib/features/life_coach/goals/presentation/pages/goal_suggestions_page.dart` | Sugestie AI |
| CoachChatPage | `lib/features/life_coach/chat/presentation/pages/coach_chat_page.dart` | Chat z AI |
| ProgressDashboardPage | `lib/features/life_coach/presentation/pages/progress_dashboard_page.dart` | Dashboard postępu |
| **Mind** | | |
| MeditationLibraryScreen | `lib/features/mind_emotion/presentation/screens/meditation_library_screen.dart` | Biblioteka medytacji |
| **Exercise** | | |
| ExerciseDetailScreen | `lib/features/exercise/presentation/pages/exercise_detail_screen.dart` | Szczegóły ćwiczenia |
| CreateCustomExerciseScreen | `lib/features/exercise/presentation/pages/create_custom_exercise_screen.dart` | Tworzenie ćwiczenia |
| **Settings** | | |
| DataPrivacyPage | `lib/features/settings/presentation/pages/data_privacy_page.dart` | Prywatność danych |

---

## Providers (State Management)

| Provider | Ścieżka | Opis |
|----------|---------|------|
| **Auth** | | |
| authProvider | `lib/core/auth/presentation/providers/auth_provider.dart` | Stan auth |
| authNotifier | `lib/core/auth/presentation/providers/auth_notifier.dart` | Logika auth |
| **Profile** | | |
| profileProvider | `lib/core/profile/presentation/providers/profile_provider.dart` | Stan profilu |
| **AI** | | |
| aiProvider | `lib/core/ai/ai_provider.dart` | OpenAI service provider |
| **Fitness** | | |
| workoutProviders | `lib/features/fitness/presentation/providers/` | Folder z providerami |
| **Life Coach** | | |
| dailyPlanProvider | `lib/features/life_coach/ai/providers/daily_plan_provider.dart` | Plan dnia AI |
| checkInProviders | `lib/features/life_coach/presentation/providers/` | Check-in providers |
| goalProviders | `lib/features/life_coach/goals/presentation/providers/` | Goal providers |
| chatProviders | `lib/features/life_coach/chat/presentation/providers/` | Chat providers |
| **Mind** | | |
| meditationProviders | `lib/features/mind_emotion/presentation/providers/meditation_providers.dart` | Medytacje |
| **Sync** | | |
| connectivityProvider | `lib/core/sync/providers/connectivity_provider.dart` | Status połączenia |
| syncStatusProvider | `lib/core/sync/providers/sync_status_provider.dart` | Status synchronizacji |

---

## Repositories

| Repository | Interface | Implementation |
|------------|-----------|----------------|
| **Auth** | | |
| AuthRepository | `lib/core/auth/domain/repositories/auth_repository.dart` | `lib/core/auth/data/repositories/auth_repository_impl.dart` |
| SessionRepository | `lib/core/auth/domain/repositories/session_repository.dart` | `lib/core/auth/data/repositories/session_repository_impl.dart` |
| **Profile** | | |
| ProfileRepository | `lib/core/profile/domain/repositories/profile_repository.dart` | `lib/core/profile/data/repositories/profile_repository_impl.dart` |
| **Mind** | | |
| MeditationRepository | `lib/features/mind_emotion/domain/repositories/meditation_repository.dart` | `lib/features/mind_emotion/data/repositories/meditation_repository_impl.dart` |

---

## Use Cases

| UseCase | Ścieżka |
|---------|---------|
| **Auth** | `lib/core/auth/domain/usecases/` |
| LoginWithEmailUsecase | `login_with_email_usecase.dart` |
| RegisterUserUsecase | `register_user_usecase.dart` |
| LoginWithGoogleUsecase | `login_with_google_usecase.dart` |
| LoginWithAppleUsecase | `login_with_apple_usecase.dart` |
| RequestPasswordResetUsecase | `request_password_reset_usecase.dart` |
| UpdatePasswordUsecase | `update_password_usecase.dart` |
| LogoutUsecase | `logout_usecase.dart` |
| CheckAuthStatusUsecase | `check_auth_status_usecase.dart` |
| **Profile** | `lib/core/profile/domain/usecases/` |
| UpdateProfileUsecase | `update_profile_usecase.dart` |
| UploadAvatarUsecase | `upload_avatar_usecase.dart` |
| ChangePasswordUsecase | `change_password_usecase.dart` |
| **Mind** | `lib/features/mind_emotion/domain/usecases/` |
| GetMeditationsUsecase | `get_meditations_usecase.dart` |
| ToggleFavoriteUsecase | `toggle_favorite_usecase.dart` |
| DownloadMeditationUsecase | `download_meditation_usecase.dart` |

---

## Database

| Plik | Opis |
|------|------|
| `lib/core/database/database.dart` | Główna klasa AppDatabase |
| `lib/core/database/database_providers.dart` | Riverpod providers dla DB |
| `lib/core/database/tables.drift.dart` | Wygenerowany kod Drift |
| **Tables** | |
| `lib/core/database/tables/sprint0_tables.dart` | WorkoutTemplates, Subscriptions, Streaks, AiConversations, MoodLogs, UserDailyMetrics, MentalHealthScreenings |
| `lib/core/database/tables/batch1_tables.dart` | CheckIns, WorkoutLogs, ExerciseSets |
| `lib/core/database/tables/batch3_tables.dart` | Goals, GoalProgress, BodyMeasurements |
| `lib/core/database/tables/life_coach_tables.dart` | DailyPlans, ChatSessions |

---

## Core Services

| Service | Ścieżka | Opis |
|---------|---------|------|
| AIService | `lib/core/ai/ai_service.dart` | OpenAI integration |
| AIConfig | `lib/core/ai/ai_config.dart` | API key, model config |
| OpenAIProvider | `lib/core/ai/providers/openai_provider.dart` | HTTP calls to OpenAI |
| SyncService | `lib/core/sync/sync_service.dart` | Background sync logic |
| SyncQueue | `lib/core/sync/sync_queue.dart` | Offline queue |
| ConflictResolver | `lib/core/sync/conflict_resolver.dart` | Last-write-wins |
| AppRouter | `lib/core/router/app_router.dart` | GoRouter config |
| AppTheme | `lib/core/theme/app_theme.dart` | Material 3 theme |
| SupabaseConfig | `lib/core/config/supabase_config.dart` | Supabase credentials |

---

## Widgets (Reusable)

| Widget | Ścieżka |
|--------|---------|
| **Auth** | |
| EmailTextField | `lib/core/auth/presentation/widgets/email_text_field.dart` |
| PasswordTextField | `lib/core/auth/presentation/widgets/password_text_field.dart` |
| OAuthButton | `lib/core/auth/presentation/widgets/oauth_button.dart` |
| **Core** | |
| SubmitButtonWidget | `lib/core/widgets/submit_button_widget.dart` |
| TimePickerWidget | `lib/core/widgets/time_picker_widget.dart` |
| DailyInputForm | `lib/core/widgets/daily_input_form.dart` |
| **Sync** | |
| OfflineBanner | `lib/core/sync/widgets/offline_banner.dart` |
| SyncStatusIndicator | `lib/core/sync/widgets/sync_status_indicator.dart` |
| **Charts** | |
| BarChartWidget | `lib/core/charts/widgets/bar_chart_widget.dart` |
| LineChartWidget | `lib/core/charts/widgets/line_chart_widget.dart` |
| **Mind** | |
| MeditationCard | `lib/features/mind_emotion/presentation/widgets/meditation_card.dart` |
| CategoryTabs | `lib/features/mind_emotion/presentation/widgets/category_tabs.dart` |
| SearchBarWidget | `lib/features/mind_emotion/presentation/widgets/search_bar_widget.dart` |

---

*Ostatnia aktualizacja: 2025-12-02*
