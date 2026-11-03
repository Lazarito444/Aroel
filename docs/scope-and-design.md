# Aroel — v1 Scope & Design

**Status:** definition · **Date:** 2026-11-03 · **Stage:** pre-build (empty repo)

---

## 1. What Aroel is

A guided introspection app for iOS and Android. Aroel turns journaling into a program
you walk, not a page you face: each day it hands you one short, timed session of one to
three prompts, and free writing exists as the escape hatch rather than the product.

Alongside the session sits a **day record** — a rating, a few tags, three lines of
gratitude — which takes twenty seconds and is worth doing on the days you have no words.

**One-liner:** Aroel turns journaling into a program you walk, not a page you face.

### 1.1 Who it is for

Adults 24–40 who have tried Day One, Journey or plain Notes and fell off within a month.
They do not lack the desire to reflect; they lack a reason to start on any given evening
and a sense of progress when they do. They are mildly anxious rather than clinically ill,
privacy-aware, and willing to pay nothing but unwilling to be advertised to.

### 1.2 The wedge

**Structured programs.** The competitor surface is a blank editor plus a prompt library.
Aroel's surface is a curriculum with a beginning, a middle and an end.

Consequence: the three launch programs are the product. Writing them is real work with a
real cost, and they are the only part of v1 that cannot be outsourced to a framework.

### 1.3 The second hook

The **day record** is the retention mechanism. Programs demand five minutes and a mood; a
rating demands four seconds and no mood at all. A user in a bad week can still close the
day, keep the streak alive, and come back to the program when they have it in them.

It also produces the data that makes the app worth keeping: after six weeks, Aroel knows
what your good days have in common.

### 1.4 Anti-goals

- Not a social network. No feeds, no sharing, no followers, ever in v1.
- Not a therapy or clinical product. No diagnoses, no claims, no crisis triage.
- Not an AI chat companion. No LLM in v1; see §8.3.
- Not a notes app. Rich embeds, tables, attachments beyond photos and audio are out.

---

## 2. The loops

### 2.1 Daily loop (the core)

```
Today  →  session card  →  prompt 1  →  write  →  prompt 2  →  write
       →  mood after         →  completion  →  back to Today (streak +1)
```

Target: 90 seconds to open and start, 5 minutes to finish. Resumable from any point,
offline, no data loss.

### 2.2 Day close (the four-second loop)

```
Today  →  rate the day (0–5, half steps)  →  tap a few tags  →  three small things
```

Available from Today at any hour, not gated behind the session. Once a day has a rating it
appears in history immediately; editing is allowed, and the last write wins.

### 2.3 Forgiving streak

A day counts if **any** of these happened: a session completed, a free entry, a rating, or
a gratitude line. A single missed day costs one grace token instead of resetting. Two
consecutive missed days reset. Never shown with guilt copy.

### 2.4 Weekly loop

Sunday evening: a reflection card on Today assembled deterministically from the week's data
— rating average and direction, most-frequent tags, days kept, the entry the user returned
to most, and one prompt aimed at the week's least-explored emotion. Templates plus numbers
only; no model writes prose.

### 2.5 Program loop

Enrollment → day N → session complete → day N+1 unlocked. Days are calendar days, not
completion-gated: a user who skips day 3 opens day 5 later and is offered a one-line
"catch-up" note rather than a backlog.

---

## 3. Scope

| Area | v1 | Later |
|---|---|---|
| Programs | 3 hand-written: *Begin* (7 days), *Untangle* (30 days), *Gratitude* (14 days, seeded from the day record) | 20+ programs, authoring CMS |
| Daily session | 1–3 prompts, autosave, resume, mood before/after, progress dots | audio-guided sessions |
| Day record | rating 0–5 in half steps, up to 5 tags, 3 gratitude lines, optional one-line note | energy, sleep, location |
| History | month calendar, day detail, edit any past day | year in review, photo recap |
| Free entry | markdown-lite text, voice dictation, up to 3 photos, tags, pin | handwriting, embeds |
| Momentary mood | optional check-in with an emotion from a fixed taxonomy | activity correlations |
| Insights | rating trend at half-step resolution, weekday pattern, tag-vs-rating comparison, emotion counts, completion %, streak | predictive trends |
| Search | full-text, tag filter, rating filter, works offline | semantic search |
| Reminders | one daily reminder, local notification + push fallback | multiple, adaptive timing |
| Export | Markdown + JSON + PDF, account deletion | scheduled backups |
| AI | on-device sentiment only | — |
| Social | none | — |
| Monetization | none — free, unlimited | — |
| Platforms | iOS 16+, Android 10+ | web reader, watch app |
| Languages | English | ES, DE |

### 3.1 Deliberately out of v1

Widgets, watch complications, HealthKit, weather import, cycle tracking, cloud backup
scheduling, program recommendations, custom programs, community, prompt marketplace, tablet
and landscape layouts, accessibility audit beyond baseline, analytics beyond crash
reporting and opt-in funnel events.

---

## 4. Domain model

Client-generated `uuid7` primary keys everywhere, so offline writes need no renumbering and
merge cleanly. Timestamps are `timestamptz` in UTC; `local_date` (`date`) sits alongside
because a day is a diary concept, not a UTC one — an entry written at 00:30 belongs to the
previous evening in the user's head, and to `local_date`, not to UTC.

### 4.1 The day is the unit

`days` is the spine. One row per user per `local_date`, holding the rating and the gratitude.
Entries, sessions and momentary moods hang off it. Everything the app calls "history" is a
query over `days`, which means no aggregation guesswork and no timezone drift.

### 4.2 Entities

| Entity | Key fields | Notes |
|---|---|---|
| `users` | id, email, display_name, timezone, locale, avatar_url, created_at | one identity per person |
| `identities` | user_id, provider (`password`/`apple`/`google`), subject, secret_hash | argon2id for password |
| `refresh_tokens` | id, user_id, token_hash, device_id, expires_at, rotated_from | rotation + reuse detection |
| `programs` | id, slug, title, subtitle, description, duration_days, theme, cover_url, version | seeded, read-only to clients |
| `program_days` | id, program_id, day_number, title, estimated_minutes | one row per program day |
| `prompts` | id, program_day_id, position, type, text, helper, max_chars | types: free, list, scale, choose, letter |
| `enrollments` | id, user_id, program_id, started_at, current_day, status, completed_at | status: active/paused/completed/abandoned |
| `session_runs` | id, enrollment_id, day_number, started_at, completed_at, entry_id | one per attempted day |
| `days` | id, user_id, local_date, rating_half, note, rated_at, created_at, updated_at | **one per user per date**, unique (user_id, local_date) |
| `day_tags` | day_id, tag_id | context: work, family, exercise, poor sleep |
| `gratitude_items` | id, day_id, position (1–3), text | short, ≤ 140 chars each |
| `entries` | id, user_id, day_id, kind, title, body_md, created_at, updated_at, word_count, pinned, session_run_id, deleted_at | kind: session/free/mood_only |
| `moods` | id, user_id, day_id, rating_half, emotion_id, recorded_at | momentary check-in, same 0–10 half-point domain as the day rating |
| `emotions` | id, slug, label, family, valence_bias | seeded taxonomy, ~60 rows |
| `entry_emotions` | entry_id, emotion_id | many-to-many |
| `tags` | id, user_id, label, color, applies_to | `applies_to` in (day, entry, both) |
| `entry_tags` | entry_id, tag_id | many-to-many |
| `entry_links` | source_entry_id, target_entry_id | backlinks, resolved from `[[...]]` |
| `media` | id, entry_id, kind (photo/audio), storage_key, width, height, duration_ms, bytes | S3 keys, signed URLs |
| `reminders` | id, user_id, time_local, days_of_week, timezone, enabled, last_fired_at | v1: exactly one |
| `devices` | id, user_id, platform, push_token, app_version, last_seen_at | |

### 4.3 Rating representation

Half steps are stored as an integer count of half points, `rating_half` in `0..10` — eleven
values (0.0 → `0`, 2.5 → `5`, 3.5 → `7`, 5.0 → `10`). Never a float, never a decimal
string: floats make `where rating = 3.5` unreliable and JSON round-trips of `3.5` invite
`3.4999`. The client converts at the presentation boundary only.

`rating_half` is nullable, and on a 0-based scale that matters more than it would on 1–5:
**`0` is a real score for a real day**, so "not rated" cannot be encoded as zero. Absence is
`NULL` in the column, an omitted field in the API rather than a `0`, and a `paper.sunk` cell
in the calendar — never the ramp's bottom step.

### 4.4 DDL sketch (the parts that carry risk)

```sql
create table days (
  id           uuid primary key,
  user_id      uuid not null references users,
  local_date   date not null,
  rating_half  smallint check (rating_half between 0 and 10),
  note         text,
  rated_at     timestamptz,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  sync_seq     bigint not null default nextval('sync_seq'),
  unique (user_id, local_date)
);
create index days_user_date on days (user_id, local_date desc);

create table gratitude_items (
  id        uuid primary key,
  day_id    uuid not null references days on delete cascade,
  position  smallint not null check (position between 1 and 3),
  text      text not null check (length(text) between 1 and 140),
  unique (day_id, position)
);

create table entries (
  id             uuid primary key,
  user_id        uuid not null references users,
  day_id         uuid not null references days,
  kind           text not null check (kind in ('session','free','mood_only')),
  title          text,
  body_md        text not null default '',
  word_count     int  not null default 0,
  pinned         boolean not null default false,
  session_run_id uuid references session_runs,
  search         tsvector generated always as
                   (to_tsvector('english', coalesce(title,'') || ' ' || body_md)) stored,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  sync_seq       bigint not null default nextval('sync_seq')
);
create index entries_user_date on entries (user_id, created_at desc) where deleted_at is null;
create index entries_search on entries using gin (search);

-- Server-assigned monotonic cursor, added to every syncable table.
create sequence sync_seq;
```

`sync_seq` (rather than `updated_at` alone) is what makes delta sync correct: it survives
clock skew and never misses a row written in the same millisecond as the pull.

### 4.5 Rating semantics

The scale is anchored in copy, not in the user's imagination:

| Value | Label | Anchor copy |
|---|---|---|
| 0.0–0.5 | bottom | "A day I'd rather not repeat." |
| 1.0–1.5 | hard | "It cost me something." |
| 2.0 | off | "Below an ordinary day." |
| 2.5 | ordinary | "Neither good nor bad. A day." |
| 3.0–3.5 | okay | "Fine. A little better than a day." |
| 4.0–4.5 | good | "I'd take another one like it." |
| 5.0 | one of the best | "One of the good ones." |

The neutral point is 2.5, not 3, because eleven stops put the middle between 2.5 and 3 and
people anchor on the middle. Leaving it implicit would produce a dataset where everyone
"averages 3.6" and means nothing by it. The anchors are shown on first use, on long-press,
and in the accessibility label of the control.

### 4.6 Emotion taxonomy

Eight families derived from Plutchik, trimmed to what people actually write: **joy, trust,
calm, sadness, fear, anger, shame, surprise**. Each holds 6–9 concrete labels (`grateful`,
`relieved`, `content`; `anxious`, `dread`, `insecure`; `irritated`, `resentful`, `furious`).
Seeded with stable slugs so analytics stay comparable across releases.

---

## 5. Screens

Fourteen surfaces. Brackets are v1 acceptance criteria.

### 5.1 Auth

Email + password, Sign in with Apple, Sign in with Google. Provider buttons above an
"or use email" disclosure. Password minimum 10 characters, no composition rules. Email
verification is required before the first sync but not before writing — the app is usable
offline immediately. [Sign-in completes in ≤ 2 taps for Apple/Google.]

### 5.2 Onboarding (3 steps, skippable after step 1)

1. **Intent** — "What brings you here?" (understand myself / slow down / work through
   something / build a habit). Sets the default program and the tone of day-1 copy.
2. **First program** — one recommended program pre-selected; alternatives behind "see other
   programs".
3. **Reminder** — time picker defaulting to 21:00 in the device timezone, with a clear
   "not now".

Step 2 also plants the first rating with a scale-anchor explanation, so the gesture is
learned before it matters. [Completes in < 60 s. No account required until first sync.]

### 5.3 Today (home)

- Date eyebrow, greeting, streak chip with grace indicator.
- **Session card** (hero): program · day N of M, prompt-derived title, duration, progress
  bar, single primary action.
- **Rate today**: eleven half-step stops along a hairline track, current value named
  (`4.0 · good`), anchors "bottom" and "good day" at the ends. One tap sets it, second tap
  on the same value clears it.
- **Tag row**: the five most recently used day tags plus a `+` that opens a sheet with
  suggestions and free text.
- **Three small things**: three lines, each optional, each autosaved on blur and on every
  keystroke pause. A filled line collapses to a single serif line with a small tick.
- Recent: the two most recent entries.
- No banners, no upsells, no notification badges.

[Every element interactive before sync completes; whole screen hydrates from SQLite in
< 150 ms; rating persists and re-renders in < 30 ms after tap.]

### 5.4 Program detail

Cover, description, day list with completion ticks, progress, pause/leave. Enrolling is one
tap and starts at day 1 immediately; no scheduled start date.

### 5.5 Session run

Full-screen, one prompt per page, no chrome except close, progress dots and prompt counter.
Autosave every keystroke to local SQLite, debounced flush every 2 s. Back navigation keeps
text. At the last prompt: mood-after check-in, then a completion screen with the streak
increment and a single "Read what you wrote" link. [Nothing typed is ever lost across app
kill, airplane mode, or backgrounding.]

The session writes into the day it was started on, and completion offers one tap to rate
that day if it is still unrated.

### 5.6 Editor (free entry)

Markdown-lite (bold, italic, headings, lists, quotes), `[[` autocomplete for entry links,
tag chips below the body, photo attach, dictate. Autosave as above. [Save-to-visible
latency < 16 ms; entry readable offline forever.]

### 5.7 Entry read

Serif typography on paper, metadata footer (date, program day, emotions, tags), backlinks
list, edit and delete. Delete is soft for 30 days.

### 5.8 Timeline

Reverse-chronological, grouped by month. Each month header shows entries written, days kept
and the month's rating average. Filter chips for program / tag / rating range. Virtualised,
no pagination gap.

### 5.9 Search

Single field, offline FTS5 on device and Postgres FTS when available; tag and rating
filters; jump to the matched paragraph. The index covers entry bodies, day notes and
gratitude lines, so "that thing about the balcony" is findable even though it was never an
entry.

### 5.10 Insights

Two modes on one screen, switched by a segmented control.

**Calendar (default).** Month grid, one cell per date, filled from the rating ramp
(§6.6). Unrated days are paper-sunk with a faint numeral. Rated days with an entry carry a
2 px dot in the cell's corner. Tap opens the day detail. Month header shows average,
days rated, and the best day. Swipe or arrows move between months; a year strip sits under
the grid for fast travel.

**Trends.** Rating line over 7 days / 30 days / year with half-step resolution; average and
direction; entries count; streak; emotion frequency bars; weekday pattern. Then, once at
least five tagged days exist in each group, **tag comparison** — "days tagged exercise
average 4.2, other days 3.1" — computed locally with an explicit sample-size guard.

Every chart derives from local data, so it renders offline. Empty states teach; they never
scold.

### 5.11 Day detail

The record of one date: rating control, day tags editable, gratitude lines editable, the
session run if any, entries from that day, and a one-line note. Reachable from the
calendar, from a timeline group header, and from an entry's metadata. Future dates are
read-only-empty, never editable.

### 5.12 On this day

Entries from one year ago and one month ago, surfaced inside Insights and at the foot of
Day detail. Never on Today, so it never competes with the session.

### 5.13 Export

One screen: Markdown, JSON, PDF. JSON is the lossless one and says so. Export includes day
records, ratings, tags and gratitude — not just entries.

### 5.14 Settings

Account (email, password, sign out, delete account), reminder, appearance (light/dark/
system), export, privacy summary, licences, version. Delete account is two steps, wipes
server data within 24 h and local data immediately, and states this plainly.

---

## 6. Design system — Warm Paper

### 6.1 Palette

| Token | Light | Dark | Use |
|---|---|---|---|
| `paper` | `#F6F1E7` | `#14110E` | app ground |
| `paper.raised` | `#FFFBF3` | `#1E1A15` | cards, sheets |
| `paper.sunk` | `#EDE5D6` | `#0E0C09` | inputs, chips, wells |
| `ink` | `#241C15` | `#EFE6D8` | primary text |
| `ink.soft` | `#5B5147` | `#B9AD9C` | secondary text |
| `ink.faint` | `#8C8175` | `#8A7F71` | meta, placeholders |
| `accent` | `#7A4E2D` | `#C98B5A` | primary actions, links |
| `seal` | `#A6402F` | `#D96A55` | destructive, hard days |
| `sage` | `#6E7B5B` | `#8E9C78` | success, calm, good days |
| `amber` | `#C08A2E` | `#D9A64B` | warning, mid mood |
| `border` | `#E2D8C6` | `#2A241D` | hairline dividers |

Contrast: `ink` on `paper` 13.4:1, `ink.soft` on `paper` 6.1:1, `accent` on `paper` 5.9:1.
All pass AA.

### 6.2 Typography

- **Newsreader** — display, headings, and everything the user wrote. The voice of the
  product.
- **Inter** — UI chrome, labels, buttons, metadata. Never for the user's own prose.

| Role | Font | Size / line | Weight |
|---|---|---|---|
| Display (greeting) | Newsreader | 28 / 32 | 400 |
| Page title | Newsreader | 22 / 28 | 500 |
| Entry body | Newsreader | 17 / 28 | 400 |
| Prompt | Newsreader | 20 / 30 | 400 |
| UI body | Inter | 14 / 20 | 400 |
| Label | Inter | 11 / 16, +0.06em | 500, uppercase |
| Caption | Inter | 11 / 16 | 400 |

### 6.3 Form

- Spacing 4 / 8 / 12 / 16 / 24 / 32 / 48. Nothing between.
- Radii: 8 chips, 12 inputs, 16 cards, 24 sheets, 999 pills.
- Elevation: `e1 0 1px 2px rgba(60,40,20,.06)`, `e2 0 8px 24px rgba(60,40,20,.08)`,
  sheet `0 -8px 32px rgba(60,40,20,.10)`. Warm-tinted, never neutral grey.
- Texture: 3 %-opacity paper grain on grounds; one hairline `border` on cards. No gradients
  except the chart area fill and the rating ramp itself.
- Icons: 1.5 px stroke, 24 px grid, rounded caps.

### 6.4 Motion

120 ms for presses (scale .98), 220 ms ease-out for sheets and card expansion, 320 ms for
page pushes. Light haptic on rating tap, session completion and gratitude save; never on
navigation. Reduce-motion honours `MediaQuery.disableAnimations` and drops to opacity fades.

### 6.5 Voice and copy

Second person, plain, unhurried. No exclamation marks, no streak guilt, no "Oops!". Panic
states say what happened and what is safe: *"You're offline. Everything you write is saved
here and will sync when you're back."*

### 6.6 Rating control and ramp

**Control.** A hairline track 1 px in `border` spanning the content width, with eleven stops
of 7 px in `ink.faint`. The selected stop becomes 20 px, filled with the ramp colour at that
value, ringed in `paper`. Labels sit at the ends only — "bottom" left, "good day" right —
plus the current value named in Inter 11 on the trailing edge. Each stop's hit target is its
full 1/11 segment of the track (≈ 30 pt on a 390 pt phone), which is why the stops are
spaced, not clustered; under 320 dp of width the control degrades to a 44 pt slider with
eleven detents.

**Ramp.** Diverging around 2.5, in-palette, so a bad week reads as warm rather than as an
error state. Neutral at the middle is deliberate: it is where "an ordinary day" lands.

| Rating | 0.0 | 0.5 | 1.0 | 1.5 | 2.0 | 2.5 | 3.0 | 3.5 | 4.0 | 4.5 | 5.0 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Hex | `#9E3B2B` | `#A95B41` | `#B77A5A` | `#C29675` | `#CDB098` | `#D8CDB8` | `#C4C3A6` | `#B0B996` | `#9AA382` | `#84906F` | `#6E7B5B` |

Numerals use `paper` only on the two darkest warm steps (0.0–0.5) and `ink` from 1.0 up,
because the middle of the ramp is far too light for white type. The ramp is the only
place in the app where colour encodes meaning, which is why it stays inside the palette
instead of importing a rainbow.

---

## 7. Architecture

### 7.1 Client — Flutter

```
lib/
  app/            router, theme, bootstrap, DI
  core/           result types, errors, clock, ids, analytics facade
  data/           drift database, api client, sync engine, repositories
  features/
    auth/ onboarding/ today/ programs/ session/ editor/
    journal/ history/ insights/ settings/
  ui/             design-system widgets (Paper, Card, Button, Sheet, RatingTrack, DayGrid)
```

Riverpod for state, `go_router` for navigation, `drift` (SQLite) as the local source of
truth, `freezed` for models, `dio` + `retrofit` for HTTP. Feature-first; no cross-feature
imports outside `ui/` and `core/`.

Offline-first rule: **every read comes from SQLite, every write goes to SQLite first.** The
network is a sync process, never a dependency of an interaction.

### 7.2 Server — .NET 9

Minimal APIs in vertical slices, EF Core + Npgsql, one project, folders per endpoint group.
Argon2id (`Konscious.Security.Cryptography`) for passwords, own OIDC validation for Apple
and Google, JWT access 15 min + rotating refresh 60 days with reuse detection.

```
POST   /auth/register | /auth/login | /auth/oauth | /auth/refresh | /auth/logout
GET    /me          PATCH /me          DELETE /me
GET    /programs    GET /programs/{slug}
POST   /enrollments  GET /enrollments/active  PATCH /enrollments/{id}
GET    /days?from=&to=          PATCH /days/{localDate}
GET    /sync?since={cursor}     POST /sync/batch
GET    /search?q=&tags=&rating= GET /insights?from=&to=
POST   /media/upload-url        GET /media/{id}
GET    /export?format=md|json|pdf
```

Rate limits: 5/min auth, 60/min sync, 30/min search. OpenAPI generated, versioned `/v1`.

### 7.3 Sync

1. Client flushes local dirty rows to `POST /sync/batch` (upserts keyed by `uuid7`, deletes
   as tombstones).
2. Server applies last-write-wins per row by `updated_at`, bumps `sync_seq`, returns the new
   rows.
3. Client pulls `GET /sync?since=cursor` and merges; cursor stored locally.

Single-user, multi-device means real conflicts are rare and LWW is acceptable. Program and
prompt content is server-owned and pulled as versioned read-only data.

Rating edits are ordinary upserts on `days`, so rating the same evening on phone and tablet
settles to the later write without any special casing.

### 7.4 Reminders

Client schedules a local notification at the chosen local time — reliable, no server
dependency. The server keeps the reminder and sends a push only if the device has not
opened the app for 24 h, from a small worker bucketing users by timezone into 15-minute
slots.

### 7.5 Storage

S3-compatible bucket for photos and audio, keys `u/{user_id}/e/{entry_id}/{media_id}`,
short-lived signed URLs, 1 GB soft quota per user.

---

## 8. Privacy and security

### 8.1 Promises the app makes

- No advertising SDKs; no third-party analytics beyond crash reports and opt-in funnel
  events.
- Staff cannot read entry bodies, ratings or gratitude. Support has no such tool.
- Export is one tap and lossless. Leaving is one flow.
- Server-side encryption at rest (Postgres + bucket), TLS 1.3 in transit.

### 8.2 Security baseline

Argon2id hashing, refresh-token rotation with reuse detection, strict CORS, no secrets in
the client, per-user row isolation enforced in queries, rate limits on auth, soft-delete
with 30-day purge, account deletion that actually deletes.

### 8.3 On-device AI, precisely

No LLM. On-device sentiment runs on Apple `NaturalLanguage` (iOS) and ML Kit or a bundled
small classifier (Android) behind one `SentimentService` interface, producing a discrete
tone per entry used only for the weekly card and emotion suggestions. If the platform API
is unavailable the feature degrades to nothing and the app is unchanged. Nothing is
uploaded.

Tag-vs-rating comparisons, weekday averages and streaks involve no model at all — they are
arithmetic over local rows, computed on device, and therefore work offline and free.

---

## 9. Milestones

| # | Milestone | Done when |
|---|---|---|
| M0 | Foundation | Flutter shell, paper theme, drift schema, .NET skeleton, Postgres migrations, CI |
| M1 | Identity | email + Apple + Google, refresh rotation, onboarding, reminder scheduling |
| M2 | Core loop | 1 program seeded, enrollment, session run, autosave, resume, streak |
| M3 | Day record | rating control + ramp, day tags, gratitude, day detail, calendar history |
| M4 | Capture | free editor, entry read, timeline with month summaries, photos |
| M5 | Find | offline FTS, search, filters, insights trends, tag comparison |
| M6 | Trust | export (md/json/pdf), account deletion, privacy screens, offline UX, error states |
| M7 | Ship | 3 programs written and edited, on-device sentiment, store listings, TestFlight + Play internal |

M2 is the go/no-go for the wedge; M3 is the go/no-go for retention. If rating a day does not
feel like something you would do unprompted for a week, the rest does not matter.

---

## 10. Open questions

1. **Program authorship.** Three programs of publishable quality is roughly 60 sessions of
   writing. Are you writing them, commissioning them, or licensing content?
2. **Scale shape.** This spec treats 0 as the worst day and 5 as one of the best, with the
   neutral point at 2.5. Confirm the direction, because flipping it later invalidates every
   chart, every anchor and every export. Confirm too that 0 is in the range at all — a
   scale that starts at 1 never lets anyone record the day that actually mattered.
3. **Rating editability.** v1 lets you re-rate any past day. The alternative — rating locks
   at midnight — produces cleaner data and a more honest record, at the cost of the person
   who forgot at 23:50. Current choice optimises for forgiveness.
4. **Voice capture.** Platform dictation (free, inconsistent) versus a transcription vendor
   (cost, and it breaks "nothing leaves the device" unless on-device).
5. **Name.** "Aroel" reads well; check trademark and App Store availability before logo work.
6. **Store risk.** Journaling with mood tracking sits near the "medical" line. Copy must
   avoid diagnosis language from day one.
7. **Free forever.** Fine while you fund hosting; decide now whether it is permanent, because
   a later paywall on an explicitly free product costs trust.
