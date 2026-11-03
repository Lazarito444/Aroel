# Find — Insights calendar

Epic E6 · Milestone M5 · Source: [`../README.md`](../README.md)
Ramp colours are literal spec (§6.6): `#9E3B2B` `#A95B41` `#B77A5A` `#C29675` `#CDB098` `#D8CDB8` `#C4C3A6` `#B0B996` `#9AA382` `#84906F` `#6E7B5B`, diverging around 2.5.

### US-602 · Read the month as a colour field
As a **Writer**, I want a month grid where each cell is coloured by the rating ramp, with a dot on rated days that have entries, so that I can see a whole season at a glance. [§5.10]

- Calendar mode is the default of the two-mode Insights screen. [§5.10]
- Cells: unrated = `paper.sunk` with faint numeral; ramp colour per §6.6; 2 px corner dot on rated days with an entry. **[ramp literal spec]** [§5.10, §6.6]
- Tap opens day detail. Month header: average, days rated, best day. Swipe/arrows between months; year strip under the grid. [§5.10]
