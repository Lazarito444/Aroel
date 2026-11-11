# Today — Streak

Epic E2 · Milestone M2 · Source: [`../README.md`](../README.md)

### US-207 · Keep a streak, and get it back if I want it
As a **Writer**, I want a streak that forgives one missed day, and that I can recover by hand when life happens, so that the streak is a record of my attention rather than a punishment. [§2.3]

- A day counts if **any** of these happened: a rating, a tag, a gratitude line, or something written. **[invariant]** [§2.3]
- One missed day spends a grace token instead of breaking the streak; two consecutive missed days reset it. **[invariant]** [§2.3]
- **Recovery:** the user can mark a missed day as kept, from the streak chip on Today or from Settings. Recovery is free and unlimited, and recovered days are marked as recovered. **[invariant]** [§2.3]
- No guilt copy anywhere: no "you lost your streak", no red, no exclamation marks. **[invariant — store-risk constraint, §6.5]** [§2.3, §6.5]
- The streak chip shows the current streak, the longest streak, the grace tokens left and the recovered days. [§2.3, §5.3]
- Notes never count toward the streak — a note has no day. **[invariant]** [§2.6]
