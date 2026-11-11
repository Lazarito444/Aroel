# Notes — The shelf

Epic E5 · Milestone M3 · Source: [`../README.md`](../README.md)

### US-505 · Keep notes that have no date
As a **Writer**, I want to write a note that belongs to no day, so that the things I jot down outside my daily record have a home of their own. [§5.6]

- Notes have no `day_id`: they are the one thing outside the `days` spine. **[invariant]** [§4.1, §4.2]
- One editor, no date field by design. **[invariant]** [§5.6]
- Notes are excluded from day analytics and from the streak. **[invariant]** [§2.6, §5.6]
- List view: newest first, pinned notes first. **[invariant]** [§5.6]
- Pinned notes stay at the top; delete is soft for 30 days, then purged, same as entries. **[invariant]** [§4.2, §8.2]
- Autosave on the same terms as entries: every keystroke to local SQLite, 2 s debounced flush, nothing lost across app kill. **[invariant]** [§5.4, §6.4]
