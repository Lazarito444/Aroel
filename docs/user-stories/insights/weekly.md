# Insights — Weekly

Epic E6 · Milestone M4 · Source: [`../README.md`](../README.md)

### US-601 · See the week as numbers
As a **Writer**, I want the last seven days shown as plain numbers — average, direction, days rated, entries, gratitude, tags, sentiment, best day — so that I can read the week without being told what it meant. [§2.4, §5.8]

- Weekly window shows: rating average and direction against the previous week, days rated, entries written, gratitude lines, most-used tags, sentiment average, and the best day of the week. [§5.8]
- Numbers only: no prose, no prompt, no model writes anything. ⚠ **[invariant — no LLM in v1, §8.3]** [§2.4, §8.3]
- Every number is computed on device from local rows and renders offline. **[invariant]** [§5.8, §7.4, §8.3]
- Direction compares the window against the one before it and says which way it moved. [§5.8]
- Empty states teach; they never scold. **[invariant]** [§5.8]
