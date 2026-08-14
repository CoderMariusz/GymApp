# Skeleton

Used while the first paint of a screen is waiting on data — Home, history list, exercise detail.

- **Mirror the real layout**, including card heights and the number of rows, so content does not
  jump when it arrives. A skeleton that is the wrong shape is worse than a blank surface.
- Opacity pulse only, 1.4s: no sweeping shimmer, nothing that reads as celebration.
- Never skeleton a number the user is about to act on. Set entry is either the real proposal or the
  screen is not ready.
- Anything slower than about 3 seconds stops being a skeleton and becomes a `Banner` that names
  the wait ("Waiting for connection").
- Collapses to a static surface under `prefers-reduced-motion`.
