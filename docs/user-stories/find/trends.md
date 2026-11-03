# Find — Trends

Epic E6 · Milestone M5 · Source: [`../README.md`](../README.md)

### US-603 · See the trend honestly
As a **Writer**, I want a rating line at half-step resolution with average and direction, entry counts and my streak, so that I can't fool myself. [§5.10]

- Rating line over 7 days / 30 days / year, half-step resolution. [§5.10]
- Shows entries count, streak and emotion frequency bars, weekday pattern. [§5.10, §3]
- Every chart derives from local data and renders offline. **[invariant]** [§5.10, §8.3]
- Empty states teach; they never scold. **[invariant]** [§5.10]

### US-604 · Compare tagged days, with an honest sample
As a **Writer**, I want the comparisons ("days tagged exercise average 4.2, other days 3.1") to appear only with a declared sample guard, so that I'm never shown a conclusion drawn from two days. [§5.10]

- Tag comparison appears **only when at least 5 tagged days exist in each group**; the guard is explicit. ⚠ **[invariant — hardcoded threshold, do not compute "when it looks right"]** [§5.10]
- Computed locally with plain arithmetic — no model, no network. **[invariant]** [§8.3]
