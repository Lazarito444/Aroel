# Sentiment — On-device only

Epic E9 · Milestone M2 · Source: [`../README.md`](../README.md)

### US-901 · Sentiment that never leaves the phone
As a **Writer**, I want the tone of my day derived on-device, used only for the day's sentiment and the highlights, and to notice nothing at all when the platform can't provide it, so that "AI" is a feature I can't detect, not a dependency I pay for. [§8.3]

- No LLM anywhere in v1. ⚠ **[invariant — §1.4, §8.3; every number in the app is arithmetic, never written prose]** [§8.3]
- Implementation: Apple `NaturalLanguage` (iOS) and ML Kit or a bundled small classifier (Android), all behind one `SentimentService` interface. [§8.3]
- Output: a discrete tone for the day, stored as `day_sentiment` with `source = on_device`. Consumed only by the day's sentiment and the highlights (US-603). **[invariant: no other consumer]** [§4.2, §8.3]
- If the platform API is unavailable, the feature degrades to **nothing** and the rest of the app is unchanged. **[invariant — must ship without it]** [§8.3]
- Nothing is uploaded. **[invariant]** [§8.3]
- No sentiment for the analytics arithmetic — averages and directions are plain local arithmetic (US-601/602). [§8.3]
