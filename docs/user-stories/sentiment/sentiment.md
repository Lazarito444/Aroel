# Sentiment — On-device only

Epic E9 · Milestone M7 · Source: [`../README.md`](../README.md)

### US-901 · Sentiment that never leaves the phone
As a **Writer**, I want entry tone derived on-device, used only for my weekly card and emotion suggestions, and to notice nothing at all when the platform can't provide it, so that "AI" is a feature I can't detect, not a dependency I pay for. [§8.3]

- No LLM anywhere in v1. ⚠ **[invariant — §1.4, §8.3; the weekly card and any prose are templates + numbers]** [§8.3]
- Implementation: Apple `NaturalLanguage` (iOS) and ML Kit or a bundled small classifier (Android), all behind one `SentimentService` interface. [§8.3]
- Output: a discrete tone per entry. Consumed only by the weekly reflection card ([`../find/weekly-reflection.md`](../find/weekly-reflection.md)) and emotion suggestions. **[invariant: no other consumer]** [§8.3]
- If the platform API is unavailable, the feature degrades to **nothing** and the rest of the app is unchanged. **[invariant — must ship without it]** [§8.3]
- Nothing is uploaded. **[invariant]** [§8.3]
- No sentiment for trend arithmetic — comparisons are plain local arithmetic (US-604), and it is not a factor in any other story. [§8.3]
