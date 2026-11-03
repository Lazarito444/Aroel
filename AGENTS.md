# AGENTS.md

Aroel is a personal journaling app for iOS/Android. **The repo is currently docs-only — no code,
manifest, or CI exists yet.** The single source of truth is [`docs/scope-and-design.md`](docs/scope-and-design.md)
(v1 scope, domain model, screens, design system, architecture, milestones). Read it before
building anything; `README.md` is just a pointer to it.

## Commands

None exist. There is no `package.json`, `pubspec.yaml`, `.sln`, Makefile, or workflow to
discover — do not hunt for scripts. When you scaffold the first code (milestone M0 in §9),
create the tooling then and record the real commands here. Verify what you add actually runs
before claiming a milestone is done.

## Mandated stack (§7)

- **Client:** Flutter + Riverpod + `go_router` + `drift` (SQLite) + `freezed` + `dio`/`retrofit`.
- **Server:** .NET 9 minimal APIs, vertical slices, EF Core + Npgsql, one project.
- Layout is feature-first: `lib/app`, `lib/core`, `lib/data`, `lib/features/<feature>`, `lib/ui`.
  No cross-feature imports except through `ui/` and `core/`.
- API is versioned under `/v1`; endpoint list is in §7.2.

Don't substitute a different stack or a monorepo split without asking.

## Invariants that are easy to break

- **`rating_half` is `smallint` in `0..10`** — half points, never a float or decimal. It is
  nullable, and `0` is a legitimate score: "unrated" is `NULL`/omitted, never `0`.
- **Two time coordinates per record:** UTC `timestamptz` plus `local_date` (`date`). A day is a
  diary concept, not a UTC one. `days` holds `unique (user_id, local_date)` and is the spine
  every history/insight query reads from.
- **Primary keys are client-generated `uuid7`.** Offline writes must need no renumbering.
- **`sync_seq` (server-assigned monotonic cursor) drives delta sync**, not `updated_at` — clock
  skew and same-millisecond writes break the latter. Conflict resolution is last-write-wins.
- **Offline-first:** every read comes from SQLite, every write lands in SQLite first. The network
  is a sync process, never a dependency of an interaction.
- **No LLM, no social features, no paywall in v1** (§1.4, §3.1, §8.3). Only on-device sentiment
  behind one `SentimentService`; degrade to nothing when unavailable.
- Writes during a session autosave per keystroke with a 2 s debounced flush; nothing typed may
  be lost across app kill or airplane mode.

## Design system is specified, not invented (§6)

- Palette tokens (`paper`, `paper.raised`, `paper.sunk`, `ink`, `ink.soft`, `ink.faint`,
  `accent`, `seal`, `sage`, `amber`, `border`) have fixed light/dark hex values — use them, not
  arbitrary colours. Elevation shadows are warm-tinted, never neutral grey.
- **Newsreader for the user's prose and headings; Inter for UI chrome only.** Never set prose in
  Inter.
- The rating ramp (§6.6) is the only place colour encodes meaning, and it diverges around 2.5,
  not 3. The eleven hex stops and the 0.0–5.0 anchor copy are literal spec — copy them, don't
  approximate.
- Spacing steps 4/8/12/16/24/32/48, radii 8/12/16/24/999, motion 120/220/320 ms.
- Copy is second person, no exclamation marks, no streak guilt, no diagnosis language (store-risk
  constraint, §10.6).

## Open questions (§10) are unresolved

Scale direction, program authorship, rating editability, voice capture, and the "free forever"
promise are undecided. Don't silently pick one; surface the choice. Tree state may be ahead of
the doc's "pre-build" status — when prose and code disagree, trust the code and update the doc.
