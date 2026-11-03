# Journal — Momentary mood

Epic E5 · Milestone M4 · Source: [`../README.md`](../README.md)
Emotion taxonomy: §4.6 — eight families (joy, trust, calm, sadness, fear, anger, shame, surprise), 6–9 labels each, stable slugs.

### US-503 · Check in with a momentary mood
As a **Writer**, I want an optional mood check-in choosing an emotion from a fixed taxonomy, with no consequence for skipping, so that moods accumulate without nagging. [§3, §4.6, §8.3]

- Taxonomy: eight Plutchik-derived families (joy, trust, calm, sadness, fear, anger, shame, surprise), 6–9 labels each, stable slugs so analytics stay comparable across releases. **[invariant]** [§4.6]
- Same 0–10 half-point domain as the day rating. **[invariant]** [§4.2]
- Correlations between moods and activities are explicitly out of v1. **[invariant: §3 scope]** [§3]
