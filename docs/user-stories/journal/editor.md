# Journal — Free-entry editor

Epic E5 · Milestone M4 · Source: [`../README.md`](../README.md)

### US-501 · Write freely when the program doesn't fit
As a **Writer**, I want a free-entry editor with markdown-lite, tag chips, photos and dictation, so that free writing is the escape hatch, not the product. [§5.6, §3]

- Markdown-lite: bold, italic, headings, lists, quotes — no embeds, tables, or attachment types beyond photos and audio in v1. **[invariant: §3 scope]** [§1.4, §3]
- `[[` autocomplete creates entry links (backlinks resolved on read). [§5.6, §4.2]
- Up to 3 photos per entry; media keys `u/{user_id}/e/{entry_id}/{media_id}` with short-lived signed URLs, 1 GB soft quota. **[invariant]** [§3, §7.5]
- Acceptance bracket: save-to-visible latency < 16 ms; **entry readable offline forever.** [§5.6]
