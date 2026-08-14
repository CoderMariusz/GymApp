<!-- AI-INDEX: designer, handoff, cover note, package, what to design, what not to design -->

# Designer handoff — cover note

**Date:** 2026-08-12 · **Product:** strength training log, working name LifeOS (name is changing — see below)
**Read this page first. Then read `DESIGN-BRIEF.md`, which is the actual specification.**

---

## 1. What you are receiving

| File | What it is | Binding? |
|---|---|---|
| **`DESIGNER-HANDOFF.md`** | This page. Context and decisions that constrain design | Context |
| **`DESIGN-BRIEF.md`** | **The specification.** Screens, states, constraints, photography direction | **Yes — this is the contract** |
| Photography assets | Separate, from the owner | See `DESIGN-BRIEF.md` §9.4 for which are approved |

You are **not** receiving the PRD, architecture or implementation plan. They exist, but they contain build ordering, hour estimates and database schema, none of which should influence how the product looks. Everything design-relevant has been lifted into the brief. If you find yourself needing something that isn't there, that's a gap in the brief — ask, don't guess.

---

## 2. The product in one paragraph

A person is at the gym, mid-workout, standing between two sets. They have roughly thirty seconds before the next one. They pick up their phone with one hand — often sweaty, sometimes gloved — enter what they just lifted, and put the phone down. **That is the entire product.** Everything else is secondary to making those few seconds fast, certain, and unambiguous.

**The user is not looking at this screen. They are glancing at it.** Every layout decision follows from that sentence.

---

## 3. What v1.0 is — and deliberately is not

**Design these:** authentication and settings · exercise catalogue and selector · active workout logging · rest timer · workout history · progress charts and personal records.

**Do not design these.** They were cut on purpose and drawing them creates pressure to build them:

| Not in v1.0 | Returns |
|---|---|
| Workout templates and routines | v1.0.1 |
| CSV export of history | v1.0.1 |
| Body measurements | v1.0.1 |
| Google / Apple sign-in | v1.0.1 |
| Life coaching, daily planning, mood | v1.1 |
| Meditation, breathing, mental health | v1.2 |
| Heart rate, GPS, calories, wearables | not committed at all |

The last row matters most for imagery. See §5.

---

## 4. The five decisions that shape your work

**1 — There is no template feature, but there is "repeat last workout" (FIT-24).**
Because routines were cut, a returning user would otherwise start every session from an empty screen and rebuild it by hand. `DESIGN-BRIEF.md` §6.9 covers this. It is the **primary way a returning user starts a workout** — not a secondary convenience — and it must not look like saving a reusable template, because nothing reusable is created.

**2 — Sync state is a first-class part of the interface, and there are six of them.**
`draft_local` → `queued` → `syncing` → `saved`, with `failed` and `conflict` as exceptional branches. Section §6.2 explains why `draft_local` and `queued` must never be confused: one means *still training*, the other means *finished and waiting for signal*. Showing "waiting to sync" mid-workout would report a failure where the system is working correctly.

**The interface must never say "saved to the cloud" when the data is only on the device.** This is the single hardest rule in the brief.

**3 — The workout must be completable with no signal at all.**
Offline is not an error state to be styled once and forgotten. It is a normal operating condition — gyms have basements.

**4 — Polish and English from day one.**
Polish strings run substantially longer than English. §11 lists the specific strings that break layouts. Treat Polish as the stress case, not the translation.

**5 — The brand name is not settled.**
"LifeOS" is being dropped and a replacement chosen. Use it as a **project label only**. Do not invest irreversible effort in a logo, wordmark or identity that depends on the final name. The design system, layout and colour work can proceed entirely without it.

---

## 5. Photography — read §9 of the brief before using any image

This is the part most likely to cause an expensive mistake, so it is worth stating twice.

**A photograph is a requirement claim.** A running route implies GPS tracking. A heart-rate waveform implies wearable integration. This product does neither, and an image suggesting otherwise creates a defect no code can fix.

Of the six generated images supplied, **two are approved for v1.0** — the man with the dumbbell and the woman stretching. The runner, the smartwatch, the planner and the meditation shot are all good work aimed at versions that do not exist yet. §9.4 has the full manifest with reasoning.

**v1.0 imagery stays in one world: strength, gym, logging, progress.** Do not assemble a set spanning running, wearables, planning and meditation — that reads as *an app that does everything*, which is exactly the positioning this project spent a full scope cut escaping.

And: **AI-generated photography may never demonstrate exercise technique.** Hero images, backgrounds, onboarding and empty states are fine. "This is how you perform a deadlift" is not — a generative model produces beautifully lit movement containing subtle biomechanical errors, and the image looks authoritative while doing it.

---

## 6. What to deliver, and in what order

Delivery is **split into two stages** so that engineering can start while you are still designing.

**Stage 1 — design system.** Tokens, typography, spacing, the five-tab shell, base components, global states (loading, empty, error, offline), **all six sync states**, accessibility rules, both themes, Polish long-string pass.

Nothing can be built until this exists. It is the critical path for the entire project.

**Stage 2 — screens, in this order:** settings → catalogue → **workout flow** → timer → history → progress.

Each screen package is frozen and handed over on its own. You do not need to finish the progress dashboard before engineering can start on settings.

The workout flow is the hardest and most important. If you want to design it first and hand it over last, that is fine — but the system in Stage 1 should be built with its requirements already on your desk, because it will demand the most from the base components.

---

## 7. How this design will be judged

Not on how the frames look in isolation. On three things:

1. **State completeness.** §7 of the brief is an inventory. A screen is finished when every applicable state has a frame or an explicit note that it does not apply. A frame labelled "final" with no empty, error, offline or loading state is not a deliverable.
2. **Whether a distracted person can use it one-handed in under a minute.** Repeating a previous workout targets under 60 seconds of active interaction; building one from scratch targets under 120.
3. **Whether it ever lies about where the data is.**

---

## 8. What is deliberately left to you

Section §13 lists this in full. In short: visual personality, motion, illustration style, chart aesthetics, empty-state voice, and the specific palette within the stated constraints. The brief specifies behaviour and structure, not taste — where it is silent, it is silent on purpose.

If something in the brief seems to over-specify a purely visual choice, say so. That is a bug in the brief.
