# Today — Home screen

Epic E2 · Milestone M2 · Source: [`../README.md`](../README.md)

### US-201 · Open Today and see my one thing
As a **Writer**, I want Today to hand me exactly one thing — rate the day, tag it, name three small things — so that starting is not a decision. [§5.3]

- Content: date eyebrow, greeting, streak chip with the grace indicator, **rate today** (hero), tag row, three small things, the day's sentiment, a write action, a notes action, two most recent entries. [§5.3]
- The rating is the only hero. Writing and notes are one tap away and nothing on the screen depends on them. [§5.3]
- No banners, no upsells, no notification badges — ever. **[invariant]** [§5.3]
- The streak chip carries the grace indicator, and when a day has been missed the recovery action is one tap from the chip. [§2.3, §5.3]

### US-202 · The whole screen works offline
As a **Writer**, I want every element of Today interactive before any sync completes, so that the network is never a dependency of an interaction. **[invariant]** [§5.3, §7.1]

- Screen hydrates from SQLite in < 150 ms. **[screen bracket]** [§5.3]
- Every read comes from SQLite. **[invariant]** [§7.1]
- No account required: local-only is the app's default state, not a degraded one. [§5.1]
