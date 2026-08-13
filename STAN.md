# lifeOS — STAN 2026-08-13

**Jednym zdaniem:** modularny ekosystem life-coachingu z AI — Fitness Coach,
Life Coach, Mind & Emotion; killer feature to komunikacja między modułami.

- **Status:** 🟡 wznawiany po długiej przerwie
- **Katalog:** `~/Projects/lifeos` (15 MB) — **ściągnięty 13.08**, wcześniej nie było go na Macu
- **Remote:** `github.com/CoderMariusz/GymApp` — ⚠️ **PUBLICZNE**
- **Stack:** Flutter ≥3.38 / Dart ≥3.10 · Supabase · Drift (19 tabel) · offline-first
- **Prod:** brak

## Uwaga na nazewnictwo

Repo nazywa się `GymApp`, projekt w środku nazywa się **LifeOS** (`pubspec.yaml`:
`name: lifeos`). Katalog lokalny nazwałem `lifeos` — zgodnie z projektem, nie z repo.

## Gdzie jesteśmy

**Ostatnia realna praca: 2 grudnia 2025** — osiem miesięcy przerwy. `pushed_at` repo
pokazuje 12.08.2026, ale żadna z 20 gałęzi nie ma commita nowszego niż grudzień 2025,
więc tamten push nie ruszył HEAD-a.

Wg `EPIC_IMPLEMENTATION_STATUS.md` (23.11.2025) — **56 % ukończenia**, 37 z 66 stories,
287 plików Dart, 27 plików testów / 207 przypadków. Struktura dokumentacji: BMAD.

- **Epic 1 (fundament, 85 %)** — rejestracja, Google/Apple OAuth, reset hasła, profil,
  sync offline-first, eksport RODO, usuwanie konta z 7-dniową karencją. Brakuje MFA
  i zarządzania urządzeniami.
- **Luki krytyczne:** Mind & Emotion, gamifikacja, powiadomienia, onboarding.

⚠️ **Te liczby mają osiem miesięcy.** Przed planowaniem trzeba je odświeżyć na kodzie,
nie na raporcie.

## Bariera wejścia — do rozwiązania jako pierwsze

**Flutter i Dart nie są zainstalowane na tym Macu** (`flutter not found`, `dart not found`).
Bez nich nie da się ani zbudować, ani uruchomić, ani nawet zrobić `flutter analyze`.
Każda ocena stanu przed instalacją SDK jest oceną dokumentacji, nie kodu.


## Design system — dostarczony 13.08

Zainstalowany jako **skill**: `.claude/skills/lifeos-strength-design/` (160 plików, 14 MB).
Agent wywołuje go przez `/lifeos-strength-design`.

Zawiera tokeny, komponenty (core, feedback, fitness, navigation), ekrany (auth, catalog,
desktop, history, selector), ui_kits, guidelines, references i imagery.

**Uwaga na zakres:** system nazywa się *Strength* i opisuje LifeOS jako **dziennik treningu
siłowego, v1.0** — węziej niż zastany kod, który celuje w trzy moduły (Fitness, Life Coach,
Mind & Emotion). Przed wdrożeniem trzeba rozstrzygnąć, czy to zawężenie zakresu produktu,
czy design pokrywa na razie jeden moduł.

## Następny krok

1. Zainstalować Flutter SDK ≥3.38
2. `flutter analyze` + `flutter test` — **zobaczyć, ile z 207 testów faktycznie przechodzi**
   po ośmiu miesiącach i przy nowszym SDK
3. Dopiero potem: odświeżyć raport stanu na podstawie kodu
4. Wdrożyć design system — jest na miejscu (najpierw rozstrzygnąć zakres, patrz wyżej)

## Ryzyko

Repo jest **publiczne**. Sprawdzone 13.08: żadnych kluczy w kodzie, jest tylko
`.env.example`. Przy każdym commicie skanować ponownie.
