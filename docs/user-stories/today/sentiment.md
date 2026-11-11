# Today — The day's sentiment

Epic E2 · Milestone M2 · Source: [`../README.md`](../README.md)
Emotion taxonomy: §4.6 — eight families (joy, trust, calm, sadness, fear, anger, shame, surprise), 6–9 labels each, stable slugs.

### US-206 · Give the day a tone
As a **Writer**, I want the day's sentiment recorded — by hand from the emotion taxonomy, or derived from what I wrote — so that good and hard days stand out over time. [§4.2, §4.6, §5.3]

- One sentiment per day: `day_sentiment` is unique on (user_id, day_id). **[invariant]** [§4.2]
- Same 0–10 half-point domain as the day rating, so tone and rating are comparable numbers. **[invariant]** [§4.3]
- Two sources: `manual` (the user picks an emotion and a value) and `on_device` (the classifier's tone for the day's writing). A manual pick wins over a computed one. **[invariant]** [§4.2, §8.3]
- If the platform classifier is unavailable, nothing breaks: the day simply has no computed sentiment, and the app is unchanged. **[invariant]** [§8.3]
- Nothing is uploaded. **[invariant]** [§8.3]
