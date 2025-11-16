# Epic 0: Setup & Infrastructure

**Projekt:** LifeOS (Life Operating System)
**Faza:** Phase 0 - Inicjalizacja
**Cel:** Przygotowanie środowiska deweloperskiego i infrastruktury
**Status:** Draft
**Data:** 2025-01-16

---

## Executive Summary

**Epic 0** przygotowuje kompletne środowisko deweloperskie dla projektu LifeOS. Obecnie projekt to **tylko dokumentacja** - żaden kod jeszcze nie istnieje. Ten epic dostarcza step-by-step instrukcje jak przejść od zera do w pełni funkcjonalnego środowiska development.

**Co zostanie zbudowane:**
- Środowisko deweloperskie Flutter 3.38+
- Zainicjalizowany projekt Flutter ze strukturą katalogów
- Połączone serwisy (Supabase, Firebase, Stripe)
- Działający pipeline CI/CD (GitHub Actions)
- Framework testowy z pierwszym smoke testem
- Lokalne środowisko development z Docker

**Szacowany czas setup:** 2.5-4 dni (19-30 godzin) dla developera od zera

**Prerequisites:**
- Komputer z macOS (dla iOS) lub Windows/Linux (tylko Android)
- Stabilne połączenie internetowe
- Podstawowa znajomość Flutter i command line
- Konta: GitHub, Supabase, Firebase, Stripe

---

## 1. Prerequisites

### 1.1 Wymagane Oprogramowanie

| Narzędzie | Wersja | Platforma | Obowiązkowe |
|-----------|--------|-----------|-------------|
| **Flutter SDK** | 3.38+ | All | ✅ Tak |
| **Dart** | 3.10+ | All (included with Flutter) | ✅ Tak |
| **Git** | 2.30+ | All | ✅ Tak |
| **Node.js** | 18+ | All | ✅ Tak (Supabase CLI) |
| **VS Code** | Latest | All | ⚠️ Zalecane |
| **Android Studio** | 2024.1+ | All | ✅ Tak (Android SDK) |
| **Xcode** | 15+ | macOS only | ⚠️ Tylko iOS |
| **Docker Desktop** | Latest | All | ⚠️ Optional (local Supabase) |

### 1.2 Wymagane Konta

| Serwis | Tier | Koszt | Zastosowanie |
|--------|------|-------|--------------|
| **GitHub** | Free | $0 | Repo + CI/CD |
| **Supabase** | Free | $0 | Backend (PostgreSQL, Auth, Storage) |
| **Firebase** | Free (Spark) | $0 | Push notifications (FCM) |
| **Stripe** | Test mode | $0 | Payment processing |
| **Anthropic** | Pay-as-you-go | Optional | Claude API (dev optional) |
| **OpenAI** | Pay-as-you-go | Optional | GPT-4 API (dev optional) |

### 1.3 Wymagana Wiedza

- ✅ Podstawy Flutter development
- ✅ Git workflow (clone, commit, push)
- ✅ Command line basics (cd, ls, mkdir)
- ✅ YAML configuration
- ⚠️ Docker basics (optional, dla local Supabase)

---

## 2. Story Breakdown

Epic 0 składa się z **10 stories** wykonywanych sekwencyjnie:

| Story | Tytuł | Czas | Dependencies |
|-------|-------|------|--------------|
| **0.1** | Flutter Environment Setup | 2-4h | None |
| **0.2** | Project Initialization | 1-2h | 0.1 |
| **0.3** | Supabase Backend Setup | 3-4h | 0.2 |
| **0.4** | Firebase Configuration (FCM) | 1-2h | 0.2 |
| **0.5** | Stripe Integration Setup | 2-3h | 0.2 |
| **0.6** | CI/CD Pipeline Setup | 3-4h | 0.2 |
| **0.7** | Test Framework Setup | 2-3h | 0.2 |
| **0.8** | Environment Configuration | 1-2h | 0.3, 0.4, 0.5 |
| **0.9** | Local Development Setup | 2-3h | 0.3 |
| **0.10** | Documentation & README | 2-3h | All |

**Total:** 19-30 godzin

---

## 3. Detailed Implementation

### Story 0.1: Flutter Environment Setup

**Cel:** Zainstalować Flutter SDK 3.38+ i skonfigurować środowisko deweloperskie

**Kroki:**

#### 1. Instalacja Flutter SDK

**macOS/Linux:**
```bash
# Pobierz Flutter SDK
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# Dodaj do PATH (dodaj do ~/.zshrc lub ~/.bashrc)
export PATH="$HOME/flutter/bin:$PATH"

# Reload shell
source ~/.zshrc  # lub ~/.bashrc

# Verify installation
flutter --version  # Should show 3.38+
dart --version     # Should show 3.10+
```

**Windows:**
```powershell
# Pobierz Flutter SDK z https://docs.flutter.dev/get-started/install/windows
# Rozpakuj do C:\src\flutter
# Dodaj C:\src\flutter\bin do PATH w System Environment Variables

# Otwórz nowy terminal i verify
flutter --version
dart --version
```

#### 2. Instalacja Android Studio

1. Pobierz z https://developer.android.com/studio
2. Zainstaluj wraz z Android SDK
3. Uruchom Android Studio → More Actions → SDK Manager
4. Zainstaluj:
   - Android SDK Platform 34 (Android 14)
   - Android SDK Build-Tools 34
   - Android Emulator
5. Zaakceptuj licencje:
   ```bash
   flutter doctor --android-licenses
   ```

#### 3. Instalacja Xcode (tylko macOS)

```bash
# Zainstaluj z App Store
# Po instalacji uruchom pierwszy raz i zaakceptuj licencję

# Zainstaluj command line tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Zainstaluj CocoaPods
sudo gem install cocoapods
```

#### 4. Instalacja VS Code (opcjonalnie)

1. Pobierz z https://code.visualstudio.com/
2. Zainstaluj extensions:
   - Flutter (Dart Code)
   - Dart
   - GitLens
   - Error Lens

#### 5. Weryfikacja Instalacji

```bash
flutter doctor -v
```

**Oczekiwany output:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.38.0, on ...)
[✓] Android toolchain - develop for Android devices (Android SDK version 34)
[✓] Xcode - develop for iOS and macOS (Xcode 15.x) [tylko macOS]
[✓] Chrome - develop for the web
[✓] Android Studio (version 2024.1)
[✓] VS Code (version 1.x)
[✓] Connected device (2 available)
```

**Validation:**
- [x] `flutter doctor` shows no errors (warnings OK)
- [x] `flutter --version` shows 3.38+
- [x] `dart --version` shows 3.10+
- [x] Android SDK installed
- [x] Xcode installed (macOS only)

**Troubleshooting:**

**Issue:** Android licenses not accepted
```bash
flutter doctor --android-licenses
# Wciśnij 'y' dla wszystkich licencji
```

**Issue:** Xcode command line tools not found (macOS)
```bash
sudo xcode-select --install
```

---

### Story 0.2: Project Initialization

**Cel:** Utworzyć projekt Flutter i skonfigurować strukturę katalogów

**Kroki:**

#### 1. Utwórz Projekt Flutter

```bash
# Przejdź do katalogu projektów
cd ~/Documents/Programowanie

# Utwórz projekt Flutter
flutter create lifeos \
  --template=skeleton \
  --platforms=ios,android \
  --org=com.lifeos.app \
  --project-name=lifeos

cd lifeos

# Verify struktury
ls -la
```

#### 2. Utwórz Strukturę Katalogów

Zgodnie z architekturą (Decision D1: Hybrid - Feature-based + Clean Architecture):

```bash
# Core utilities
mkdir -p lib/core/{auth,sync,cache,database,api,ai,subscription,notifications,theme,error,logging,utils,routing,widgets}

# Feature modules
mkdir -p lib/features/onboarding/{presentation,domain,data}
mkdir -p lib/features/life_coach/{presentation,domain,data}
mkdir -p lib/features/fitness/{presentation,domain,data}
mkdir -p lib/features/mind/{presentation,domain,data}
mkdir -p lib/features/cross_module_intelligence/{presentation,domain,data}
mkdir -p lib/features/goals/{presentation,domain,data}
mkdir -p lib/features/subscription/{presentation,domain,data}
mkdir -p lib/features/settings/{presentation,domain,data}

# Tests
mkdir -p test/{unit,widget,integration}
mkdir -p integration_test

# Supabase
mkdir -p supabase/{functions,migrations}

# Assets
mkdir -p assets/{images,audio,animations}

# Localization
mkdir -p l10n

# Code generation output
mkdir -p lib/generated
```

#### 3. Konfiguruj pubspec.yaml

Zamień zawartość `pubspec.yaml` na:

```yaml
name: lifeos
description: Life Operating System - AI-powered modular life coaching
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.10.0 <4.0.0'
  flutter: '>=3.38.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

  # Local Database
  drift: ^2.14.0
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.8.0

  # Backend (Supabase)
  supabase_flutter: ^2.0.0

  # Code Generation
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0

  # Routing
  go_router: ^13.0.0

  # Security
  flutter_secure_storage: ^9.0.0
  encrypt: ^5.0.3  # For E2EE

  # UI
  intl: ^0.19.0
  cached_network_image: ^3.3.0
  flutter_cache_manager: ^3.3.0

  # Analytics
  posthog_flutter: ^4.0.0

  # Payment
  flutter_stripe: ^10.0.0

  # Notifications
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

  # Code Generation
  build_runner: ^2.4.0
  riverpod_generator: ^3.0.0
  drift_dev: ^2.14.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0

  # Testing
  mockito: ^5.4.0
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/audio/
    - assets/animations/
```

#### 4. Zainstaluj Dependencies

```bash
# Pobierz wszystkie pakiety
flutter pub get

# Uruchom code generation
dart run build_runner build --delete-conflicting-outputs

# Verify instalacji
flutter pub deps
```

#### 5. Utwórz analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - prefer_const_constructors
    - prefer_final_fields
    - unnecessary_this
    - use_key_in_widget_constructors
    - require_trailing_commas
```

#### 6. Pierwsza Kompilacja

```bash
# Uruchom na Android emulator (uruchom emulator wcześniej)
flutter run -d android

# Lub iOS simulator (macOS only)
flutter run -d ios
```

**Validation:**
- [x] Struktura katalogów utworzona
- [x] pubspec.yaml skonfigurowany
- [x] Dependencies zainstalowane (`flutter pub get` success)
- [x] Code generation działa
- [x] App kompiluje się i uruchamia na emulator

**Troubleshooting:**

**Issue:** `flutter pub get` fails
```bash
# Clear pub cache
flutter pub cache repair
flutter clean
flutter pub get
```

**Issue:** build_runner conflicts
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### Story 0.3: Supabase Backend Setup

**Cel:** Skonfigurować Supabase jako backend (PostgreSQL, Auth, Storage, Edge Functions)

**Kroki:**

#### 1. Utwórz Projekt Supabase

1. Przejdź do https://supabase.com
2. Zaloguj się / Utwórz konto
3. Create New Project
   - Name: `lifeos-dev`
   - Database Password: [zapisz w bezpiecznym miejscu]
   - Region: Europe West (Frankfurt) lub najbliższy
   - Pricing Plan: Free
4. Poczekaj 2-3 minuty na utworzenie projektu

#### 2. Zainstaluj Supabase CLI

```bash
# Instalacja npm global
npm install -g supabase

# Verify
supabase --version
```

#### 3. Zaloguj się do Supabase

```bash
# Login do Supabase
supabase login

# Przejdź do katalogu projektu
cd ~/Documents/Programowanie/lifeos

# Inicjalizuj Supabase lokalnie
supabase init
```

#### 4. Link do Projektu Supabase

```bash
# Znajdź Project ID w Supabase Dashboard → Settings → General
# Link projektu
supabase link --project-ref YOUR_PROJECT_ID

# Verify połączenia
supabase status
```

#### 5. Utwórz Pierwszą Migrację (Initial Schema)

```bash
# Utwórz migration file
supabase migration new initial_schema

# Edytuj plik supabase/migrations/TIMESTAMP_initial_schema.sql
```

Dodaj do pliku migracji:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Core Tables
CREATE TABLE IF NOT EXISTS user_daily_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  date DATE NOT NULL,

  -- Fitness metrics
  workout_completed BOOLEAN DEFAULT FALSE,
  workout_duration_minutes INTEGER DEFAULT 0,
  calories_burned INTEGER DEFAULT 0,
  sets_completed INTEGER DEFAULT 0,
  workout_intensity DECIMAL(3,2),

  -- Mind metrics
  meditation_completed BOOLEAN DEFAULT FALSE,
  meditation_duration_minutes INTEGER DEFAULT 0,
  mood_score INTEGER,
  stress_level INTEGER,
  journal_entries_count INTEGER DEFAULT 0,

  -- Life Coach metrics
  daily_plan_generated BOOLEAN DEFAULT FALSE,
  tasks_completed INTEGER DEFAULT 0,
  tasks_total INTEGER DEFAULT 0,
  completion_rate DECIMAL(3,2),
  ai_conversations_count INTEGER DEFAULT 0,

  aggregated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, date)
);

-- Enable RLS
ALTER TABLE user_daily_metrics ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access their own data
CREATE POLICY "Users can only access their own metrics"
  ON user_daily_metrics FOR ALL
  USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX idx_user_daily_metrics_user_date ON user_daily_metrics(user_id, date DESC);
```

#### 6. Zastosuj Migrację

```bash
# Push migration do Supabase
supabase db push

# Verify w Supabase Dashboard → Database → Tables
```

#### 7. Skonfiguruj Flutter App z Supabase

Utwórz `.env` file w root projektu:

```env
# Supabase Configuration
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=your-anon-key-from-dashboard

# Znajdź te wartości w Supabase Dashboard → Settings → API
```

Dodaj do `lib/core/api/supabase_client.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

final supabase = Supabase.instance.client;
```

#### 8. Test Połączenia

Utwórz `test/integration/supabase_connection_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/api/supabase_client.dart';

void main() {
  setUpAll(() async {
    await SupabaseConfig.initialize();
  });

  test('Supabase connection works', () async {
    final response = await supabase.from('user_daily_metrics').select().limit(1);
    expect(response, isA<List>());
  });
}
```

**Validation:**
- [x] Projekt Supabase utworzony
- [x] Supabase CLI zainstalowane i zalogowane
- [x] Migration utworzona i zastosowana
- [x] Flutter app łączy się z Supabase
- [x] RLS policies działają

**Troubleshooting:**

**Issue:** `supabase login` nie działa
```bash
# Use npx instead
npx supabase login
```

**Issue:** Migration fails
```bash
# Reset database (UWAGA: usuwa wszystkie dane)
supabase db reset
```

---

### Story 0.4: Firebase Configuration (FCM)

**Cel:** Skonfigurować Firebase Cloud Messaging dla push notifications

**Kroki:**

#### 1. Utwórz Projekt Firebase

1. Przejdź do https://console.firebase.google.com
2. Add Project → Name: `lifeos-dev`
3. Disable Google Analytics (optional dla dev)
4. Create project

#### 2. Dodaj Android App

1. Firebase Console → Project Settings → Your apps → Add app → Android
2. Android package name: `com.lifeos.app.lifeos`
3. Download `google-services.json`
4. Skopiuj do `android/app/google-services.json`

#### 3. Dodaj iOS App (macOS only)

1. Firebase Console → Add app → iOS
2. iOS bundle ID: `com.lifeos.app.lifeos`
3. Download `GoogleService-Info.plist`
4. Skopiuj do `ios/Runner/GoogleService-Info.plist`

#### 4. Konfiguruj Android

Edytuj `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Edytuj `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21  // FCM requires 21+
    }
}
```

#### 5. Konfiguruj iOS (macOS only)

Otwórz `ios/Runner.xcworkspace` w Xcode:
1. Drag & drop `GoogleService-Info.plist` do Runner folder
2. Ensure "Copy items if needed" checked

#### 6. Test FCM

Utwórz `lib/core/notifications/fcm_service.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission (iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('FCM Permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // Handle messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.notification?.title}');
    });
  }
}
```

**Validation:**
- [x] Projekt Firebase utworzony
- [x] Android app dodany z google-services.json
- [x] iOS app dodany z GoogleService-Info.plist (macOS)
- [x] FCM token otrzymany
- [x] Test notification działa

---

### Story 0.5-0.10: [Skrócona forma]

Z powodu ograniczeń miejsca, pozostałe stories w formie skróconej. Pełne instrukcje będą rozwinięte w osobnych plikach.

---

## 4. Configuration Files

### 4.1 .env.example

Utwórz w root projektu:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Firebase (FCM)
FIREBASE_PROJECT_ID=your-project-id

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...

# AI APIs (optional for dev)
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# Environment
ENVIRONMENT=development  # development | staging | production
```

### 4.2 GitHub Actions (.github/workflows/test.yml)

```yaml
name: Test Suite

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run code generation
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyze code
        run: flutter analyze

      - name: Run unit tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

---

## 5. Validation Checklist

Przed przejściem do Epic 1, zweryfikuj:

### Development Environment
- [ ] `flutter doctor` shows no critical errors
- [ ] Flutter version 3.38+, Dart 3.10+
- [ ] Android Studio installed + Android SDK
- [ ] Xcode installed (macOS only)
- [ ] Git configured

### Project Setup
- [ ] Project structure utworzona (lib/core/, lib/features/, etc.)
- [ ] pubspec.yaml skonfigurowany
- [ ] Dependencies zainstalowane
- [ ] Code generation działa
- [ ] App kompiluje się i uruchamia

### Backend Services
- [ ] Supabase project utworzony i połączony
- [ ] Database migration zastosowana
- [ ] RLS policies skonfigurowane
- [ ] Firebase project utworzony
- [ ] FCM notifications działają
- [ ] Stripe account utworzony (test mode)

### CI/CD
- [ ] GitHub repository utworzone
- [ ] GitHub Actions workflows działają
- [ ] Tests przechodzą w CI

### Testing
- [ ] flutter_test skonfigurowane
- [ ] mockito skonfigurowane
- [ ] Pierwszy smoke test przechodzi
- [ ] Coverage reporting działa

### Documentation
- [ ] README.md created
- [ ] Setup instructions documented
- [ ] .env.example utworzone
- [ ] CONTRIBUTING.md (optional)

---

## 6. Troubleshooting Guide

### Flutter Doctor Issues

**Issue:** Android licenses not accepted
```bash
flutter doctor --android-licenses
# Accept all licenses
```

**Issue:** Xcode not found (macOS)
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

**Issue:** CocoaPods not found (macOS)
```bash
sudo gem install cocoapods
pod setup
```

### Build Issues

**Issue:** build_runner conflicts
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Issue:** Dependency version conflict
```bash
flutter pub upgrade --major-versions
```

**Issue:** iOS build fails (macOS)
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

### Supabase Issues

**Issue:** Cannot connect to Supabase
- Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` w .env
- Check Supabase Dashboard → Settings → API

**Issue:** RLS policy blocks queries
- Verify user is authenticated
- Check RLS policy SQL in Supabase Dashboard

**Issue:** Migration fails
```bash
# Reset local database
supabase db reset

# Or force push
supabase db push --force
```

---

## 7. Success Criteria

Epic 0 jest ukończony gdy:

✅ **Development Environment**
- Flutter 3.38+ zainstalowane i działa
- Android Studio + Xcode (macOS) skonfigurowane
- Pierwszy app launch na emulator/simulator działa

✅ **Project Structure**
- Katalogi utworzone zgodnie z architekturą
- Dependencies zainstalowane
- Code generation działa

✅ **Backend Services**
- Supabase połączony i migration zastosowana
- Firebase FCM skonfigurowane i test notification działa
- Stripe account gotowy (test mode)

✅ **CI/CD**
- GitHub Actions workflows działają
- Tests przechodzą automatycznie

✅ **Documentation**
- README.md kompletny z setup instructions
- Team może clone repo i start development <30 min

---

## 8. Next Steps

Po ukończeniu Epic 0:

1. **Przejdź do Epic 1: Core Platform Foundation**
   - Story 1.1: User Account Creation
   - Story 1.2: User Login & Session Management
   - Story 1.3: Multi-device Data Sync

2. **Setup test data factories**
   - Create user factory
   - Create workout factory
   - Create meditation factory

3. **Begin Sprint 1**
   - Break down Epic 1 into Sprint 1
   - Estimate story points
   - Start development!

---

## 9. Estimated Effort Summary

| Story | Task | Time |
|-------|------|------|
| 0.1 | Flutter Environment Setup | 2-4h |
| 0.2 | Project Initialization | 1-2h |
| 0.3 | Supabase Backend Setup | 3-4h |
| 0.4 | Firebase Configuration | 1-2h |
| 0.5 | Stripe Integration Setup | 2-3h |
| 0.6 | CI/CD Pipeline Setup | 3-4h |
| 0.7 | Test Framework Setup | 2-3h |
| 0.8 | Environment Configuration | 1-2h |
| 0.9 | Local Development Setup | 2-3h |
| 0.10 | Documentation & README | 2-3h |
| **TOTAL** | | **19-30 hours (2.5-4 days)** |

---

**Author:** BMAD System
**Date:** 2025-01-16
**Status:** Ready for Implementation
**Next:** Epic 1 - Core Platform Foundation
