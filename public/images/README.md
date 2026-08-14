# Product imagery

Empty on purpose.

`DESIGN-BRIEF.md` §9.4 approves **two** assets for v1.0: the heavy-dumbbell hero and the
woman stretching in a dark gym. Four of the six generated images are held — the runner
implies GPS, the smartwatch implies heart-rate monitoring, the planner belongs to v1.1 and
the meditation shot to v1.2. **A photograph is a requirement claim**, so an image that
promises a feature the app does not have is a defect no code can fix.

The design system currently ships three images in
`.claude/skills/lifeos-strength-design/assets/imagery/` — `hero-dumbbell.png` (approved
asset 1) plus two body shots cropped from the mockup sheet. **The approved asset 2 —
the woman stretching — is not among them.** Resolve that gap before shipping a hero.

Nothing is copied here yet because §3.2 requires build-time preprocessing (WebP/AVIF,
deterministic filenames, explicit width and height) — the static export has no request-time
image optimiser. Dropping a 2.5 MB PNG in `public/` would ship exactly the thing that rule
forbids.

**Never** use generated imagery to demonstrate technique (§9.5).
