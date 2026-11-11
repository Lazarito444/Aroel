# Insights — Sentiment highlights

Epic E6 · Milestone M4 · Source: [`../README.md`](../README.md)

### US-603 · See the best days, not just the average
As a **Writer**, I want my best days surfaced — the highest-sentiment day of the week or month, with the entry that earned it — so that a hard month still shows me what was good in it. [§5.8]

- The highlight is the highest `day_sentiment` in the window, with the day's entry shown underneath it. [§4.2, §5.8]
- The highlight is chosen by the stored sentiment value, never by a model re-reading the text. **[invariant]** [§8.3]
- If the window has no sentiment recorded, the highlight is simply absent — no substitute, no estimate. [§5.8]
- Nothing is uploaded and no network call is needed to render it. **[invariant]** [§8.3, §7.4]
