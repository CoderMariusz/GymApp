<!-- AI-INDEX: design brief, handoff, screens, states, tokens, accessibility, DESIGN_ID -->

# Design Brief — v1.0

**Version:** 1.0
**Date:** 2026-08-12
**Audience:** the design tool producing the v1.0 interface
**Status:** READY FOR DESIGN — **input contract for `G-DESIGN`, not its completion**
**Related:** `PRD.md` (what must work), `ARCHITECTURE.md` (system boundaries), `PLAN.md` (build order)

> **This brief does not satisfy `G-DESIGN`. It enables it.** `G-DESIGN` passes only when the produced and accepted design package exists — frames, tokens, both themes, all states from §7, `DESIGN_ID` per tested frame, accessibility annotations. A text brief is not a design. Do not treat this document as a design artefact when deciding whether scored feature work may begin.

> This document is self-contained. Do not infer product behaviour, routing or data states from elsewhere — everything needed to design v1.0 is here. Where a constraint is non-negotiable it says so, and the reason is given. Constraints without reasons get quietly dropped later, so every one of them is justified.

---

## 1. What this product is

A strength-training log. The user is standing in a gym, between sets, holding a phone in one hand. They want to record the set they just finished and put the phone away.

That is the entire v1.0 product. Not a coach, not a social network, not a nutrition tracker.

### 1.1 The one sentence that should drive every design decision

**The user is not looking at this screen. They are glancing at it.**

Every interaction competes with the rest between sets — roughly sixty to a hundred and eighty seconds, during which the user is also breathing hard, possibly holding a barbell collar, and losing focus. A design that is pleasant to explore at a desk and slow to operate at a squat rack has failed.

### 1.2 Measurable target

A standard session — six exercises, eighteen working sets, all previously performed — must be logged in **under sixty seconds of cumulative active interaction time**. Rest time is not counted; only the time the user is actually touching the screen. That is roughly **two seconds of interaction per set**, including confirming pre-filled values.

Two seconds per set means: one tap for the common case. Anything requiring the user to read, decide, then aim will not fit.

---

## 2. Who uses it

**Primary persona — Marek, 31.** Trains three to four times a week. Knows what progressive overload is. Currently uses a spreadsheet or a competing app. Trains at a gym with poor mobile signal.

His pains, in order of severity:
1. Re-typing the same numbers he entered last week.
2. Not being sure the session actually saved.
3. Too many taps between finishing a set and being done with the phone.
4. Checking whether he is progressing takes more effort than it should.

He is not a beginner and does not want to be taught how to squat. He wants a fast, trustworthy ledger.

**Not designing for:** absolute beginners needing exercise instruction, bodybuilders tracking macros, or anyone wanting a social feed. Those are explicitly out of scope and should not shape the interface.

---

## 3. Non-negotiable constraints

These come from the architecture and cannot be designed around.

| # | Constraint | Reason |
|---|---|---|
| C-1 | **Bottom navigation has exactly five destinations:** Home, Workout, Exercises, History, Progress | A sixth tab makes targets too small for one-handed use at the width we support |
| C-2 | **Settings is not a tab.** It is reached from an avatar or gear control in the Home header | Settings is visited rarely; a tab position is expensive |
| C-3 | **Sync state is a first-class visual element, never only a toast** | A toast that disappears cannot answer "did my workout save?", which is the user's second-worst pain |
| C-4 | **Colour alone may never carry meaning** for personal records, errors, or sync state | Accessibility requirement, and gym lighting is unreliable |
| C-5 | **Touch targets are at least 44×44 px** | One-handed use, sweaty hands, moving user |
| C-6 | **Safe-area insets designed in from v1.0** | The same design ships inside a native shell in v1.1; retrofitting is expensive |
| C-7 | **The rest timer stays visible but never blocks set entry** | The user must be able to log while the timer runs |
| C-8 | **Every destructive action has explicit confirmation and a described recovery path** | Deleting a workout destroys derived personal records |
| C-9 | **Charts require an accessible tabular or textual alternative** | Screen-reader users cannot read a line chart |
| C-10 | **Polish strings are the layout stress case** | Polish runs roughly 20–30% longer than English; if it fits in Polish it fits everywhere |

---

## 4. Scope of v1.0 — design only these

The engineering scope was deliberately cut. **Do not design** templates, CSV export, body measurements, or social login buttons — they are not in v1.0 and designing them wastes effort and invites scope creep.

| Area | In v1.0 | Notes |
|---|---|---|
| Authentication | **Email and password only** | No Google or Apple buttons. Sign in, sign up, password reset, recovery |
| App shell | Yes | Five tabs, header, safe areas |
| Home | Yes | New user, returning user, active-workout resume, queued-sync warning |
| Active workout | **Yes — the critical flow** | Most of the design effort belongs here |
| Exercise catalog | Yes | List, search, filter, detail, custom exercise create and edit |
| History | Yes | List, filter by exercise, detail, edit, delete |
| Progress | Yes | Estimated one-rep max per exercise, weekly volume, personal-record timeline |
| Settings | Yes | Units, theme, language, profile, data and privacy, about, logout |
| System states | Yes | Loading, empty, offline, queued, sync failed, update available, fatal error |
| Templates | **No** — v1.0.1 | |
| CSV export | **No** — v1.0.1 | The data-export entry point in Settings still exists for legal reasons |
| Body measurements | **No** — v1.0.1 | |

---

## 5. The critical flow — active workout

This is where the product succeeds or fails. Everything else is supporting cast.

### 5.1 Shape of the flow

```
Home
  → Start workout (blank)
    → Add exercise  ──→ Exercise selector (recent · frequent · search)
      → Set editor   ──→ repeat per set, per exercise
        → Rest timer  (runs concurrently, never blocking)
    → Complete workout
      → Summary (working sets · duration · volume · new records · sync state)
        → Home
```

### 5.2 The set editor is the product

The single most important component. Design it first and design it hardest.

**The common case, which must be one tap:** the user has done this exercise before. Weight and repetitions are pre-filled from the last session. They performed the same thing again. They confirm.

**The second case, which must be fast:** same exercise, one value changed. They adjust weight or reps, then confirm. Two or three interactions, no keyboard if avoidable.

**The rare case, which may be slower:** a new exercise with no history. Full entry.

Design implications to resolve:
- Pre-filled values must be visibly *proposals*, not recorded facts. The user must be able to tell at a glance what has been logged and what is merely suggested.
- Show the previous session's value alongside, with its age ("last time: 80 kg × 8, 5 days ago"). This is the pain point that brings users in.
- Numeric adjustment needs to work without a keyboard. Steppers, quick-pick chips of plausible values, or a scrub control — your call, but the keyboard is the slow path and must not be the default.
- Warm-up sets are visually distinct from working sets. They do not count toward volume or records, and the user must be able to see which is which without reading labels.

### 5.3 Fields vary by exercise

Not every exercise records the same things. The set editor adapts to a `tracks` property on the exercise:

| Exercise kind | Fields shown |
|---|---|
| Standard barbell or dumbbell lift | weight, repetitions |
| Bodyweight movement | repetitions; weight optional and additive |
| Timed hold or carry | duration |
| Distance work | distance, optionally duration |

Optional on every set, never in the primary path: rating of perceived exertion, and a short note.

Design a layout that accommodates all four without feeling like four different screens.

### 5.4 Rest timer

Starts automatically when a set is confirmed. Default duration comes from the exercise. The user can change or skip it. It signals through vibration and sound where the platform allows.

It must remain visible while the user logs the next set, and it must not steal focus or cover input. It must survive the user switching apps and coming back.

---

## 6. States — the part that is usually missed

Every screen needs its states designed. This inventory is the completeness criterion for `G-DESIGN`: a screen is not done until each applicable state has a frame or an explicit note that it does not apply.

### 6.1 Universal states

| State | When | Must convey |
|---|---|---|
| Loading | Data in flight | Something is happening; how long roughly |
| Empty | No data yet | What this screen will show, and how to get there |
| Error | Operation failed | What failed, whether it is retryable, what to do |
| Offline | No connectivity | What still works, what does not |

### 6.2 Sync states — specific to this product

The user's second-worst pain is not knowing whether the session saved. These five states are distinct and must be visually distinguishable. **The interface must never say "saved to the cloud" when the data is only on the device.**

| State | Meaning | Emotional job |
|---|---|---|
| `draft_local` | **The workout is in progress and safely stored on this device. It has not been sent to the server yet — and should not be.** | Quiet confidence. The user must never suspect their in-progress session is at risk, but this state should not shout |
| `saved` | On the server, confirmed | Reassure and get out of the way |
| `queued` | On the device, waiting for connectivity | Reassure — this is normal and the data is safe |
| `syncing` | In transit | Show progress without demanding attention |
| `failed` | Attempt failed, will retry | Inform without alarming; the data is still safe |
| `conflict` | Needs a decision (v1.1, design the slot now) | Demand attention; this is the only one that should interrupt |

**The full progression is:** `draft_local` → *(user completes workout)* → `queued` → `syncing` → `saved`, with `failed` and `conflict` as exceptional branches.

`draft_local` is distinct from `queued` and confusing them is a real design failure. `draft_local` means the user is *still training* — nothing has been submitted because nothing is finished. `queued` means the user *has finished* and the completed session is waiting for a connection. Showing "waiting to sync" during an active workout would suggest something is stuck when the system is behaving exactly as intended.

`queued` deserves particular care. It is the **normal, expected state** for a user in a gym basement — it must read as "everything is fine" rather than as a warning. Treating it like an error would undermine the exact trust the product is built on.

### 6.3 Update available

A new version can be installed. It must **never** interrupt an active workout. Design the deferred case: the notice waits, unobtrusively, until the session is complete.

---

## 7. Screen inventory

Each screen lists states requiring a frame. This is the checklist `G-DESIGN` verifies against.

| Screen | Required states |
|---|---|
| Sign in | default · validation error · wrong credentials · in progress |
| Sign up | default · validation error · email taken · success |
| Password reset | request · sent · set new password · expired link |
| Home — new user | empty, with the primary call to action |
| Home — returning | recent activity · start workout · queued-sync banner if applicable |
| Home — active workout | resume prompt, visually dominant |
| Active workout | empty (no exercises) · one exercise · many exercises · scrolled · timer running · offline · completing |
| Exercise selector | recent · frequent · search results · no results · filtered |
| Set editor | pre-filled · empty · warm-up · each of the four field layouts · invalid input |
| Workout summary | with records · without records · queued · synced |
| Exercise list | default · searching · no results · filters active |
| Exercise detail | full content · minimal content (no tips available) · custom exercise |
| Custom exercise editor | create · edit · validation error · delete confirmation |
| History list | populated · empty · filtered · loading more |
| Workout detail | default · editing · delete confirmation |
| Progress | populated · insufficient data · per-exercise chart · records timeline · range selector |
| Settings | index · each subsection · destructive confirmations |
| System | fatal error · offline · update available |

---

## 8. Design tokens

Define these as semantic roles, not raw values. The implementation uses Tailwind and shadcn/ui, so tokens should map onto that model.

**Colour roles needed:** surface levels · text primary and secondary · border · primary action · destructive · success · warning · and five distinct sync-state roles per §6.2.

Both light and dark themes are required. **Dark is likely the more used theme** — gyms are dim and phones are set to dark. Do not treat it as an afterthought.

**Typography:** numerals in the set editor must be large and unambiguous. The user reads them at arm's length while breathing hard. Tabular figures where numbers align in columns.

**Spacing and hit areas:** a base scale plus an explicit minimum interactive size of 44 px.

---

## 9. Accessibility

Target is WCAG 2.2 AA on critical flows. Automated checks are necessary but not sufficient — annotate the following:

- Focus order on every form and on the set editor.
- Screen-reader labels for controls whose meaning is carried by an icon.
- Contrast verified in both themes, including the sync-state colours.
- Layout at 200% text scaling without loss of function.
- The tabular alternative for every chart.

---

## 10. Localisation stress cases

English and Polish ship together in v1.0. Test the layout against these actual strings:

| English | Polish | Growth |
|---|---|---|
| Rest | Przerwa | +100% |
| Save | Zapisz | +50% |
| Sets | Serie | +25% |
| Add exercise | Dodaj ćwiczenie | +33% |
| Workout summary | Podsumowanie treningu | +57% |
| Waiting for connection | Oczekiwanie na połączenie | +18% |
| Personal record | Rekord życiowy | +7% |
| Delete workout | Usuń trening | flat |

Polish also uses diacritics that extend below the baseline (ą, ę) — check line height in dense numeric layouts.

---

## 11. What to deliver

| Item | Requirement |
|---|---|
| Mobile reference | 390×844 |
| Desktop reference | 1440 wide, fully usable — not merely a stretched phone |
| Themes | Light and dark, complete |
| Token definitions | Semantic roles, both themes |
| Component states | Per §6 and §7 |
| Frame identifiers | Stable `DESIGN_ID` per frame, mapped to requirement identifiers from the PRD |
| Accessibility annotations | Per §9, on critical paths |
| Asset export rules | Naming, formats, densities |

A frame labelled "final" is not a deliverable. The state inventory in §7 is the acceptance criterion.

---

## 12. Deliberately left to the designer

The constraints above are boundaries, not a design. These are open, and a good answer to any of them would improve the product:

1. **How a set is confirmed.** A large button, a swipe, a tap on the row — the two-second budget is the constraint, the mechanism is open.
2. **Numeric input without a keyboard.** The hardest and most valuable problem in this brief.
3. **How pre-filled proposals are distinguished from recorded facts.** Weight, colour, position, or something better.
4. **Where sync state lives.** Per-set, per-workout, global, or a combination.
5. **How the rest timer stays visible without occupying space** the set editor needs.
6. **Home screen composition.** What a returning user should see first.

---

## 13. What would make this design fail

Stated plainly so it can be checked against:

- A set takes more than two or three interactions in the common case.
- The user cannot tell whether their workout is saved without navigating somewhere.
- `queued` reads as an error.
- The rest timer covers the input the user needs.
- Polish strings wrap or truncate in the set editor.
- The dark theme is a colour inversion rather than a designed theme.
- Charts have no non-visual alternative.
- An update interrupts an active workout.
