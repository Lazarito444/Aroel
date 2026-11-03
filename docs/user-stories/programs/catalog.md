# Programs — Catalog & enrollment

Epic E3 · Milestone M2 · Source: [`../README.md`](../README.md)

### US-301 · Browse and see a program's promise
As a **Writer**, I want to open a program — cover, description, day list with completion ticks, progress — so that I know what I'm committing to before I commit. [§5.4]

- Three launch programs only: *Begin* (7 days), *Untangle* (30 days), *Gratitude* (14 days, seeded from the day record). **[invariant]** [§3]
- Programs, program days and prompts are server-owned, read-only, versioned content pulled by the client — never client-writable, never user-authored in v1. **[invariant]** [§4.2, §7.3, §10 (open question 1)]

### US-302 · Enroll in one tap and start day 1
As a **Writer**, I want to enroll and be inside day 1 immediately — no scheduled start date, no form — so that momentum survives the tap. [§5.4]

- Enrollment creates an `enrollments` row (status `active`, current_day 1) and does not wait on the network. **[invariant: offline-first]** [§4.2, §7.1]

### US-306 · Pause or leave a program without punishment
As a **Writer**, I want to pause or leave a program from its detail screen, so that life can interrupt without the program haunting me. [§5.4]

- Enrollment status moves to `paused` / `abandoned`; no guilt copy. **[invariant: no streak guilt, §6.5]** [§4.2, §6.5]
