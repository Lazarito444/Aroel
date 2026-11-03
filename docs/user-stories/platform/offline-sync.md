# Platform — Offline & sync

Cross-cutting · Milestone M1–M2, ongoing · Source: [`../README.md`](../README.md)

### US-801 · My journal is my local database
As a **Writer**, I want every interaction to land in local SQLite first — offline writes with client-generated `uuid7` keys that never need renumbering — so that airplane mode is indistinguishable from a slow server. [§7.1, §7.3, AGENTS.md]

- Every read from SQLite, every write to SQLite first. The network is a sync process, never an interaction dependency. **[invariant]** [§7.1]
- All primary keys are client-generated `uuid7`; offline writes never renumber or re-key. **[invariant]** [§4, AGENTS.md]
- Each record carries two time coordinates: a UTC `timestamptz` and a `local_date`. A day is a diary concept; the `days` spine is keyed `unique (user_id, local_date)` and every history/insight query reads from it — no aggregation guesswork, no timezone drift. **[invariant]** [§4, §4.1]

### US-802 · Sync that survives clock skew
As a **Writer**, I want my second device to converge with my first — including an evening I rated on both — so that multi-device isn't an archaeology project. [§7.3]

- Delta sync is driven by the server-assigned monotonic **`sync_seq` cursor**, not `updated_at`. Rows apply last-write-wins per row by `updated_at` once pulled in; the cursor is what guarantees no clock-skew omission and no rows missed in the same millisecond as the pull. ⚠ **[invariant — AGENTS.md: sync_seq, not updated_at, drives delta sync]** [§4.4, §7.3, AGENTS.md]
- Endpoints: `POST /sync/batch` (upserts keyed by `uuid7`, deletes as tombstones), then pull `GET /sync?since=cursor`; cursor stored locally. [§7.3]
- Single-user, multi-device; last-write-wins per row is acceptable and requires no special casing for rating edits. **[invariant]** [§7.3]
- Program and prompt content is server-owned, versioned, read-only. [§7.3]
- Rate limits: 5/min auth, 60/min sync, 30/min search. **[invariant]** [§7.2]
