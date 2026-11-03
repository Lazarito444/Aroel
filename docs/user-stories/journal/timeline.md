# Journal — Timeline

Epic E5 · Milestone M4 · Source: [`../README.md`](../README.md)

### US-504 · See the archive as months, not rows
As a **Writer**, I want a reverse-chronological timeline grouped by month, each month header showing entries written, days kept and average rating, with filter chips, so that I can feel the long arc. [§5.8]

- Filters: program / tag / rating range. [§5.8]
- Virtualised, no pagination gap. **[invariant]** [§5.8]
- All list endpoints paginate server-side; nothing returns unbounded collections. **[invariant, AGENTS.md]** [§7.2]
