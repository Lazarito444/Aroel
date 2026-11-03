# Today — Home screen

Epic E2 · Milestone M2–M3 · Source: [`../README.md`](../README.md)

### US-201 · Open Today and see my one thing
As a **Writer**, I want Today to hand me exactly one session card — program, day N of M, duration, progress, one primary action — so that starting is not a decision. [§5.3]

- Content: date eyebrow, greeting, streak chip with grace indicator, session card (hero), rate today, tag row, three small things, two most recent entries. [§5.3]
- No banners, no upsells, no notification badges — ever. **[invariant]** [§5.3]
- Single primary action on the session card. [§5.3]

### US-202 · The whole screen works offline
As a **Writer**, I want every element of Today interactive before any sync completes, so that the network is never a dependency of an interaction. **[invariant]** [§5.3, §7.1]

- Screen hydrates from SQLite in < 150 ms. **[screen bracket]** [§5.3]
- Every read comes from SQLite. **[invariant, §7.1]**
