# Journal — Per-day writing

Epic E5 · Milestone M2 · Source: [`../README.md`](../README.md)

### US-501 · Write what today needed
As a **Writer**, I want a plain editor for the day I am on, so that the days with something to say have a proper home. [§5.4]

- Markdown-lite: bold, italic, headings, lists, quotes. No embeds, no tables, no attachments. **[invariant: §3 scope]** [§3, §5.4]
- The entry attaches to the day it was written on — an entry started at 23:57 belongs to that evening, not to the next day. **[invariant: local_date, not UTC]** [§4, §5.4]
- Autosave every keystroke to local SQLite, with a debounced flush every 2 s. **[invariant]** [§5.4, AGENTS.md]
- Acceptance bracket: **nothing typed is ever lost across app kill, airplane mode, or backgrounding.** **[screen bracket]** [§5.4]
- Acceptance bracket: save-to-visible latency < 16 ms; **entry readable offline forever.** [§5.4]
