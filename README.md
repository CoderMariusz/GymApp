# LifeOS - Life Operating System

**Version:** 1.0.0
**Status:** Story 1.1 Implementation Complete
**Last Updated:** 2025-11-22

---

## Overview

LifeOS is an AI-powered modular life coaching application built with Flutter. This implementation covers **Story 1.1: User Account Creation** with email/password and social authentication (Google, Apple).

---

## Features Implemented (Story 1.1)

✅ **Email/Password Registration**
- Password validation (min 8 chars, 1 uppercase, 1 number, 1 special char)
- Real-time password strength indicator
- Email format validation
- Comprehensive error handling

✅ **Social Authentication**
- Google OAuth 2.0 (Android + iOS)
- Apple Sign-In (iOS only)
- Deep linking support for OAuth callbacks

✅ **User Profile Creation**
- Automatic profile creation in `user_profiles` table
- Default settings (name, email, avatar placeholder)
- Row Level Security (RLS) policies

✅ **Email Verification**
- Automatic verification email sent on registration
- Deep link support: `lifeos://verify?token={token}`
- Resend verification option

✅ **Error Handling**
- Email already exists → "Try logging in?" link
- Weak password → Highlighted requirements
- Invalid email → Inline error
- Network errors → Retry button

✅ **State Management**
- Riverpod StateNotifier pattern
- Clean Architecture (domain/data/presentation layers)
- Reactive UI with auth state changes

---

## Architecture

### Clean Architecture Layers

```
lib/
├── core/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/          # UserEntity
│   │   │   ├── repositories/      # AuthRepository interface
│   │   │   ├── usecases/          # RegisterUserUseCase
│   │   │   ├── validators/        # PasswordValidator, EmailValidator
│   │   │   └── exceptions/        # Auth exceptions
│   │   ├── data/
│   │   │   ├── models/            # UserModel (DTO)
│   │   │   ├── datasources/       # SupabaseAuthDataSource
│   │   │   └── repositories/      # AuthRepositoryImpl
│   │   └── presentation/
│   │       ├── pages/             # RegisterPage, LoginPage
│   │       ├── widgets/           # Reusable widgets
│   │       └── providers/         # Riverpod providers
│   ├── config/                    # Supabase configuration
│   ├── router/                    # GoRouter setup
│   ├── theme/                     # App theme (Deep Blue)
│   └── utils/                     # Result type, helpers
└── main.dart                      # App entry point
```

---

## Prerequisites

### Required Tools

1. **Flutter SDK**: 3.38+ (Dart 3.10+)
   ```bash
   flutter --version
   ```

2. **Supabase Account**
   - Create project at [supabase.com](https://supabase.com)
   - Get API URL and Anon Key

3. **Firebase Account** (for FCM - optional for Story 1.1)
   - Create project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android/iOS apps
   - Download `google-services.json` and `GoogleService-Info.plist`

4. **Google Cloud Console** (for OAuth)
   - Create OAuth 2.0 credentials
   - Configure redirect URIs

5. **Apple Developer Account** (for Apple Sign-In on iOS)
   - Enable Sign in with Apple capability

---

## Setup Instructions

### 1. Clone Repository

```bash
git clone https://github.com/CoderMariusz/GymApp.git
cd GymApp
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

Create `.env` file in project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Update `lib/core/config/supabase_config.dart` to load from environment:

```dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'YOUR_URL_HERE',  // Replace with actual URL
);

static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'YOUR_KEY_HERE',  // Replace with actual key
);
```

### 4. Run Database Migrations

The database schema is already in `supabase/migrations/001_initial_schema.sql`.

To apply migrations:

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to **SQL Editor**
3. Execute the migration SQL file
4. Verify `user_profiles` table exists with RLS policies

**Key Table Created:**
```sql
CREATE TABLE user_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  date_of_birth DATE,
  gender TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 5. Configure OAuth Providers in Supabase

#### Google OAuth:
1. Go to Supabase Dashboard → Authentication → Providers
2. Enable **Google** provider
3. Add Client ID and Client Secret from Google Cloud Console
4. Add redirect URL: `https://your-project.supabase.co/auth/v1/callback`

#### Apple Sign-In (iOS):
1. Enable **Apple** provider in Supabase
2. Configure Services ID from Apple Developer
3. Add redirect URL

### 6. Run Code Generation

Generate Freezed and JSON serialization code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 7. Run the App

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Specific device
flutter devices  # List devices
flutter run -d <device-id>
```

---

## Running Tests

### Unit Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Widget Tests

```bash
flutter test test/core/auth/presentation/
```

### Integration Tests

```bash
flutter test integration_test/
```

---

## Testing Checklist (Story 1.1 Acceptance Criteria)

- [ ] **AC1**: User can register with email + password (validation enforced)
- [ ] **AC2**: User can register with Google OAuth (Android + iOS)
- [ ] **AC3**: User can register with Apple Sign-In (iOS)
- [ ] **AC4**: Email verification sent after registration
- [ ] **AC5**: User profile created with default settings
- [ ] **AC6**: User redirected to onboarding flow after registration
- [ ] **AC7**: Error handling works for all cases
- [ ] **AC8**: Supabase Auth integration functional

---

## Known Limitations & TODOs

### Story 1.1 Complete:
✅ Email/password registration
✅ Google OAuth
✅ Apple Sign-In (iOS)
✅ Email verification flow
✅ User profile creation
✅ Error handling
✅ Unit tests for domain layer

### Pending (Future Stories):
- **Story 1.2**: User Login & Session Management
- **Story 1.3**: Password Reset Flow
- **Story 1.4**: User Profile Management
- **Story 1.5**: Data Sync Across Devices
- **Story 1.6**: GDPR Compliance (Data Export/Deletion)

### Additional Unit Tests Needed:
- Widget tests for RegisterPage
- Integration tests for full auth flow
- Repository implementation tests with mocked Supabase client

---

## Environment Variables

Required environment variables (create `.env` file):

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Firebase (optional for Story 1.1)
FIREBASE_PROJECT_ID=your-project-id
```

**Note**: Never commit `.env` to version control. Use `.env.example` as template.

---

## Troubleshooting

### Flutter Doctor Issues
```bash
flutter doctor --android-licenses
flutter upgrade
flutter clean && flutter pub get
```

### Supabase Connection Errors
- Verify `.env` has correct URL and key
- Check Supabase project is not paused
- Ensure network connection is stable

### OAuth Not Working
- Verify OAuth credentials in Supabase Dashboard
- Check redirect URIs are configured correctly
- For Google: Ensure SHA-1 fingerprint is added (Android)
- For Apple: Verify Services ID and capabilities

### Build Failures
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Code Quality

### Linting
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

---

## Deployment (Future)

### Build APK (Android)
```bash
flutter build apk --release
```

### Build IPA (iOS)
```bash
flutter build ios --release
```

---

## Contributing

1. Create feature branch: `git checkout -b feature/story-X.Y`
2. Implement changes following Clean Architecture
3. Write tests (80%+ coverage target)
4. Run tests and linting
5. Create pull request

---

## Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Riverpod Docs**: https://riverpod.dev
- **Supabase Docs**: https://supabase.com/docs
- **Project PRD**: `docs/ecosystem/prd.md`
- **Architecture**: `docs/ecosystem/architecture.md`
- **Story 1.1 Details**: `docs/sprint-artifacts/sprint-1/1-1-user-account-creation.md`

---

## License

Copyright © 2025 LifeOS. All rights reserved.

---

**Implementation Status**: Story 1.1 ✅ Complete
**Next Story**: 1.2 - User Login & Session Management
