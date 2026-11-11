# Aroel — v1 User Stories

**Status:** definition · **Date:** 2026-11-11 · **Source: [`../scope-and-design.md`](../scope-and-design.md) — section references appear on each criterion; ⚠ marks invariants nobody may paraphrase away. Actor: **Writer** (app user).

Structure: one folder per module (mirrors `lib/features` in §7.1), one file per feat. New stories go in the module's folder; cross-cutting ones in `platform/`.

| Module | Feat files | Stories | Milestone |
|---|---|---|---|
| [auth/](auth/) | [signin](auth/signin.md) · [onboarding](auth/onboarding.md) · [account](auth/account.md) | US-101…106 | M1 |
| [today/](today/) | [home](today/home.md) · [rating](today/rating.md) · [tags](today/tags.md) · [gratitude](today/gratitude.md) · [sentiment](today/sentiment.md) · [streak](today/streak.md) | US-201…207 | M2 |
| [journal/](journal/) | [day-record](journal/day-record.md) · [editor](journal/editor.md) · [entry-read](journal/entry-read.md) | US-401…404, US-501…502 | M2 |
| [notes/](notes/) | [notes](notes/notes.md) | US-505 | M3 |
| [insights/](insights/) | [weekly](insights/weekly.md) · [monthly](insights/monthly.md) · [highlights](insights/highlights.md) | US-601…603 | M4 |
| [platform/](platform/) | [offline-sync](platform/offline-sync.md) | US-801…802 | M1–M2, cross-cutting |
| [sentiment/](sentiment/) | [sentiment](sentiment/sentiment.md) | US-901 | M2 |

26 stories across 7 modules.

**Retired stories.** IDs are not stable across revisions of the scope doc — do not reuse a
retired ID.

| Retired | Was | When |
|---|---|---|
| US-301…306 | program catalog, enrollment, session run | 2026-11-11, guided programs removed |
| US-503, US-504 | momentary mood, timeline | 2026-11-11, v1 trimmed to six things |
| US-601…605 | search, calendar, trends, tag comparison, weekly reflection | 2026-11-11 — the band is now the insights module (US-601 weekly, US-602 monthly, US-603 highlights) |
| US-701…703 | export, privacy summary, voice/copy | 2026-11-11, deferred to later |
| US-803 | reminders | 2026-11-11, deferred to later |

Do not reintroduce a deferred feature without updating the scope doc in the same commit.

Out of scope, per §1.4 and §3.1: social features, LLM, paywall, widgets, guided programs and
sessions, search, export, photos and audio, reminders, tablet/landscape layouts. No story
depends on any of them.

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
| Autosave per keystroke, 2 s debounced flush; nothing typed is lost | §5.4, AGENTS.md |
| **The account is optional; local-only is the default, never a degraded mode** | §5.1, §4.2 |
| Signing up adopts the local journal without re-keying a single row | §4.2 |
| No LLM, no social, no ad SDK, no paywall in v1 | §1.4, §3, §8.3 |
| Every analytics number is local arithmetic; no model writes a number or a sentence | §7.4, §8.3 |
| No guided programs, sessions or enrollments in v1 | §1.2, §1.4, §3.1 |
| The streak forgives one missed day and can be recovered by hand; notes never count | §2.3, §2.6 |
| Newsreader for prose, Inter for chrome; never Inter in prose | §6.2 |
| Ramp + anchors hex values and copy are literal spec; diverges at 2.5 | §6.6 |
| Spacing 4/8/12/16/24/32/48; radii 8/12/16/24/999; motion 120/220/320 ms | §6.3, §6.4 |
| Copy: second person, no exclamations, no streak guilt, no diagnosis language | §6.5, §10.5 |
| Deletion actually deletes (server ≤ 24 h, local immediate) | §5.9, §8.2 |

## Open questions this doc inherits (do not resolve silently)

The stories assume the doc's current stance. If development flips any, it breaks the story, and the scope doc must be updated in the same commit: scale direction and the 0 point (US-402/403), rating editability (US-401), sentiment manual versus computed (US-206), streak recovery rules (US-207), differentiation without a curriculum (§10.7), "free forever" promise (US-105/106 copy). See §10.
