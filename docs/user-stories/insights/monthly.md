# Insights — Monthly

Epic E6 · Milestone M4 · Source: [`../README.md`](../README.md)
Ramp colours are literal spec (§6.6): `#9E3B2B` `#A95B41` `#B77A5A` `#C29675` `#CDB098` `#D8CDB8` `#C4C3A6` `#B0B996` `#9AA382` `#84906F` `#6E7B5B`, diverging around 2.5.

### US-602 · Read the month as a colour field
As a **Writer**, I want the month as a grid of ramp-coloured days with the same numbers under it, so that I can see a whole season at a glance. [§2.5, §5.8]

- Cells: unrated = `paper.sunk` with a faint numeral; ramp colour per §6.6. **[ramp literal spec]** [§5.8, §6.6]
- Tap a cell opens the day detail. [§5.7, §5.8]
- The month shows the same numbers as the week, over the month, plus a per-week breakdown inside it and the best day of the month. [§5.8]
- Every number is computed on device and renders offline. **[invariant]** [§5.8, §7.4]
- Empty states teach; they never scold. **[invariant]** [§5.8]
