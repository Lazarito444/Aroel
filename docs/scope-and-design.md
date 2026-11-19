# Aroel — v1 Scope & Design

**Status:** definition · **Date:** 2026-11-12 · **Stage:** v1 built (the Flutter client
lives in `mobile/`: onboarding, sign-in, account and deletion of M1; the day record of M2 —
rating, tags, gratitude, per-day writing with autosave, streak with recovery and a
manual tone picker; the notes shelf, the day detail and the entry read view of M3; the
weekly and monthly review screens of M4 — all offline-first from SQLite (schema v3), all
tested). The server lives in `backend/` and serves the account, profile, days, insights
and sync endpoints under `/v1` (register, login, oauth, refresh with rotation and reuse
detection, logout, password, email verification, `GET/PATCH/DELETE /me`, `GET /days`,
`GET /insights`, `GET /sync`, `POST /sync/batch`), with verification-gated sync,
tombstone-based deletes and last-write-wins merge. The client syncs on launch, on sign-in
and on demand from the account screen. On-device classification of the tone and the
store listings of M5 are not there yet. Sentiment is manual only for now; the on-device
classifier of §4.6 remains for M5)

> **Change 2026-11-11 — v1 trimmed to six things.** Account + sync (optional), the day
> record (per-day writing, rating, tags, sentiment, gratitude), notes, a recoverable
> streak, and weekly + monthly analytics. Everything else — guided programs, search,
> export, photos, reminders, timelines, privacy screens — is deferred to "Later" (§3.1).
> Earlier versions of this doc specified a larger product; §10.9 keeps the history.

---

## 1. What Aroel is

A quiet journaling app for iOS and Android. Most days cost four seconds: rate the day,
tap a few tags, name three small things. On the days you have more to say, you write, and
the writing belongs to that day. Notes live outside the calendar, for the things that have
no date.

There is no sign-in wall. The app is complete without an account; create one only if you
want your journal on a second device.

**One-liner:** Aroel is a four-second journal that keeps a record of your days.

### 1.1 Who it is for

Adults 24–40 who have tried Day One, Journey or plain Notes and fell off within a month.
They do not lack the desire to reflect; they lack a reason to open the app on any given
evening and a sense of progress when they do. They are mildly anxious rather than
clinically ill, privacy-aware, and unwilling to be advertised to.

### 1.2 The wedge

**The day record.** The competitor surface is a blank editor plus a streak counter.
Aroel's surface is a structured day: a rating on an anchored eleven-stop scale, a small
vocabulary of context tags, a sentiment value, three optional lines of gratitude, and
whatever you wrote — all hanging off one record per calendar day.

Consequence: the day record is the product, and every screen is a query over it. There is
no curriculum behind it, so the record has to earn the return visit on its own, in four
seconds.

### 1.3 The ritual

**Three small things.** A rating demands four seconds and no mood at all. A user in a bad
week can still close the day, keep the streak alive, and come back to write when they
have it in them.

It also produces the data that makes the app worth keeping: after six weeks, Aroel knows
what your good days have in common — because you tagged them, and the tagging was part
of the four-second close rather than a separate ritual.

### 1.4 Anti-goals

- Not a social network. No feeds, no sharing, no followers, ever in v1.
- Not a therapy or clinical product. No diagnoses, no claims, no crisis triage.
- Not an AI chat companion. No LLM in v1; see §8.3.
- Not a notes app. Rich embeds, tables and attachments are out.
- Not a guided curriculum. No programs, sessions or enrollments in v1.
- Not an account-gated app. No sign-in wall, ever — see §5.1.

---

## 2. The loops

### 2.1 Daily loop (the core)

```
Today  →  rate the day (0–5, half steps)  →  tap a few tags  →  three small things
       →  (optionally) write  →  day closed (streak +1)
```

Target: 4 seconds to close the day, 5 minutes if you also write. Resumable from any
point, offline, no data loss. The rating is the hero of Today; writing is one tap away
and never a gate.

### 2.2 The four-second close

```
rate the day  →  tap a few tags  →  three small things
```

Available from Today at any hour, and never gated behind anything else. Once a day has a
rating it appears in history immediately; editing is allowed, and the last write wins.

### 2.3 Forgiving streak

A day counts if **any** of these happened: a rating, a tag, a gratitude line, or something
written. A single missed day costs one grace token instead of resetting. Two consecutive
missed days reset. Never shown with guilt copy.

**Recovery.** A broken streak can be recovered on purpose: from the streak chip, the user
can mark a missed day as kept. Recovery is free and unlimited, and recovered days are
marked as recovered in the streak view — no shaming, no "you lost it" copy.

**As implemented.** The streak is evaluated lazily against the last day that was kept, so
no nightly job is needed and the answer is the same whenever it is asked for. One missed
day spends the grace token and the streak continues; two missed days in a row break it,
and the fresh streak starts with a fresh token. Whether the token should replenish over
time is still open (§10.8).

### 2.4 Weekly review

Once a week, the Insights screen shows the last seven days as numbers: rating average and
direction against the week before, days rated, entries written, gratitude lines, the most
used tags, sentiment average, and the best day of the week.

### 2.5 Monthly review

The same numbers over the calendar month, with the month as a grid of ramp-coloured cells
and a per-week breakdown inside it.

Both reviews are arithmetic over local rows: no model, no prompt bank, no prose. They
render offline and they never scold an empty week.

### 2.6 The writing loop

**Per-day writing.** Write → the entry attaches to the day you wrote it → tag it if you
want. The day you wrote in is the day you wrote in, even at 00:30.

**Notes.** A note has no date. Write it, pin it, find it in the notes list. Notes do not
touch the streak and do not appear in day analytics — they are the shelf, not the record.

---

## 3. Scope

| Area | v1 | Later |
|---|---|---|
| Account & sync | optional account; local-only by default; email + Apple + Google; delta sync | more providers, sync for shared devices |
| Day record | rating 0–5 in half steps, up to 5 tags, sentiment, 3 gratitude lines, one-line note | energy, sleep, location |
| Per-day writing | markdown-lite text, autosave, resume | photos, audio, dictation, handwriting |
| Notes | plain notes with no date, pinnable | tags and linking on notes |
| Streak | current and longest, one grace token per missed day, manual recovery | freezes, milestones |
| Analytics | weekly and monthly: rating average and direction, days rated, entries, gratitude count, top tags, sentiment average and peaks | year in review, tag-vs-rating comparison, predictions |
| On-device AI | sentiment tone per day | — |
| Social | none | — |
| Monetization | none — free, unlimited | — |
| Platforms | iOS 16+, Android 10+ | web reader, watch app |
| Languages | English | ES, DE |

### 3.1 Deferred to later

Guided programs and sessions; search; export (Markdown, JSON, PDF); photos, audio and
dictation; reminders and push notifications; the timeline and the day archive; "on this
day"; tag-vs-rating comparison; the privacy summary screen; entry links and backlinks;
the weekly reflection card with prose.

Deferred means deferred, not never: each of these was specified in an earlier revision of
this document and the design decisions survive in the git history.

---

## 4. Domain model

Client-generated `uuid7` primary keys everywhere, so offline writes need no renumbering and
merge cleanly. Timestamps are `timestamptz` in UTC; `local_date` (`date`) sits alongside
because a day is a diary concept, not a UTC one — an entry written at 00:30 belongs to the
previous evening in the user's head, and to `local_date`, not to UTC.

### 4.1 The day is the unit

`days` is the spine. One row per user per `local_date`, holding the rating and the gratitude.
Per-day writing and sentiment hang off it. Everything the app calls "history" or
"analytics" is a query over `days`, which means no aggregation guesswork and no timezone
drift. Notes are the one thing that sits outside the spine, by design.

### 4.2 Entities

| Entity | Table | Key fields | Notes |
|---|---|---|---|
| `CoreUser` | `users` | id, display_name, timezone, locale, created_at, updated_at | the journal profile of one person; absent in local-only mode; **no email** — that belongs to the identity row |
| `InfrastructureUser` | `aspnet_users` | id, email, password_hash, security_stamp, … | ASP.NET Core Identity; owns the credential and **shares its key** with the profile |
| — | `aspnet_user_logins`, `aspnet_user_claims`, `aspnet_user_tokens`, `aspnet_roles`, … | | provider links (`apple`, `google`) and the rest of the identity schema, owned by the framework |
| `CoreRefreshToken` | `refresh_tokens` | id, user_id, token_hash, device_id, expires_at, revoked_at, rotated_from_id | rotation + reuse detection |
| `CoreDevice` | `devices` | id, user_id, platform, push_token, app_version, last_seen_at | |
| `CoreDay` | `days` | id, user_id, local_date, rating_half, note, rated_at, created_at, updated_at, sync_seq | **one per user per date**, unique (user_id, local_date) |
| `CoreGratitudeItem` | `gratitude_items` | id, day_id, position (1–3), text, created_at, updated_at, sync_seq | unique (day_id, position) |
| `CoreDayTag` | `day_tags` | id, day_id, tag_id, created_at, updated_at, sync_seq | the link between a day and a tag |
| `CoreDaySentiment` | `day_sentiment` | id, user_id, day_id, rating_half, emotion_id, source, recorded_at, sync_seq | one per day; `source` = manual/on_device |
| `CoreEntry` | `entries` | id, user_id, day_id, kind, title, body_md, word_count, opened_count, last_opened_at, pinned, deleted_at, sync_seq | kind: free/mood_only |
| `CoreNote` | `notes` | id, user_id, title, body_md, word_count, pinned, deleted_at, sync_seq | **no `day_id`** — the shelf |
| `CoreEmotion` | `emotions` | id, slug, label, family, valence_bias | seeded taxonomy, ~60 rows |
| `CoreTag` | `tags` | id, user_id, label, color, sync_seq | context tags for days |
| `CoreStreakState` | `streak_states` | id, user_id, current_streak, longest_streak, grace_remaining, last_kept_date | one row per user |
| `CoreStreakRestoration` | `streak_restorations` | id, user_id, streak_state_id, local_date | days the user chose to recover |

**How the code is shaped.** The domain lives in `Aroel.Core` and knows nothing about
Entity Framework or ASP.NET Core Identity. Every entity is built by a static `Create`
that returns a `Result`, so a rule that cannot be met is a value the caller has to deal
with rather than an exception it can forget; state then changes only through the
behaviour the entity exposes, which is where the invariants live (a day carries at most
five tags and three gratitude lines, a rating is half points, an unrated day is absent
rather than zero). The identity side is the one place where the domain and the framework
meet: `InfrastructureUser` is ASP.NET Core Identity's user, and `CoreUser` is the
journal profile it points at.

**Local-only mode.** The client generates its own `user_id` (uuid7) on first launch and
writes every row under it. Without an account those rows never leave the device. When the
user later creates an account, the client sends that same id as the account's id; the
server rejects an id that is already taken. Signing up therefore never re-keys a single
row, and a phone that has been journalling for a month signs up without a migration.

**Removed with earlier revisions.** `programs`, `program_days`, `prompts`, `enrollments`,
`session_runs`, `media`, `entry_emotions`, `entry_tags`, `entry_links` and `weekly_prompts`
were specified in earlier revisions and are not part of v1.

### 4.3 Rating representation

Half steps are stored as an integer count of half points, `rating_half` in `0..10` — eleven
values (0.0 → `0`, 2.5 → `5`, 3.5 → `7`, 5.0 → `10`). Never a float, never a decimal
string: floats make `where rating = 3.5` unreliable and JSON round-trips of `3.5` invite
`3.4999`. The client converts at the presentation boundary only.

`rating_half` is nullable, and on a 0-based scale that matters more than it would on 1–5:
**`0` is a real score for a real day**, so "not rated" cannot be encoded as zero. Absence is
`NULL` in the column, an omitted field in the API rather than a `0`, and a `paper.sunk` cell
in the calendar — never the ramp's bottom step.

The same domain is used by `day_sentiment.rating_half`, so a day's tone and its rating are
comparable numbers.

### 4.4 DDL (as migrated)

The schema is what `backend/Aroel.Data/Migrations` generates; this is the shape of the
tables that carry risk.

```sql
-- Server-assigned monotonic cursor, shared by every syncable table.
create sequence sync_seq start with 1 increment by 1 no cycle;

create table users (
  id           uuid primary key,
  display_name varchar(120) not null,
  timezone     varchar(64) not null,
  locale       varchar(35) not null,
  created_at   timestamptz not null,
  updated_at   timestamptz not null
);

-- The identity row: ASP.NET Core Identity owns the credential, the journal owns the
-- profile, and the two share a primary key.
create table aspnet_users (
  id           uuid primary key references users (id) on delete cascade,
  email        varchar(256),
  password_hash text,
  -- ... the rest of the identity schema
);

create table days (
  id           uuid primary key,
  user_id      uuid not null references users (id) on delete cascade,
  local_date   date not null,
  rating_half  smallint check (rating_half between 0 and 10),
  note         varchar(280),
  rated_at     timestamptz,
  created_at   timestamptz not null,
  updated_at   timestamptz not null,
  sync_seq     bigint not null default nextval('sync_seq'::regclass),
  unique (user_id, local_date)
);

create table gratitude_items (
  id         uuid primary key,
  day_id     uuid not null references days (id) on delete cascade,
  position   smallint not null check (position between 1 and 3),
  text       varchar(140) not null check (length(text) between 1 and 140),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  sync_seq   bigint not null default nextval('sync_seq'::regclass),
  unique (day_id, position)
);

create table day_tags (
  id         uuid primary key,
  day_id     uuid not null references days (id) on delete cascade,
  tag_id     uuid not null references tags (id) on delete cascade,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  sync_seq   bigint not null default nextval('sync_seq'::regclass),
  unique (day_id, tag_id)
);

create table day_sentiment (
  id           uuid primary key,
  user_id      uuid not null references users (id) on delete cascade,
  day_id       uuid not null references days (id) on delete cascade,
  rating_half  smallint check (rating_half between 0 and 10),
  emotion_id   uuid references emotions (id) on delete set null,
  source       varchar(16) not null check (source in ('manual','on_device')),
  recorded_at  timestamptz not null,
  created_at   timestamptz not null,
  updated_at   timestamptz not null,
  sync_seq     bigint not null default nextval('sync_seq'::regclass),
  unique (user_id, day_id)
);

create table entries (
  id             uuid primary key,
  user_id        uuid not null references users (id) on delete cascade,
  day_id         uuid not null references days (id) on delete cascade,
  kind           varchar(16) not null check (kind in ('free','mood_only')),
  title          varchar(200),
  body_md        text not null default '',
  word_count     int  not null default 0,
  opened_count   int  not null default 0,
  last_opened_at timestamptz,
  pinned         boolean not null default false,
  created_at     timestamptz not null,
  updated_at     timestamptz not null,
  deleted_at     timestamptz,
  sync_seq       bigint not null default nextval('sync_seq'::regclass)
);
create index entries_user_date on entries (user_id, created_at desc) where deleted_at is null;

create table notes (
  id         uuid primary key,
  user_id    uuid not null references users (id) on delete cascade,
  title      varchar(200),
  body_md    text not null default '',
  word_count int  not null default 0,
  pinned     boolean not null default false,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq   bigint not null default nextval('sync_seq'::regclass)
);

create table refresh_tokens (
  id              uuid primary key,
  user_id         uuid not null references users (id) on delete cascade,
  token_hash      varchar(256) not null unique,
  device_id       uuid,
  expires_at      timestamptz not null,
  revoked_at      timestamptz,
  rotated_from_id uuid,
  created_at      timestamptz not null,
  updated_at      timestamptz not null
);

create table streak_states (
  id              uuid primary key,
  user_id         uuid not null unique references users (id) on delete cascade,
  current_streak  int not null default 0,
  longest_streak  int not null default 0,
  grace_remaining int not null default 1,
  last_kept_date  date,
  created_at      timestamptz not null,
  updated_at      timestamptz not null
);

create table streak_restorations (
  id             uuid primary key,
  user_id        uuid not null references users (id) on delete cascade,
  streak_state_id uuid not null references streak_states (id) on delete cascade,
  local_date     date not null,
  created_at     timestamptz not null,
  updated_at     timestamptz not null,
  unique (user_id, local_date)
);
```

`sync_seq` (rather than `updated_at` alone) is what makes delta sync correct: it survives
clock skew and never misses a row written in the same millisecond as the pull. Every
table the client owns carries one — including `gratitude_items` and `day_tags`, because
a gratitude line and a tag are edited after the day is written, and a row without a
cursor is a row a second device never hears about.

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

Nine surfaces. Brackets are v1 acceptance criteria.

### 5.1 Auth (optional, never a wall)

Email + password, Sign in with Apple, Sign in with Google. Provider buttons above an
"or use email" disclosure. Password minimum 8 characters, no composition rules. An email
address belongs to one account. Ten failed sign-ins lock the account for five minutes.

**The app never asks for an account before the user has written something.** Auth lives in
Settings and in the onboarding's third step, where it is offered, not requested. Email
verification is required before the first sync but never before writing — the app is usable
offline immediately. [Sign-in completes in ≤ 2 taps for Apple/Google.]

### 5.2 Onboarding (3 steps, each skippable)

1. **Intent** — "What brings you here?" (understand myself / slow down / work through
   something / build a habit). Sets the tone of the copy around the day record.
2. **First rating** — the eleven-stop scale with its anchors explained, and the first
   rating planted, so the gesture is learned before it matters.
3. **Sync** — an invitation to create an account so the journal can follow you to another
   device, with a clear "not now" that means it.

Every step carries a clear "not now", and the whole flow is skippable. [Completes in
< 60 s. No account required until the user asks for one.]

### 5.3 Today (home)

- Date eyebrow, greeting, streak chip with the grace indicator and the recovery action.
- **Rate today** (hero): eleven half-step stops along a hairline track, current value named
  (`4.0 · good`), anchors "bottom" and "good day" at the ends. One tap sets it, second tap
  on the same value clears it.
- **Tag row**: the five most recently used day tags plus a `+` that opens a sheet with
  suggestions and free text.
- **Three small things**: three lines, each optional, each autosaved on blur and on every
  keystroke pause. A filled line collapses to a single serif line with a small tick.
- **Sentiment**: the day's tone, set by hand or derived from what you wrote.
- **Write**: one action that opens the editor on today's record. An invitation, not a hero.
- **Notes**: one action that opens a note with no date.
- Recent: the two most recent entries.
- No banners, no upsells, no notification badges.

[Every element interactive before sync completes; whole screen hydrates from SQLite in
< 150 ms; rating persists and re-renders in < 30 ms after tap.]

### 5.4 Editor (per-day writing)

Markdown-lite (bold, italic, headings, lists, quotes). Autosave every keystroke to local
SQLite with a 2 s debounced flush; back navigation keeps text. The entry attaches to the
day it was written on — an entry started at 23:57 belongs to that evening. [Save-to-visible
latency < 16 ms; nothing typed is lost across app kill, airplane mode, or backgrounding;
entry readable offline forever.]

### 5.5 Entry read

Serif typography on paper, metadata footer (date, sentiment, tags), edit and delete. Delete
is soft for 30 days, then purged. Pinned entries float to the top.

### 5.6 Notes

A list of notes, newest first, with pinned notes first. One editor, no date field by
design — a note is for the things that have no date. Notes are excluded from day
analytics and from the streak.

### 5.7 Day detail

The record of one date: rating control, day tags editable, gratitude lines editable, the
day's sentiment, the entries from that day, and a one-line note. Reachable from the
monthly grid and from an entry's metadata. Future dates are read-only-empty, never
editable.

### 5.8 Insights (weekly & monthly)

One screen, two windows, switched by a segmented control.

**Weekly.** The last seven days as numbers: rating average and direction against the week
before, days rated, entries written, gratitude lines, most-used tags, sentiment average,
and the best day of the week.

**Monthly.** The calendar month as a grid of ramp-coloured cells (§6.6), with the same
numbers over the month, a per-week breakdown inside it, the best day of the month, and the
highest-sentiment day — the month in its best light — with the entry that earned it.

Every number is arithmetic over local rows, so the screen renders offline. Empty states
teach; they never scold.

### 5.9 Settings

Account (create, sign in, email, password change, sign out, delete account), sync status,
streak (current, longest, recovered days), appearance (light/dark/system), licences,
version. Delete account is two steps, wipes server data within 24 h and local data
immediately, and states this plainly.

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
| Note body | Newsreader | 17 / 28 | 400 |
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
page pushes. Light haptic on rating tap, gratitude save and entry save; never on
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
    auth/ onboarding/ today/ journal/ notes/ insights/ settings/
  ui/             design-system widgets (Paper, Card, Button, Sheet, RatingTrack, DayGrid)
```

Riverpod for state, `go_router` for navigation, `drift` (SQLite) as the local source of
truth, `freezed` for models, `dio` + `retrofit` for HTTP. Feature-first; no cross-feature
imports outside `ui/` and `core/`.

Offline-first rule: **every read comes from SQLite, every write goes to SQLite first.** The
network is a sync process, never a dependency of an interaction. This is also what makes
the account optional: the same code path serves local-only and synced users, and the only
difference is whether a sync engine is attached.

### 7.2 Server — .NET 11

Minimal APIs in vertical slices, EF Core + Npgsql, one project, folders per endpoint group.
C# 15. PBKDF2 for passwords, which is the ASP.NET Core Identity default and needs no
third-party hasher; own OIDC validation for Apple and Google, JWT access 15 min + rotating
refresh 60 days with reuse detection.

```
POST   /auth/register | /auth/login | /auth/oauth | /auth/refresh | /auth/logout
POST   /auth/password | /auth/email-verification
GET    /me          PATCH /me          DELETE /me
GET    /days?from=&to=          PATCH /days/{localDate}
GET    /sync?since={cursor}     POST /sync/batch
GET    /insights?window=week|month&from=&to=
```

Rate limits: 5/min auth, 60/min sync, 30/min insights. OpenAPI generated, versioned `/v1`.

**What the client sends.** `POST /auth/register` carries the identifier the device already
writes its rows under (`userId`), so the account adopts the journal on the device and not
one row is re-keyed; the server rejects an identifier that is taken. `POST /auth/oauth`
carries the provider, the provider's token and the same `userId`. `POST /auth/password`
changes the password of the signed-in account, and `POST /auth/email-verification` sends
the verification email again; both are needed by §5.9 and are not implied by the list
above. Errors answer with a code — `email.invalid`, `auth.email_taken`,
`auth.invalid_credentials`, `auth.account_locked`, `auth.rate_limited`,
`refresh_token.reused` — and the client turns the code into a sentence.

### 7.3 Sync

1. Client flushes local dirty rows to `POST /sync/batch` (upserts keyed by `uuid7`, deletes
   as tombstones).
2. Server applies last-write-wins per row by `updated_at`, bumps `sync_seq`, returns the new
   rows.
3. Client pulls `GET /sync?since=cursor` and merges; cursor stored locally.

Single-user, multi-device means real conflicts are rare and LWW is acceptable. Signing up
after months of local-only use is the same batch with a larger backlog: the client pushes
every local row under its own user id (§4.2) and the server accepts it.

Rating edits are ordinary upserts on `days`, so rating the same evening on phone and tablet
settles to the later write without any special casing.

### 7.4 Analytics

Every number is computed on device from local rows — no server call, no model, no network.
`GET /insights` exists for the case of a second device asking for the same view, and its
answers must match the local ones, because the arithmetic is the same.

### 7.5 Storage

Nothing to store: v1 has no photos and no audio. The bucket, the signed URLs and the media
table are deferred with the rest of media (§3.1).

---

## 8. Privacy and security

### 8.1 Promises the app makes

- No advertising SDKs; no third-party analytics beyond crash reports and opt-in funnel
  events.
- Staff cannot read entry bodies, ratings or gratitude. Support has no such tool.
- Leaving is one flow: delete the account and everything goes, locally at once and on the
  server within 24 h.
- Server-side encryption at rest (Postgres), TLS 1.3 in transit.

Export is deferred in v1 (§3.1). That weakens the "leaving is easy" promise and is the
first thing to put back if the scope allows it.

### 8.2 Security baseline

PBKDF2 password hashing (the Identity default), unique email, lockout for five minutes
after ten failed attempts, refresh-token rotation with reuse detection, strict CORS, no
secrets in the client, per-user row isolation enforced in queries, rate limits on auth,
soft-delete with 30-day purge, account deletion that actually deletes.

### 8.3 On-device AI, precisely

No LLM. On-device sentiment runs on Apple `NaturalLanguage` (iOS) and ML Kit or a bundled
small classifier (Android) behind one `SentimentService` interface, producing a discrete
tone for the day. If the platform API is unavailable the feature degrades to nothing and
the app is unchanged. Nothing is uploaded.

Rating averages, weekday patterns, streaks and tag counts involve no model at all — they
are arithmetic over local rows, computed on device, and therefore work offline and free.

---

## 9. Milestones

| # | Milestone | Done when |
|---|---|---|
| M0 | Foundation | Flutter shell, paper theme, drift schema, .NET skeleton, Postgres migrations, CI |
| M1 | Account & sync | local-only mode, email + Apple + Google, refresh rotation, delta sync, sign-up without re-keying |
| M2 | Day record | rating control + ramp, tags, gratitude, sentiment, per-day writing, autosave, resume, streak with recovery |
| M3 | Notes & day detail | notes list + editor, day detail, pinning, soft delete |
| M4 | Analytics | weekly numbers, monthly grid and numbers, sentiment peaks, all offline |
| M5 | Ship | on-device sentiment on both platforms, error states, store listings, TestFlight + Play internal |

M2 is the go/no-go for the wedge; M3 is the go/no-go for retention. If rating a day does not
feel like something you would do unprompted for a week, the rest does not matter.

---

## 10. Open questions

1. **Scale shape.** This spec treats 0 as the worst day and 5 as one of the best, with the
   neutral point at 2.5. Confirm the direction, because flipping it later invalidates every
   chart, every anchor and every export. Confirm too that 0 is in the range at all — a
   scale that starts at 1 never lets anyone record the day that actually mattered.
2. **Rating editability.** v1 lets you re-rate any past day. The alternative — rating locks
   at midnight — produces cleaner data and a more honest record, at the cost of the person
   who forgot at 23:50. Current choice optimises for forgiveness.
3. **Sentiment, manual or computed.** A day's tone can be picked by hand from the emotion
   taxonomy, derived on-device from what you wrote, or both. v1 allows both, with the
   manual pick winning. Confirm whether the computed tone should overwrite the manual one
   on a later day.
4. **Name.** "Aroel" reads well; check trademark and App Store availability before logo work.
5. **Store risk.** Journaling with mood tracking sits near the "medical" line. Copy must
   avoid diagnosis language from day one.
6. **Free forever.** Fine while you fund hosting; decide now whether it is permanent, because
   a later paywall on an explicitly free product costs trust.
7. **Differentiation without a curriculum.** With programs gone, the app's difference is
   the anchored scale, the four-second close and the paper design. That is a thinner moat
   than a curriculum. Worth deciding whether v2 leans into the writing side (a better
   editor, richer media) or the ritual side (streaks, weekly reviews).
8. **Streak recovery rules.** v1 lets the user recover a missed day for free and
   indefinitely (§2.3). Decide whether recovery should be limited per streak, and whether
   recovered days count as kept days in the analytics averages. *As implemented for now:*
   recovery is free and unlimited, the grace token is spent when it forgives a miss and a
   fresh streak starts with a fresh one, and a recovered day counts as kept but is not yet
   distinguished in the averages.
9. **History of this document.** Earlier revisions specified guided programs with sessions,
   search, export, media, reminders, a timeline and a weekly reflection card. All of it was
   deliberately cut (§3.1). The git history holds the full design; nothing was lost by
   accident.
