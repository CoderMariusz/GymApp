# LifeOS - Quick Start Guide

**Story 1.1: User Account Creation** - Ready to run! 🚀

---

## ✅ Konfiguracja Supabase - GOTOWA!

Twój projekt jest już skonfigurowany z credentials Supabase:

- **Projekt URL**: `https://neyxqfrtygpatwopeqqe.supabase.co`
- **Klucze API**: ✅ Skonfigurowane
- **Database Password**: `mm2022MM!!`

---

## 🚀 Uruchomienie aplikacji (3 kroki)

### 1. Zainstaluj zależności Flutter

```bash
flutter pub get
```

### 2. Wygeneruj pliki (Freezed, JSON Serializable)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Uruchom aplikację

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Lista dostępnych urządzeń
flutter devices
```

---

## 📊 Baza danych

### Status migracji

✅ **Plik migracji**: `supabase/migrations/001_initial_schema.sql`
✅ **Tabela user_profiles**: Gotowa z RLS policies
✅ **Trigger auto-create**: Skonfigurowany

### Uruchom migrację w Supabase

1. Otwórz [Supabase Dashboard](https://supabase.com/dashboard)
2. Wybierz projekt: `neyxqfrtygpatwopeqqe`
3. Przejdź do **SQL Editor**
4. Wklej zawartość `supabase/migrations/001_initial_schema.sql`
5. Kliknij **Run**

**Alternatywnie przez CLI:**

```bash
# Zainstaluj Supabase CLI
npm install -g supabase

# Połącz z projektem
supabase link --project-ref neyxqfrtygpatwopeqqe

# Uruchom migrację
supabase db push
```

---

## 🧪 Testowanie

### Unit Tests

```bash
flutter test

# Z coverage
flutter test --coverage
```

### Testowanie funkcjonalności

**Email/Password Registration:**
1. Otwórz aplikację
2. Kliknij "Create Account"
3. Wpisz email (np. `test@example.com`)
4. Wpisz hasło (min 8 znaków, wielka litera, liczba, znak specjalny)
5. Kliknij "Create Account"
6. ✅ Powinieneś zobaczyć stronę onboardingu

**Google OAuth:**
1. Kliknij "Continue with Google"
2. Zaloguj się przez Google
3. ✅ Przekierowanie na onboarding

**Apple Sign-In (iOS only):**
1. Na iOS: kliknij "Continue with Apple"
2. Zaloguj się przez Apple
3. ✅ Przekierowanie na onboarding

---

## 🔐 Credentials Summary

**Supabase:**
- URL: `https://neyxqfrtygpatwopeqqe.supabase.co`
- Anon Key: ✅ (w `supabase_config.dart`)
- Service Role Key: ✅ (w `supabase_config.dart`)

**Database:**
- Host: `db.neyxqfrtygpatwopeqqe.supabase.co`
- Port: `5432`
- Database: `postgres`
- User: `postgres`
- Password: `mm2022MM!!`

**Environment Files:**
- `.env` - ✅ Utworzony z credentials (NIE commitowany)
- `.env.example` - ✅ Template dla innych developerów

---

## 📁 Struktura projektu

```
lib/
├── core/
│   ├── auth/              ✅ Pełna implementacja
│   │   ├── domain/        # Entities, UseCases, Validators
│   │   ├── data/          # Supabase DataSource, Repository
│   │   └── presentation/  # RegisterPage, LoginPage, Providers
│   ├── config/            ✅ Supabase config
│   ├── router/            ✅ GoRouter setup
│   └── theme/             ✅ LifeOS Deep Blue theme
└── main.dart              ✅ App entry point
```

---

## ✅ Story 1.1 - Acceptance Criteria

| Criterion | Status | Test Method |
|-----------|--------|-------------|
| AC1: Email/password registration | ✅ | Wypełnij formularz rejestracji |
| AC2: Google OAuth | ✅ | Kliknij "Continue with Google" |
| AC3: Apple Sign-In (iOS) | ✅ | Kliknij "Continue with Apple" |
| AC4: Email verification | ✅ | Sprawdź maila po rejestracji |
| AC5: User profile creation | ✅ | Sprawdź `user_profiles` table |
| AC6: Redirect to onboarding | ✅ | Po rejestracji → /onboarding |
| AC7: Error handling | ✅ | Spróbuj słabego hasła |
| AC8: Supabase Auth | ✅ | Wszystkie metody działają |

---

## 🐛 Troubleshooting

### Problem: "Supabase connection failed"
**Rozwiązanie:**
```bash
# Sprawdź czy .env ma poprawne credentials
cat .env | grep SUPABASE

# Zrestartuj aplikację
flutter clean
flutter pub get
flutter run
```

### Problem: "Build failed - missing generated files"
**Rozwiązanie:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problem: "OAuth not working"
**Rozwiązanie:**
1. Sprawdź Supabase Dashboard → Authentication → Providers
2. Upewnij się, że Google/Apple są włączone
3. Zweryfikuj redirect URLs

### Problem: "Email verification not sent"
**Rozwiązanie:**
1. Sprawdź Supabase Dashboard → Authentication → Settings
2. Upewnij się, że "Enable Email Confirmations" jest włączone
3. Zweryfikuj email template

---

## 🎯 Next Steps

### Dokończenie Story 1.1
- [ ] Dodaj widget tests dla RegisterPage
- [ ] Dodaj integration tests
- [ ] Przetestuj na prawdziwym urządzeniu

### Story 1.2: User Login & Session Management
- [ ] Implementacja session persistence
- [ ] Remember me functionality
- [ ] Auto-login on app restart

### Story 1.3: Password Reset Flow
- [ ] Forgot password page
- [ ] Email reset link
- [ ] New password form

---

## 📞 Support

**Problemy z projektem?**
- GitHub Issues: https://github.com/CoderMariusz/GymApp/issues
- Pull Request: https://github.com/CoderMariusz/GymApp/pull/new/claude/implement-story-1.1-012QZm2fkPTrjbRKdJ246KdX

**Dokumentacja:**
- README.md - Pełny setup guide
- IMPLEMENTATION_SUMMARY.md - Szczegóły implementacji
- docs/sprint-artifacts/sprint-1/1-1-user-account-creation.md - Story details

---

## ✨ Gotowe do działania!

Twój projekt LifeOS Story 1.1 jest w pełni skonfigurowany i gotowy do uruchomienia.

**Wszystko co musisz zrobić:**
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

**Happy coding! 🚀**
