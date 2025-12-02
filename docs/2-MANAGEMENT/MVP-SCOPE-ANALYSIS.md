# MVP 1.0 Scope Analysis - Szczegółowa Weryfikacja

<!-- AI-INDEX: mvp-scope, analysis, verification, stories, tasks, questions -->

**Data:** 2025-12-02
**Cel:** Weryfikacja logiki, tasków i założeń przed implementacją

---

## KOREKTA DO AUDYTU

Po głębszej analizie kodu, znalazłem że **poprzedni audit był częściowo błędny**:

| Element | Poprzedni Audit | Rzeczywistość |
|---------|-----------------|---------------|
| GoalsRepository | "Mock" | ✅ **REAL** - `GoalsRepositoryImpl` z Drift |
| CheckInRepository | "Mock" | ✅ **REAL** - `CheckInRepositoryImpl` z Drift |
| Coach Chat Page | "Nie istnieje" | ✅ **ISTNIEJE** - pełny UI z messagingiem |
| Meditation Player | "Nie istnieje" | ❌ **Potwierdzone** - NIE istnieje |

**PRAWDZIWY problem:** Konflikt providerów (szczegóły poniżej)

---

## KRYTYCZNY PROBLEM: Konflikt Providerów

### Opis problemu

Mamy **DWA pliki** definiujące te same providery z **RÓŻNYMI implementacjami**:

**Plik 1:** `lib/features/life_coach/presentation/providers/goals_provider.dart`
```dart
@riverpod
GoalsRepository goalsRepository(Ref ref) {
  return GoalsRepositoryImpl(database);  // ✅ REAL
}
```

**Plik 2:** `lib/features/life_coach/ai/providers/daily_plan_provider.dart`
```dart
@riverpod
GoalsRepository goalsRepository(Ref ref) {
  return MockGoalsRepository();  // ❌ MOCK
}
```

### Konsekwencje

| Screen | Używa | Implementacja |
|--------|-------|---------------|
| Goals List | `goals_provider.dart` | ✅ Real (Drift) |
| Create Goal | `goals_provider.dart` | ✅ Real (Drift) |
| Daily Plan Generator | `daily_plan_provider.dart` | ❌ Mock |
| Morning Check-in | `check_in_provider.dart` | ✅ Real (Drift) |

**Efekt:** Daily Plan AI generator NIE widzi prawdziwych celów użytkownika!

### Fix wymagany
```dart
// W daily_plan_provider.dart - zamień:
@riverpod
GoalsRepository goalsRepository(Ref ref) {
  return MockGoalsRepository();
}

// Na:
@riverpod
GoalsRepository dpGoalsRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return GoalsRepositoryImpl(database);
}
```

---

## ANALIZA PER EPIC DLA MVP 1.0

### EPIC 1: Core Platform

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 1.1 Account Creation | ✅ Done | ✅ **DONE** | Supabase Auth |
| 1.2 Login & Session | ✅ Done | ✅ **DONE** | Email + OAuth prepared |
| 1.3 Password Reset | ✅ Done | ⚠️ **PARTIAL** | Deep link nie testowany |
| 1.4 User Profile | ✅ Done | ✅ **DONE** | Profile editing |
| 1.5 Data Sync | ✅ Done | ⚠️ **PARTIAL** | Queue jest, logic nie |
| 1.6 GDPR | ✅ Done | ✅ **DONE** | Export/Delete |

**Rzeczywisty status:** 80% (lepiej niż poprzednio szacowałem)

**Taski MVP:**
- [ ] Test password reset deep link
- [ ] Ewentualnie: Sync logic (może być deferred)

---

### EPIC 2: Life Coach

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 2.1 Morning Check-in | ✅ Done | ✅ **DONE** | UI + Real repo |
| 2.2 AI Daily Plan | ✅ Done | ⚠️ **USES MOCK** | Generator działa, ale z mock goals |
| 2.3 Goal Creation | ✅ Done | ✅ **DONE** | Real repository |
| 2.4 AI Chat | ✅ Done | ✅ **DONE** | UI istnieje! |
| 2.5 Evening Reflection | ✅ Done | ✅ **DONE** | UI + Real repo |
| 2.6 Streak Tracking | ✅ Done | ⚠️ **LOGIC ONLY** | Brak UI, logika w repo |
| 2.7 Progress Dashboard | 🔄 | ⚠️ **BASIC** | Podstawowy UI |
| 2.8 Manual Adjustment | 🔄 | ✅ **DONE** | Drag & drop |

**Rzeczywisty status:** 75%

**Taski MVP:**
- [ ] **P0:** Fix provider conflict (zamień Mock→Real w daily_plan_provider)
- [ ] P1: Streak UI na Home screen
- [ ] P2: Progress dashboard improvements

---

### EPIC 3: Fitness

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 3.1 Smart Pattern Memory | ✅ Done | ✅ **DONE** | Provider + logic |
| 3.2 Exercise Library | ✅ Done | ⚠️ **UI ONLY** | Brak Drift persistence |
| 3.3 Workout Logging | ✅ Done | ✅ **DONE** | Full implementation |
| 3.4 History View | ✅ Done | ✅ **DONE** | List + detail |
| 3.5 Progress Charts | ✅ Done | ✅ **DONE** | fl_chart integrated |
| 3.6 Body Measurements | ✅ Done | ✅ **DONE** | Full CRUD |
| 3.7 Templates | 🔄 | ✅ **DONE** | Full CRUD |
| 3.8 Quick Log | 🔄 | ✅ **DONE** | Working |

**Rzeczywisty status:** 90% (najlepszy moduł!)

**Taski MVP:**
- [ ] P1: Exercise Library persistence (Drift tables)
- [ ] P2: Exercise instructions (może być deferred)

---

### EPIC 4: Mind & Emotion

| Story | Doc Status | Code Status | Uwagi |
|-------|------------|-------------|-------|
| 4.1 Meditation Library | 🔄 | ✅ **DONE** | UI complete |
| 4.2 Meditation Player | ✅ Done | ❌ **NOT DONE** | NIE ISTNIEJE |
| 4.3 Mood Tracking | ✅ Done | ⚠️ **IN CHECK-IN** | Jest w morning check-in |

**Rzeczywisty status:** 25%

**Taski MVP:**
- [ ] **P0:** Meditation Player screen
- [ ] P1: Standalone Mood tracking UI (opcjonalne - jest w check-in)
- [ ] P1: Breathing exercises

---

## PYTANIA DO CIEBIE

### 1. Mood Tracking Location

**Obecna sytuacja:** Mood i stress tracking jest **WBUDOWANY** w Morning Check-in:
```dart
// morning_check_in_page.dart
- Rate mood (1-5 emoji slider)
- Rate energy (1-5 emoji slider)
- Rate sleep quality (1-5 emoji slider)
```

**Pytanie:** Czy potrzebujemy DODATKOWEGO standalone mood tracking w Mind module?
- **Opcja A:** Wystarczy w check-in (szybciej)
- **Opcja B:** Dodatkowy ekran w Mind (więcej pracy, ~4h)

---

### 2. Breathing Exercises Scope

**Dokumentacja mówi:** 5 technik (Box, 4-7-8, Calming, Energizing, Sleep)

**Pytanie:** Czy dla MVP wystarczą 2-3 techniki?
- Box Breathing (najpopularniejsza)
- 4-7-8 (do snu)
- Calming (na stres)

Pozostałe można dodać w 1.1.

---

### 3. Meditation Content

**Pytanie:** Skąd weźmiemy audio dla medytacji MVP?
- **Opcja A:** Placeholder z free ambient sounds (np. freesound.org)
- **Opcja B:** Tylko timer bez audio (silent meditation)
- **Opcja C:** Masz już content?

---

### 4. Exercise Library - 500 exercises

**Dokumentacja mówi:** 500+ exercises

**Pytanie:** Skąd mają pochodzić dane ćwiczeń?
- **Opcja A:** Hardcoded JSON file (quick)
- **Opcja B:** API zewnętrzne (wger.de API?)
- **Opcja C:** Masz już bazę danych ćwiczeń?

Dla MVP wystarczy ~50-100 ćwiczeń.

---

### 5. AI Chat - API Keys

**Pytanie:** Czy AI Chat powinien działać w MVP bez kluczy API?
- **Opcja A:** Wyłączyć chat do czasu kluczy
- **Opcja B:** Mock responses (placeholder)
- **Opcja C:** Użyć free LLM (np. local Llama via Ollama)

---

### 6. Offline Mode

**Pytanie:** Jak ważny jest offline mode dla MVP?

**Obecna sytuacja:**
- Drift DB działa offline ✅
- SyncQueue table istnieje ✅
- Sync logic NIE zaimplementowana ❌

**Opcje:**
- **A:** MVP bez sync (działa offline, ale bez sync do cloud)
- **B:** Basic sync (upload tylko, bez conflict resolution)
- **C:** Full sync (więcej pracy, ~8-10h)

---

## PROPONOWANA KOLEJNOŚĆ TASKÓW

### Phase 0: Fixes (4h)
1. **Fix provider conflict** (1h) - KRYTYCZNE
2. Test password reset (1h)
3. Fix hardcoded user IDs w meditation_providers (1h)
4. Verify all providers use real repos (1h)

### Phase 1: Mind Module (16h)
1. **Meditation Player** (8h)
   - Player screen z just_audio
   - Play/pause/seek
   - Background playback
   - Session completion tracking

2. **Breathing Exercises** (6h)
   - 3 techniki (Box, 4-7-8, Calming)
   - Animated circle
   - Timer z fazami

3. **Placeholder meditations** (2h)
   - 5-10 entries w DB
   - Free ambient audio

### Phase 2: Improvements (8h)
1. Exercise Library persistence (4h)
2. Streak UI na Home (2h)
3. Polish & testing (2h)

**Total: ~28h** (mniej niż wcześniejsze 48h po korekcie audytu)

---

## ZAŁOŻENIA

1. **API Keys** - nie są potrzebne dla MVP (mock responses OK)
2. **Meditation content** - placeholdery wystarczą
3. **Exercise library** - 50-100 ćwiczeń wystarczy
4. **Sync** - offline-first bez cloud sync dla MVP
5. **Onboarding** - skip dla MVP
6. **IAP** - skip dla MVP (free access)

---

## DECISION LOG

| Decyzja | Status | Notes |
|---------|--------|-------|
| Mood tracking location | ❓ PENDING | Czy w check-in wystarczy? |
| Breathing exercises count | ❓ PENDING | 3 vs 5 technik |
| Meditation audio source | ❓ PENDING | Placeholder vs content |
| Exercise data source | ❓ PENDING | JSON vs API |
| AI Chat w/o API keys | ❓ PENDING | Mock vs disable |
| Offline sync | ❓ PENDING | None vs basic |

---

*Analiza utworzona: 2025-12-02*
*Czekam na odpowiedzi przed implementacją*
