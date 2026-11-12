# AGENTS.md

Aroel is a personal journaling app for iOS/Android. **The repo is docs-only on the client side —
no Flutter app exists yet**; the server scaffold lives in [`backend/`](backend). The single source
of truth is [`docs/scope-and-design.md`](docs/scope-and-design.md)
(v1 scope, domain model, screens, design system, architecture, milestones). Read it before
building anything; `README.md` is just a pointer to it.

## Commands

Backend (SDK pinned by `global.json` to 11.0.x, C# 15):

```
dotnet build backend/Aroel.slnx
dotnet test backend/Aroel.slnx
dotnet run --project backend/Aroel.Api
```

Migrations (needs the `dotnet-ef` tool, and a Postgres reachable at the `Aroel` connection
string in `backend/Aroel.Api/appsettings.json`):

```
dotnet ef migrations add <Name> --project backend/Aroel.Data --startup-project backend/Aroel.Api --output-dir Migrations
dotnet ef database update --project backend/Aroel.Data --startup-project backend/Aroel.Api
```

Backend layout — four projects, not one, and the direction of the arrows is the point:

```
Aroel.Core        domain: entities, value objects, Result, contracts   (no framework)
Aroel.Application use cases and the ports they need                    (depends on Core)
Aroel.Data        EF Core, ASP.NET Core Identity, the migrations        (depends on Core, Application)
Aroel.Api         composition root: wiring, endpoints                   (depends on all three)
Aroel.Core.Tests  domain tests        Aroel.Data.Tests  identity tests
```

Client: no `package.json` or `pubspec.yaml` exists yet — do not hunt for scripts. When you
scaffold the first Flutter code (milestone M0 in §9), create the tooling then and record the
real commands here. Verify what you add actually runs before claiming a milestone is done.

## How the domain is written

- **Every entity is built by a static `Create` that returns a `Result`.** A rule that cannot be
  met is a value the caller has to deal with, never an exception it can forget.
- **State changes only through behaviour.** No public setters, no anemic entities, no
  `data annotations` on the domain.
- **Identifiers are `Guid`**, generated with `Guid.CreateVersion7()` so they sort by creation time and
  can be produced on the device. The API boundary checks the version when it starts accepting
  client ids.
- **The domain does not know about EF Core or Identity.** The one exception is deliberate:
  `InfrastructureUser` (ASP.NET Core Identity) and `CoreUser` (the journal profile) are two
  halves of one account, tied together by key.
- Errors are `AppError` codes, never prose; the API localizer turns a code into a message.

## How the server is wired

- **`Program.cs` reads as a list of decisions.** The wiring lives in
  `Aroel.Api/Composition/AroelComposition.cs`, declared as a C# 14 extension block, so
  `builder.Services.AddAroelServices(connectionString)` says what the server is without
  saying how.
- **The service graph is validated at startup** (`ValidateOnBuild`), so a missing registration
  fails at boot instead of on the first request that needs it.
- **The identity policy lives in `Aroel.Data`** (`IdentitySetup`) and is pinned by a test;
  the composition root only wires it.

## Mandated stack (§7)

- **Client:** Flutter + Riverpod + `go_router` + `drift` (SQLite) + `freezed` + `dio`/`retrofit`.
- **Server:** .NET 11 minimal APIs (C# 15), vertical slices, EF Core + Npgsql. The backend is
  four projects (see above) rather than one; the layering is the point.
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
  behind one `SentimentService`; degrade to nothing when unavailable. Every analytics number is
  local arithmetic — no model writes a number or a sentence.
- **No guided programs, sessions or enrollments in v1** (§1.2, §1.4, §3.1). The day record is
  the core loop: rating, tags, gratitude, sentiment, per-day writing. US-301…306 are retired IDs
  — do not reuse them.
- **The account is optional** (§5.1, §4.2). The client owns its `uuid7` user id from first
  launch and works local-only until the user signs up; signing up adopts the local journal
  without re-keying a row. Never put a sign-in wall in front of writing.
- The streak forgives one missed day and can be recovered by hand; notes never count toward it
  (§2.3, §2.6). No streak-guilt copy, ever.
- Writes autosave per keystroke with a 2 s debounced flush; nothing typed may
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
  constraint, §10.5).

## Open questions (§10) are unresolved

Scale direction, rating editability, sentiment manual versus computed (§10.3), streak recovery
rules (§10.8), differentiation without a curriculum (§10.7), and the "free forever" promise are
undecided. Don't silently pick one; surface the choice. Tree state may be ahead of the doc's
"pre-build" status — when prose and code disagree, trust the code and update the doc.
