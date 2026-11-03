# Journal — Day record & day detail

Epic E4 · Milestone M3 · Source: [`../README.md`](../README.md)
The rating control used here is the one specced in [`../today/rating.md`](../today/rating.md).

### US-401 · Edit any part of a past day
As a **Writer**, I want to open any past day and edit its rating, tags, gratitude and note, with the last write winning, so that a forgotten 23:50 rating is saveable. [§2.2, §5.11]

- Last write wins, including across devices: an upsert on `days` keyed by `(user_id, local_date)` settles to the later write with no special casing. **[invariant]** [§2.2, §7.3]
- Future dates are read-only-empty, never editable. **[invariant]** [§5.11]
- Rating is stored as `rating_half`, a smallint 0–10 counting half points — never a float or string; the client converts only at the presentation boundary. **[invariant]** [§4.3, AGENTS.md]

### US-402 · Unrated is not zero
As a **Writer**, I want "not rated" to look like nothing, not like my worst day, so that the record stays honest. [§4.3]

- Absence is `NULL` in the column and an **omitted field in the API**, never `0` — `0` is a real score for a real day ("A day I'd rather not repeat."). **[invariant]** [§4.3]
- In the calendar an unrated day is a `paper.sunk` cell with a faint numeral — never the ramp's bottom step. **[invariant]** [§4.3, §5.10]
- The day record appears in history as soon as it has a rating. [§2.2]

### US-403 · The scale means something
As a **Writer**, I want the 11 anchors ("A day I'd rather not repeat." → "One of the good ones.") exactly as the spec writes them, so that 2.5 means ordinary and 0 is usable. [§4.5]

- The seven value bands, their labels and anchor copy are literal spec — copy verbatim, don't paraphrase. ⚠ **[invariant, §6 + AGENTS.md: the anchor copy and eleven hex ramp stops are literal]** [§4.5, §6.6]
- Ramp diverges around **2.5**, in-palette, warm into cool; numerals use `paper` only on the two darkest warm steps (0.0–0.5). **[invariant]** [§6.6]

### US-404 · Day detail is the record of one date
As a **Writer**, I want one place that gathers a date's rating, tags, gratitude, session run, entries and note, so that looking back is one scroll. [§5.11]

- Reachable from the calendar, a timeline group header, and an entry's metadata. [§5.11]
- Surfaces "On this day" (one year ago, one month ago) at its foot — never on Today. **[invariant: never on Today]** [§5.12]
