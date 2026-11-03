# Programs — Session run

Epic E3 · Milestone M2 · Source: [`../README.md`](../README.md)

### US-303 · Walk a session with nothing between me and the words
As a **Writer**, I want a full-screen session with one prompt per page — 1 to 3 prompts, prompt counter, progress dots, nothing else — so that I write rather than navigate. [§5.5, §2.1]

- Each prompt shows its text, helper and per-type input (types: free, list, scale, choose, letter). **[invariant]** [§4.2, §4.6]
- Back navigation keeps text. [§5.5]
- Target times: 90 s to open and start, 5 min to finish. [§2.1]
- No chrome except close, progress dots and prompt counter. [§5.5]

### US-304 · Never lose a word
As a **Writer**, I want the session to autosave every keystroke locally and resume from any point, so that nothing typed is ever lost. [§5.5]

- Acceptance bracket: **nothing typed is ever lost across app kill, airplane mode, or backgrounding.** **[screen bracket]** [§5.5]
- Autosave every keystroke to local SQLite, with a debounced flush every 2 s. **[invariant]** [§5.5, AGENTS.md]
- A session writes into the day it was **started on** — a session started at 23:57 and completed at 00:03 lands on that evening's `local_date`, not next day's. **[invariant: local_date, not UTC]** [§5.5, §4]

### US-305 · Close the session and meet the next day
As a **Writer**, I want a mood-after check-in at the last prompt, then a completion screen with the streak increment and one link — so that finishing feels like arriving. [§5.5, §2.1]

- Last prompt → mood-after check-in → completion: streak increment + a single "Read what you wrote" link, and one tap to rate the day if still unrated. [§5.5]
- Progression: completing day N unlocks day N+1. **[invariant]** [§2.5]
- Days are calendar days, not completion-gated: skipping day 3 and opening day 5 later is offered a **one-line catch-up note, not a backlog**. **[invariant]** [§2.5]
