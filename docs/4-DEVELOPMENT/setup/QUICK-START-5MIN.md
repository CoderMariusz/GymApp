# Quick Start - 5 Minutes Setup

<!-- AI-INDEX: quick-start, setup, development, environment, flutter, supabase -->

**Cel:** Uruchomienie projektu w 5 minut

---

## Prerequisites

- Flutter SDK 3.38+
- Dart 3.10+
- Git
- VS Code / Android Studio

---

## 1. Clone & Setup (2 min)

```bash
# Clone repo
git clone https://github.com/CoderMariusz/GymApp.git
cd GymApp

# Install dependencies
flutter pub get

# Generate code (Drift, Freezed, Riverpod)
dart run build_runner build --delete-conflicting-outputs
```

---

## 2. Configuration (1 min)

Stwórz plik `.env` w root:

```bash
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

Lub użyj istniejącej konfiguracji w `lib/core/config/`.

---

## 3. Run App (2 min)

```bash
# Sprawdź urządzenia
flutter devices

# Uruchom na emulatorze/symulatorze
flutter run

# Z hot reload
flutter run --hot
```

---

## Verification

Po uruchomieniu powinieneś zobaczyć:
- Ekran logowania/rejestracji
- Możliwość nawigacji po modułach

---

## Common Issues

| Problem | Rozwiązanie |
|---------|-------------|
| `build_runner` fails | `flutter clean && flutter pub get` |
| Supabase connection | Sprawdź `.env` credentials |
| iOS simulator | `flutter run -d ios` |
| Android emulator | `flutter run -d android` |

---

## Next Steps

1. **Zrozumienie architektury:** `docs/1-BASELINE/architecture/ARCH-overview.md`
2. **Standardy kodu:** `docs/4-DEVELOPMENT/standards/`
3. **Aktualne zadania:** `docs/2-MANAGEMENT/project-status.md`

---

## Project Structure

```
lib/
├── core/           # Shared utilities (auth, db, sync)
├── features/       # Feature modules
│   ├── life_coach/
│   ├── fitness/
│   ├── mind_emotion/
│   └── ...
└── generated/      # Generated code
```

---

## Useful Commands

```bash
# Run tests
flutter test

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Analyze code
flutter analyze

# Format code
dart format lib/
```

---

*Setup time: ~5 minutes | Full docs: docs/*
