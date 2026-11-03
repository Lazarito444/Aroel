# Aroel — v1 User Stories

**Status:** definition · **Date:** 2026-11-03 · **Source:** [`../scope-and-design.md`](../scope-and-design.md) — section references appear on each criterion; ⚠ marks invariants nobody may paraphrase away. Actor: **Writer** (app user).

Structure: one folder per module (mirrors `lib/features` in §7.1), one file per feat. New stories go in the module's folder; cross-cutting ones in `platform/`.

| Module | Feat files | Stories | Milestone |
|---|---|---|---|
| [auth/](auth/) | [signin](auth/signin.md) · [onboarding](auth/onboarding.md) · [account](auth/account.md) | US-101…106 | M1 |
| [today/](today/) | [home](today/home.md) · [rating](today/rating.md) · [tags](today/tags.md) · [gratitude](today/gratitude.md) | US-201…205 | M2–M3 |
| [programs/](programs/) | [catalog](programs/catalog.md) · [session](programs/session.md) | US-301…306 | M2 |
| [journal/](journal/) | [day-record](journal/day-record.md) · [editor](journal/editor.md) · [entry-read](journal/entry-read.md) · [momentary-mood](journal/momentary-mood.md) · [timeline](journal/timeline.md) | US-401…404, US-501…504 | M3–M4 |
| [find/](find/) | [search](find/search.md) · [calendar](find/calendar.md) · [trends](find/trends.md) · [weekly-reflection](find/weekly-reflection.md) | US-601…605 | M3–M5 |
| [trust/](trust/) | [export](trust/export.md) · [privacy](trust/privacy.md) · [voice](trust/voice.md) | US-701…703 | M6 |
| [platform/](platform/) | [offline-sync](platform/offline-sync.md) · [reminders](platform/reminders.md) | US-801…803 | M1–M2, cross-cutting |
| [sentiment/](sentiment/) | [sentiment](sentiment/sentiment.md) | US-901 | M7 |

Out of scope, per §1.4 and §3.1: social features, LLM, paywall, widgets, custom programs, tablet/landscape layouts. No story depends on any of them.

---

## Invariants that belong to tests, not tickets

These have no user-facing story because no user asked for them; they are what every story silently assumes. Each needs a regression test, not only an implementation:

| Invariant | From |
|---|---|
| `rating_half` is smallint 0–10; 0 = "A day I'd rather not repeat."; unrated = NULL/omitted | §4.3, AGENTS.md |
| Two time coordinates per record (`timestamptz` UTC + `local_date`); `days` is the spine | §4, AGENTS.md |
| Primary keys client-generated `uuid7` | §4, AGENTS.md |
| `sync_seq` cursor drives delta sync; LWW per row by `updated_at` | §7.3, AGENTS.md |
| Offline-first: reads from SQLite, writes to SQLite first | §7.1 |
| Autosave per keystroke, 2 s debounced flush; nothing typed is lost | §5.5, AGENTS.md |
| No LLM, no social, no ad SDK, no paywall in v1 | §1.4, §3, §8.3 |
| Newsreader for prose, Inter for chrome; never Inter in prose | §6.2 |
| Ramp + anchors hex values and copy are literal spec; diverges at 2.5 | §6.6 |
| Spacing 4/8/12/16/24/32/48; radii 8/12/16/24/999; motion 120/220/320 ms | §6.3, §6.4 |
| Copy: second person, no exclamations, no streak guilt, no diagnosis language | §6.5, §10.6 |
| Tag-comparison sample guard ≥ 5 per group is hardcoded | §5.10 |
| Export is lossless and includes days/ratings/tags/gratitude | §5.13 |
| Deletion actually deletes (server ≤ 24 h, local immediate) | §5.14, §8.2 |

## Open questions this doc inherits (do not resolve silently)

The stories assume the doc's current stance. If development flips any, it breaks the story, and the scope doc must be updated in the same commit: scale direction and the 0 point (US-402/403), rating editability (US-401), voice capture vendor vs. dictation (US-501), program authorship (US-301 content), "free forever" promise (US-701/702 copy). See §10.
