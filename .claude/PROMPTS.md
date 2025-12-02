# PROMPTS - Szablony promptów dla AI

> Gotowe prompty do rozpoczęcia pracy. Skopiuj i dostosuj.

---

## 1. Nowy Feature (Pełny)

```
Stwórz nowy feature: {NAZWA_FEATURE}

Wymagania:
- {Requirement 1}
- {Requirement 2}
- {Requirement 3}

Przed rozpoczęciem:
1. Przeczytaj PATTERNS.md (.claude/PATTERNS.md)
2. Sprawdź TABLES.md czy potrzebna nowa tabela
3. Sprawdź FILE-MAP.md czy podobny feature istnieje

Struktura do utworzenia:
lib/features/{feature_name}/
├── data/
│   ├── datasources/{feature}_local_datasource.dart
│   ├── models/{feature}_model.dart
│   └── repositories/{feature}_repository_impl.dart
├── domain/
│   ├── entities/{feature}_entity.dart
│   ├── repositories/{feature}_repository.dart
│   └── usecases/
├── presentation/
│   ├── pages/{feature}_page.dart
│   ├── providers/{feature}_provider.dart
│   └── widgets/

Po zakończeniu:
1. Dodaj route w app_router.dart
2. Zaktualizuj FILE-MAP.md
3. Zaktualizuj docs/2-MANAGEMENT/project-status.md
```

---

## 2. Nowa Page (Screen)

```
Stwórz nową stronę: {NAZWA_PAGE}

Lokalizacja: lib/features/{feature}/presentation/pages/{page_name}_page.dart

Wzorce z PATTERNS.md:
- ConsumerWidget pattern
- state.when() dla AsyncValue
- AppBar z tytułem
- Error handling

Komponenty UI:
- {Lista komponentów}

Provider do użycia: {nazwa_provider}

Po zakończeniu zaktualizuj:
- FILE-MAP.md (sekcja Pages)
- app_router.dart (nowa route)
```

---

## 3. Nowy Provider (Riverpod)

```
Stwórz nowy provider: {NAZWA_PROVIDER}

Typ: [AsyncNotifier / FutureProvider / StateProvider]

Lokalizacja: lib/features/{feature}/presentation/providers/{provider_name}_provider.dart

Stan:
- {Field 1}: {Type}
- {Field 2}: {Type}

Metody:
- {method1}(): {description}
- {method2}(): {description}

Dependencies:
- {repository/service}

Użyj riverpod_annotation (@riverpod).
Po zakończeniu uruchom: dart run build_runner build
```

---

## 4. Nowa Tabela Drift

```
Dodaj nową tabelę Drift: {NAZWA_TABELI}

Lokalizacja: lib/core/database/tables/{batch}_tables.dart

Pola:
- id: TextColumn (PK)
- userId: TextColumn
- {field}: {Type} - {description}
- createdAt, updatedAt: DateTimeColumn
- isSynced, lastSyncedAt: sync metadata

Po utworzeniu:
1. Dodaj do database.dart (@DriftDatabase tables: [...])
2. Uruchom: dart run build_runner build
3. Zaktualizuj TABLES.md
```

---

## 5. Fix Bug

```
Napraw bug: {OPIS_BUGA}

Lokalizacja problemu: {ścieżka_pliku}:{linia}

Oczekiwane zachowanie:
- {description}

Aktualne zachowanie:
- {description}

Przed naprawą:
1. Przeczytaj kod w {plik}
2. Sprawdź powiązane providery
3. Sprawdź czy bug jest w CLAUDE.md (Known Issues)

Po naprawie:
1. Usuń z Known Issues w CLAUDE.md jeśli był tam
2. Zaktualizuj MVP-TODO.md jeśli dotyczy
```

---

## 6. Kontynuacja Pracy

```
Kontynuuj pracę nad projektem GymApp.

Przeczytaj najpierw:
1. docs/2-MANAGEMENT/project-status.md - aktualny stan
2. docs/2-MANAGEMENT/MVP-TODO.md - co zostało
3. CLAUDE.md - Known Issues

Następnie zaproponuj:
- Które zadania są priorytetowe
- Które można zrobić razem
- Estymowany effort (S/M/L)
```

---

## 7. Code Review

```
Zrób code review dla: {ŚCIEŻKA_PLIKU}

Sprawdź:
1. Zgodność z Clean Architecture (PATTERNS.md)
2. Poprawność typów i null-safety
3. Error handling
4. Naming conventions
5. Brakujące testy
6. Potencjalne memory leaks (dispose)
7. Hardcoded values (userId, API keys)

Format odpowiedzi:
- Krytyczne: [lista]
- Poprawki: [lista]
- Sugestie: [lista]
```

---

## 8. Aktualizacja Dokumentacji

```
Zaktualizuj dokumentację po ukończeniu: {OPIS_PRACY}

Pliki do sprawdzenia/aktualizacji:
1. docs/2-MANAGEMENT/project-status.md - % completion
2. docs/2-MANAGEMENT/epics/epic-{N}.md - status story
3. docs/2-MANAGEMENT/MVP-TODO.md - checkboxy
4. CLAUDE.md - Known Issues (jeśli naprawiono)
5. .claude/FILE-MAP.md - nowe pliki
6. .claude/TABLES.md - nowe tabele
```

---

## 9. Story Implementation

```
Zaimplementuj story: {STORY_ID} - {STORY_TITLE}

Szczegóły w: docs/2-MANAGEMENT/epics/epic-{N}.md

Acceptance Criteria:
- [ ] {AC1}
- [ ] {AC2}
- [ ] {AC3}

Podejście:
1. Przeczytaj pełny opis story w epic file
2. Sprawdź zależności (inne stories, tabele)
3. Użyj wzorców z PATTERNS.md
4. Implementuj krok po kroku

Po zakończeniu:
1. Oznacz story jako ✅ Done w epic file
2. Zaktualizuj project-status.md
```

---

## 10. Quick Start (Nowa Sesja)

```
Zaczynam nową sesję pracy nad GymApp.

Quick context:
- Flutter app, Clean Architecture + Riverpod
- Drift (SQLite) + Supabase
- MVP 1.0 ~45% complete

Moje cele na tę sesję:
1. {Cel 1}
2. {Cel 2}

Przeczytaj te pliki:
- .claude/FILE-MAP.md (jeśli szukam kodu)
- .claude/TABLES.md (jeśli dotyka DB)
- .claude/PATTERNS.md (jeśli tworzę nowy kod)
```

---

*Skopiuj prompt, wypełnij {PLACEHOLDERS}, wklej do AI.*
